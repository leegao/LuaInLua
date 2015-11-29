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
  print("Entering closure")
  local scope = {
    closure = new_closure(nparams or 0, is_vararg or false),
    local_id = 0,
    constant_id = 1,
    locals = {},
    constants = {},
    upvalues = {},
    code = {},
    prototypes = {},

    reserved_registers = {},
  }

  scope.id = peek(closures) and #peek(closures).prototypes or 0

  function scope:level()
    for i, scope in ipairs(closures) do
      if scope == self then return i end
    end
    error "Illegal state"
  end

  function scope:enter()
    local id = self:next()
    push({start = id}, self.locals)
    self:free{id, 1}
  end

  function scope:exit()
    local locals = pop(self.locals)
    self:free_after(locals.start)
    return locals
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

  function scope:free_after(start)
    local free_bank = {}
    for key in pairs(self.reserved_registers) do
      if key >= start then
        free_bank[key] = true
      end
    end

    for key in pairs(free_bank) do
      self.reserved_registers[key] = nil
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

  function scope:searchup(id, level)
    for i, upvalue in ipairs(self.upvalues) do
      if id == upvalue[1] and level == upvalue[2] then
        return i
      end
    end
  end

  function scope:markupval(id, other)
    if not id then return end
    if not self:searchup(id, other) then
      table.insert(self.upvalues, {id, other})
    end

    return id, other
  end

  function scope:look_for(name)
    for i = #self.locals, 1, -1 do
      local block = self.locals[i]
      for j = #block, 1, -1 do
        local var, id = unpack(block[j])
        if var == name then
          return id, self:level()
        end
      end
    end
    -- go to the previous closure to look for an upvalue
    local parent = self:get_parent()
    if not parent then
      return
    end
    return self:markupval(parent:look_for(name))
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
    local levels = self:level() - 2
    if levels < 0 then
      print(#self.code + 1, ...)
    else
      print(("    "):rep(levels), #self.code + 1, ...)
    end
    table.insert(self.code, {...})
  end

  function scope:pc()
    return #self.code
  end

  function scope:patch_jmp(start, finish)
    print("Changing sBx of " .. start .. " to " .. finish - start)
    local instr = self.code[start]
    assert(instr[1] == 'JMP' or instr[1] == 'FORPREP')
    assert(instr[3] == '#')
    instr[3] = finish
    instr[5] = '; to ' .. (finish + 1)
  end

  function scope:finalize()
    print "Finalize is unimplemented"
    local latest = peek(closures)
    if latest then
      table.insert(latest.prototypes, self)
    end

    return self, #closures + 1
  end

  push(scope, closures)
  return scope
end

local function close()
  print "Leaving closure"
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
    closure:emit("LOADK", alpha, k, '', "; " .. tostring(value))

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
    local r, scope = closure:look_for(node.value)
    if scope == closure:level() then
      closure:emit("MOVE", alpha, r)
    elseif scope then
      local up = closure:searchup(r, scope)
      assert(up, "Upvalue must have been populated")
      closure:emit("GETUPVALUE", alpha, up)
    else
      -- global
      local k = closure:const(node.value)
      closure:emit("GETTABUP", alpha, 0, k, "; " .. node.value)
    end

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

  on_function = function(self, node, alphas)
    local closure = latest()
    local alpha, mine, rest = closure:own_or_propagate(alphas)

    local level = closure:level()

    -- node : functiondef = parameters : (parameters = [names], vararg), body : block
    enter(#node.parameters, not not node.parameters.vararg)
    do
      local func = latest()
      local parameters = node.parameters
      for name in parameters:children() do
        func:bind(name.value, func:next())
      end
      self:accept(node.body)
      func:emit("RETURN", 0, 1)
    end
    local prototype, protolevel = close()
    closure:emit("CLOSURE", alpha, prototype.id)
    -- mark upvalues
    for upvalue in utils.loop(prototype.upvalues) do
      local register, uplevel = unpack(upvalue)
      if uplevel == level then
        -- emit a move
        closure:emit("MOVE", 0, register, '', "; upvalue")
      else
        -- emit an upvalue
        closure:emit("GETUPVAL", 0, closure:searchup(register, uplevel), '', "; upvalue")
      end
    end

    if rest then closure:null(rest) end
    if mine then closure:free(combine(alpha, rest)) end
    return {alpha, 1}
  end,

  on_explist = function(self, node, alphas)
    error "Illegal state: explist"
  end,

  on_localassign = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()

    local max = BETA(#node.left, #node.right)
    if #node.right == 0 then
      assert(#node.left ~= 0)
      -- this is only possible if we have `local x, y, z`
      local id = closure:next(max)
      local rest = {id, max}
      closure:null(rest)
      for j = 1, max do
        closure:bind(node.left[j].value, id + j - 1)
      end
      return STATEMENT
    end

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
      else
        self:accept(assert(not name and exp))
      end
    end
    return self:statement(start_pc)
  end,

  assign = function(self, left, register)
    local closure = latest()
    if left.kind == 'name' then
      local r, scope = closure:look_for(left.value)
      if scope == closure:level() then
        closure:emit("MOVE", r, register)
      elseif scope then
        local up = closure:searchup(r, scope)
        assert(up, "Upvalue must have been populated")
        closure:emit("SETUPVALUE", up, register)
      else
        -- global
        closure:emit("SETTABUP", 0, closure:const(left.value), register, "; " .. left.value)
      end
    else
      assert(left.kind == 'index')
      local alpha = closure:next()
      self:accept(left.left, {alpha, 1})
      local right = closure:next()
      assert(right == alpha + 1)
      self:accept(left.right, {right, 1})
      closure:free({alpha, 2})
      closure:emit("SETTABLE", alpha, right, register)
    end
  end,

  on_assignments = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    local max = BETA(#node.left, #node.right)
    for i = 1, max do
      local left = node.left[i]
      local exp = node.right[i]
      if left and exp and exp ~= node.right[#node.right] then
        local id = closure:next()
        self:accept(exp, {id, 1})
        self:assign(left, id)
        closure:free{id, 1}
      elseif left and exp and exp == node.right[#node.right] then
        local len = max - i + 1
        local id = closure:next(len)
        local rest = {id, len}
        self:accept(exp, rest)
        for j = 0, len - 1 do
          self:assign(node.left[i + j], id + j)
        end
        closure:free(rest)
        break
      else
        self:accept(exp)
      end
    end
    return self:statement(start_pc)
  end,

  on_block = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    closure:enter()
    for child in node:children() do
      self:accept(child)
    end
    closure:exit()
    return self:statement(start_pc)
  end,

  on_if = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    local reg = closure:next()
    local finishers = {}
    self:accept(node.cond, {reg, 1})
    closure:free{reg, 1}
    closure:emit("TEST", reg, 0)
    closure:emit("JMP", 0, "#", '', '; TODO: patch in')
    local hole = closure:pc()
    -- the block
    self:accept(node.block)
    closure:emit("JMP", 0, "#", '', '; TODO: patch in end')
    table.insert(finishers, closure:pc())
    -- see if there's an elseif
    if node.elseifs then
      for conditional in utils.loop(node.elseifs) do
        closure:patch_jmp(hole, closure:pc()) -- goto closure:pc() + 1
        local reg = closure:next()
        self:accept(conditional.cond, {reg, 1})
        closure:free{reg, 1}
        closure:emit("TEST", reg, 0)
        closure:emit("JMP", 0, "#", '', '; TODO: patch in')
        hole = closure:pc()
        self:accept(conditional.block)
        closure:emit("JMP", 0, "#", '', '; TODO: patch in end')
        table.insert(finishers, closure:pc())
      end
    end
    closure:patch_jmp(hole, closure:pc())
    if node.else_ then
      self:accept(node.else_.block)
    end
    for finisher in utils.loop(finishers) do
      closure:patch_jmp(finisher, closure:pc())
    end
    return self:statement(start_pc)
  end,

  on_while = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    local reg = closure:next()
    self:accept(node.cond, {reg, 1})
    closure:free{reg, 1}
    closure:emit("TEST", reg, 1)
    closure:emit("JMP", 0, "#", '', '; TODO: patch in end')
    local hole = closure:pc()
    self:accept(node.block)
    closure:emit("JMP", 0, start_pc - closure:pc() - 1, '', '; to ' .. (start_pc + 1))
    closure:patch_jmp(hole, closure:pc())
    return self:statement(start_pc)
  end,

  on_repeat = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    self:accept(node.block)

    local reg = closure:next()
    self:accept(node.cond, {reg, 1})
    closure:free{reg, 1}
    closure:emit("TEST", reg, 0)
    closure:emit("JMP", 0, start_pc - closure:pc() - 1, '', '; to ' .. (start_pc + 1))
    return self:statement(start_pc)
  end,

  on_fori = function(self, node)
    -- node('fori'):set('id', from(_1)):set('start', _3):set('finish', _5):set('step', _6[1]):set('block', _8)
    --1	LOADK(A=r(1), Bx=start)
    --2	LOADK(A=r(2), Bx=finish)
    --3	LOADK(A=r(3), Bx=step)
    --4	FORPREP(A=r(1), sBx=goto FORLOOP (3))
    --5	  BLOCK
    --6	  BLOCK
    --7	  BLOCK
    --8	FORLOOP(A=r(1), sBx=goto FORPREP (-4))
    --9	RETURN(A=r(f), B=v(1))
    local closure = latest()
    local start_pc = closure:pc()
    closure:enter()
    do -- the for loop outer block
      local base = closure:next()
      -- ensure that the next 3 instructions are stored to consecutive ids
      self:accept(node.start, {base, 1})
      assert(closure:next() == base + 1)
      self:accept(node.finish, {base + 1, 1})
      assert(closure:next() == base + 2)
      if node.step then
        self:accept(node.step, {base + 2, 1})
      else
        closure:emit("LOADK", base + 2, closure:const(1))
      end
      local var = closure:next()
      assert(var == base + 3)
      closure:bind(node.id.value, var)
      closure:emit("FORPREP", base, '#', '', '; TODO: patch with end')
      local prep_pc = closure:pc()
      self:accept(node.block)
      closure:patch_jmp(prep_pc, closure:pc())
      closure:emit("FORLOOP", base, prep_pc - closure:pc() - 1, '', '; to ' .. (prep_pc + 1))
      closure:free{base, 4}
    end
    closure:exit()
    return self:statement(start_pc)
  end,

  on_callstmt = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    self:accept(unpack(node))
    return self:statement(start_pc)
  end,

  on_empty = function(self, node)
    local closure = latest()
    local start_pc = closure:pc()
    -- NOP
    return self:statement(start_pc)
  end,

  statement = function(self, start_pc)
    return {first = start_pc, last = latest():pc()}
  end,

  expression = function(self, start_pc, bundle)
    return {first = start_pc, last = latest():pc(), unpack(bundle)}
  end,
}


--local tree = parser([[
--  local a = 1;
--  local b, c = "asdfasdf";
--  local c = 1, 2;
--  local e = (not c) + 3;
--  local f = {1, e, c, zzz = 5, [3] = 2}
--  local x, y, z = a("zzz", a(), "xxx", a(3,c,5))
--  local b = z:lol(a)
--  local c = {...}
--  local z, x, y = ...
--  local g = f[3].c
--  local h = g.foo
--  local foo = function() local zzz = a, function() local yyy, xxx = zzz, b, aaa end end
--  foo:bar(1, 2, 3)
--  a, b, c, gbl = 3
--  gbl = foo()
--  gbl.x = 3
--  do
--    local abcdefg = hi
--  end
--  a = abcdefg
--  a = abcdefg
--  a = a + a
--]])

local tree = parser [[
--  if foo() then bar() elseif dog() then else foobar() end
--  while bar(f()) do print("hello") end
--  repeat foo() until bar()
--  for i = 1, 3 do print("hello") end
  local f = function() end
]]
-- main closure
enter(0, true)
interpreter:accept(tree)
latest():emit("RETURN", 0, 1)
close()