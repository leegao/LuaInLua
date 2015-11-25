-- interprets a subset of Lua directly

local visitor = require 'lua.base_visitor'
local parser = require 'lua.parser'
local ir = require 'bytecode.ir'
local utils = require 'common.utils'

local STATEMENT = {}
local MAX_REGISTERS = 255

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

  function scope:reserve(i)
    assert(not self.reserved_registers[i], "Register " .. i .. " is already reserved")
    self.reserved_registers[i] = true
    return i
  end

  function scope:free(i)
    assert(self.reserved_registers[i], "Register " .. i .. " is already free")
    self.reserved_registers[i] = nil
  end

--  function scope:next()
--    -- dumb traversal
--    for i=1, MAX_REGISTERS do
--      if not self.reserved_registers[i] then
--        return self:reserve(i)
--      end
--    end
--    error "Ran out of registers to allocate"
--  end

  function scope:next()
    local max = 0
    for key in pairs(self.reserved_registers) do
      if key > max then max = key end
    end
    return self:reserve(max + 1)
  end

  function scope:own_or_propagate(alphas)
    if not alphas or alphas[2] == 0 then
      return self:next(), true
    end
    local alpha, num = unpack(alphas)
    if num == 1 then
      return alpha, false
    else
      return alpha, false, {alpha + 1, num - 1}
    end
  end

  function scope:bind(name, id)
    assert(self.reserved_registers[id], "Cannot bind a new local to a non-reserved regiser")
    table.insert(self:block(), {name, id})
    return id
  end

  function scope:look_for(name)
    for i = #self.locals, 1, -1 do
      local block = self.locals[i]
      for j = #block, 1, -1 do
        local var, id = unpack(block[j])
        if var == name then
          return id
        end
      end
    end
    -- go to the previous closure to look for an upvalue
    error "Unimplemented"
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
    assert(rest[2] > 0)
    self:emit("LOADNIL", rest[1], rest[2] - 1)
  end

  function scope:emit(...)
    print(...)
  end

  function scope:finalize()
    error "Finalize is unimplemented"
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
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
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
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
    return {alpha, 1}
  end,

  on_false = function(self, _, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    closure:emit("LOADBOOL", alpha, 0)
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
    return {alpha, 1}
  end,

  on_name = function(self, node, alphas)
    local var = node.value
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local r = closure:look_for(var)
    if mine then
      if rest then closure:null(rest) end
      return {r, 1}
    else
      closure:emit("MOVE", alpha, r)
      if rest then closure:null(rest) end
      return {alpha, 1}
    end
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
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
    return {alpha, 1}
  end,

  on_binop = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    local operator = node.operator.token[1]
    local left = self:accept(node.left, node.left.kind ~= 'name' and {alpha, 1})
    local right = self:accept(node.right, node.right.kind ~= 'name' and {alpha + 1, 1})
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
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
    return {alpha, 1}
  end,

  on_table = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)
    -- get the elements 
    if mine then closure:free(alpha) end
    if rest then closure:null(rest) end
    return {alpha, 1}
  end,

  on_explist = function(self, node, alphas)
    local alpha, num = unpack(alphas)
    for i, child in ipairs(node) do
      self:accept(child, {alpha + i - 1, math.max(0, num - i + 1)})
    end
    return alphas
  end,

  on_localassign = function(self, node)
    local closure = latest()
    local ids = {}
    for name in node.left:children() do
      assert(name.kind == 'name')
      table.insert(ids, closure:next())
    end

    if not node.right then
      closure:null({ids[1], #ids})
      return STATEMENT
    end

    self:accept(node.right, {ids[1], #ids})

    for i, name in ipairs(node.left) do
      closure:bind(name.value, ids[i])
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
local f = {}
]])
-- main closure
enter()
interpreter:accept(tree)
-- close()