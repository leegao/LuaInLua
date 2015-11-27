-- interprets a subset of Lua directly

local visitor = require 'lua.base_visitor'
local parser = require 'lua.parser'
local ir = require 'bytecode.ir'
local utils = require 'common.utils'

local STATEMENT = {}
local MAX_REGISTERS = 255
-- TODO: fix me, TOP will only happen immediately before a call, table, or return, so they will never effect the
-- computation of the actual register stack
local TOP = -MAX_REGISTERS

local function peek(stack) return stack[#stack] end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end

local closures = {}

local function new_closure(nparams, is_vararg)
  local closure = {
    first_line   = -1,
    last_line    = -1,
    nparams      = nparams,
    is_vararg    = is_vararg,
    stack_size   = 0,
    code         = {},
    constants    = {},
    upvalues     = {},
    debug        = {},
    ir_context   = ir(),
  }

  return closure
end

local function enter(nparams, is_vararg)
  local scope = {
    closure = new_closure(nparams or 0, is_vararg or false),
    local_id = 0,
    constant_id = 1,
    locals = {},
    constants = {},

    reserved_registers = {},
  }

  function scope:enter()
    push({}, self.locals)
  end

  function scope:exit()
    return pop(self.locals)
  end

  function scope:block()
    return peek(self.locals)
  end

  function scope:reserve(start, n)
    for i = start, start + n - 1 do
      assert(not self.reserved_registers[i], "Register " .. i .. " is already reserved")
      self.reserved_registers[i] = true
    end
    return start
  end

  function scope:free(alphas)
    local start, n = unpack(alphas)
    assert(self.reserved_registers[start], "Register " .. start .. " is already free")
    for i = start, start + n - 1 do
      self.reserved_registers[i] = nil
    end
    -- verify that there's no more reserved registers
    for key in pairs(self.reserved_registers) do
      assert(key < start)
    end
  end

  function scope:next(n)
    if not n then n = 1 end
    local max = 0
    for key in pairs(self.reserved_registers) do
      if key > max then max = key end
    end
    return self:reserve(max + 1, n)
  end

  function scope:own_or_propagate(alphas, n)
    if not alphas and n then error "Must propagate alphas" end
    n = n or 1
    if not alphas then
      return self:next(), true
    end
    local alpha, num = unpack(alphas)
    if num == n then
      return alpha, false
    elseif num < 0 then
      return alpha, false
    else
      assert(num >= n)
      return alpha, false, {alpha + n, num - n}
    end
  end

  function scope:bind(name, id)
    assert(self.reserved_registers[id], "Cannot bind a new local to a non-reserved regiser")
    table.insert(self:block(), {name, id})
    return id
  end

  function scope:get_parent()
    local last
    for scope in utils.loop(closures) do
      if scope == self then
        return last
      end
      last = scope
    end
    error "Illegal state"
  end

  function scope:markupval(location, id)
    print("Implement me")
    return location, id
  end

  function scope:look_for(name)
    for i = #self.locals, 1, -1 do
      local block = self.locals[i]
      for j = #block, 1, -1 do
        local var, id = unpack(block[j])
        if var == name then
          return id, self
        end
      end
    end
    -- go to the previous closure to look for an upvalue
    local parent = self:get_parent()
    if not parent then
      error "Unimplemented"
    end
    return self:markupval(parent:lookfor(name))
  end

  function scope:const(value)
    local constants = self.constants
    if constants[value] then
      return constants[value]
    end
    local id = self.constant_id
    self.constant_id = id + 1
    constants[value] = id
    return id
  end

  function scope:null(rest)
    if rest[2] < 0 then return end
    assert(rest[2] > 0)
    self:emit("LOADNIL", rest[1], rest[2] - 1)
  end

  function scope:emit(...)
    print(...)
  end

  function scope:finalize()
    print "Finalize is unimplemented"
  end

  push(scope, closures)
  return scope
end

local function close()
  return pop(closures):finalize()
end

local function latest()
  return peek(closures)
end

local function L(number)
  if number >= 0 then
    return number
  end
end

local function combine(start, rest)
  if not rest then return {start, 1} end
  assert(rest[1] == start + 1)
  return {start, rest[2] + 1}
end

local function from(alpha)
  if alpha < 0 then
    return 0
  else
    return alpha
  end
end

local BETA = math.max

-- emit ASTs of bytecodes
-- closure is the current state, alpha is the register to assign into, beta is the "frontier", and gamma is the number
-- of values to return
-- @alphas - optional: either a location to move into or own the object in this field
-- @gamma - number of expressions to return, 0 if not applicable
-- @return alphas - the locations of the current expression if applicable
local interpreter = visitor {
  on_any_constant = function(self, value, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local k = closure:const(value)
    closure:emit("LOADK", alpha, value)

    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_number = function(self, node, alphas)
    return self:on_any_constant(tonumber(node.value), alphas)
  end,

  on_string = function(self, node, alphas)
    return self:on_any_constant(tostring(node.value), alphas)
  end,

  on_true = function(self, _, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    closure:emit("LOADBOOL", alpha, 1)
    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_false = function(self, _, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    closure:emit("LOADBOOL", alpha, 0)
    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_name = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local r = closure:look_for(node.value)
    closure:emit("MOVE", alpha, r)
    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_nil = function(self, _, alphas)
    local closure = latest()
    closure:null(alphas)
    return alphas
  end,

  on_unop = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local operator = node.operator.token[1]
    local operand = self:accept(node.operand, node.operand.kind ~= 'name' and {alpha, 1})
    local select = {MIN = "UNM", NOT = "NOT", HASH = "LEN"}
    closure:emit(select[operator], alpha, operand[1])
    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_binop = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local operator = node.operator.token[1]
    local left = self:accept(node.left, node.left.kind ~= 'name' and {alpha, 1})
    local id_right = closure:next()
    local right = self:accept(node.right, node.right.kind ~= 'name' and {id_right, 1})
    local select = {
      PLUS = "ADD",
      MIN = "SUB",
      MUL = "MUL",
      DIV = "DIV",
      POW = "POW",
      MOD = "MOD",
      CONCAT = "CONCAT",
      AND = "AND",
      OR = "OR",
    }
    if select[operator] then
      closure:emit(select[operator], alpha, left[1], right[1])
    else
      error "Unimplemented"
    end
    closure:free({id_right, 1})
    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_table = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    closure:emit("NEWTABLE", alpha, 0, 0)
    -- get the elements
    local last_index
    for child in node:children() do if not child.index then last_index = child end end
    local last = alpha
    for child in node:children() do
      if not child.index then
        local id = closure:next()
        assert(id == last + 1)
        last = id
        if child ~= last_index then
          self:accept(child.value, {id, 1})
        else
          local final = self:accept(child.value, {id, TOP})
          closure:emit("SETLIST", alpha, from(last - alpha + final[2] - 1), 1)
          closure:free({alpha + 1, last - alpha})
          break
        end
      end
    end

    for child in node:children() do
      if child.index then
        local index_id = closure:next()
        local index = self:accept(child.index, {index_id, 1})
        local value_id = closure:next()
        local value = self:accept(child.value, {value_id, 1})
        closure:emit("SETTABLE", alpha, index[1], value[1])
        assert(value_id == index_id + 1)
        closure:free({index_id, 2})
      end
    end

    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  call_imp = function(self, node, call, first, num_in, num_out)
    local closure = latest()
    if #node.args ~= 0 then
      local previous_id = first
      for arg in node.args:children() do
        local id = closure:next()
        assert(id == previous_id + 1)
        previous_id = id
        if arg ~= node.args[#node.args] then
          self:accept(arg, {id, 1})
        else
          local _, pack_length = unpack(self:accept(arg, {id, TOP}))
          closure:emit("CALL", call, from(num_in + #node.args + pack_length), from(num_out + 1))
          -- time to destroy the previous ids
          assert(id == first + #node.args)
          closure:free {first + 1, #node.args}
          break
        end
      end
    else
      closure:emit("CALL", call, num_in + 1, from(num_out + 1))
    end
  end,

  on_call = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)

    -- first, let's free up rest so the subexpressions can use them
    if rest then closure:free(rest) end
    local num_out = alphas and alphas[2] or TOP
    -- node = call -> target : expr, args : args -> [expr]
    self:accept(node.target, {alpha, 1})
    self:call_imp(node, alpha, alpha, 0, num_out)
    -- next, reserve the output registers again
    if rest then assert(closure:next(rest[2]) == rest[1]) end

    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, num_out}
  end,

  on_selfcall = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)

    -- first, let's free up rest so the subexpressions can use them
    if rest then closure:free(rest) end
    local num_out = alphas and alphas[2] or TOP
    -- node = selfcall = taget : (index = left : expr, right : name), args
    self:accept(node.target.left, {alpha, 1})
    local base = closure:next()
    assert(base == alpha + 1)
    self:accept(node.target.right, {base, 1})
    closure:emit("SELF", alpha, alpha, base)
    self:call_imp(node, alpha, alpha + 1, 1, num_out)
    closure:free{base, 1}
    -- next, reserve the output registers again
    if rest then assert(closure:next(rest[2]) == rest[1]) end

    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, num_out}
  end,

  on_vararg = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local num_out = alphas and alphas[2] or TOP

    closure:emit("VARARG", alpha, from(num_out + 1))

    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, num_out}
  end,

  on_index = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)

    self:accept(node.left, {alpha, 1})
    local right = closure:next()
    closure:free(self:accept(node.right, {right, 1}))
    closure:emit("GETTABLE", alpha, alpha, right)

    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_explist = function(self, node, alphas)
    error "Illegal state: explist"
  end,

  on_localassign = function(self, node)
    local closure = latest()
    local max = BETA(#node.left, #node.right)
    for i = 1, max do
      local name = node.left[i]
      local exp = node.right[i]
      if name and exp and exp ~= node.right[#node.right] then
        local id = closure:next()
        self:accept(exp, {id, 1})
        closure:bind(name.value, id)
      elseif name and exp and exp == node.right[#node.right] then
        local len = max - i + 1
        local id = closure:next(len)
        local rest = {id, len}
        self:accept(exp, rest)
        for j = 0, len - 1 do
          closure:bind(node.left[i + j].value, id + j)
        end
        break
      elseif name then
        local id = closure:next(max - i + 1)
        local rest = {id, max - i + 1}
        closure:null(rest)
        break
      else
        self:accept(exp)
      end
    end
    return STATEMENT
  end,

  on_block = function(self, node)
    local closure = latest()
    closure:enter()
    for child in node:children() do
      self:accept(child)
    end
    closure:exit()
    return STATEMENT
  end,
}


local tree = parser([[
local a = 1;
local b, c = "asdfasdf";
local c = 1, 2;
local e = (not c) + 3;
local f = {1, e, c, zzz = 5, [3] = 2}
local x, y, z = a("zzz", a(), "xxx", a(3,c,5))
local b = z:lol(a)
local c = {...}
local z, x, y = ...
local g = f[3].c
local h = g.foo
]])
-- main closure
enter()
interpreter:accept(tree)
close()