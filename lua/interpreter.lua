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

  function scope:reserve(i)
    assert(not self.reserved_registers[i], "Register " .. i .. " is already reserved")
    self.reserved_registers[i] = true
    return i
  end

  function scope:free(i)
    assert(self.reserved_registers[i], "Register " .. i .. " is already free")
    self.reserved_registers[i] = nil
  end

  function scope:next()
    -- dumb traversal
    for i=1, MAX_REGISTERS do
      if not self.reserved_registers[i] then
        return self:reserve(i)
      end
    end
    error "Ran out of registers to allocate"
  end

  function scope:continguous()
    local max = 0
    for key in pairs(self.reserved_registers) do
      if key > max then max = key end
    end
    return self:reserve(max)
  end

  function scope:own_or_propagate(alphas)
    if not alphas or #alphas == 0 then
      return self:next()
    end
    assert(#alphas == 1)
    return alphas[1]
  end

  function scope:new_local(name)
    local id = self.local_id
    self.local_id = self.local_id + 1
    table.insert(self.locals, {name, id})
    self:reserve(id)
    return id
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
    local alpha = closure:own_or_propagate(alphas)
    local k = closure:const(value)
    if L(alpha) then
      -- emit loadk, alpha, k
      closure:emit("LOADK", alpha, k)
      return {alpha}
    end
    error "LValue optimization unimplemented"
  end,

  on_number = function(self, node, alphas)
    return self:on_any_constant(tonumber(node.value), alphas)
  end,

  on_string = function(self, node, alphas)
    return self:on_any_constant(tostring(node.value), alphas)
  end,

  on_true = function(self, node, alphas)
    local closure = latest()
    local alpha = closure:own_or_propagate(alphas)
    if L(alpha) then
      closure:emit("LOADBOOL", alpha, 1)
      return {alpha}
    end
    error "LValue optimization unavailable"
  end,

  on_false = function(self, node, alphas)
    local closure = latest()
    local alpha = closure:own_or_propagate(alphas)
    if L(alpha) then
      closure:emit("LOADBOOL", alpha, 0)
      return {alpha}
    end
    error "LValue optimization unavailable"
  end,

  on_explist = function(self, node, alphas)
    local closure = latest()
    for i, child in ipairs(node) do
      local returned_alpha = self:accept(child, {alphas[i]})
      if i > #alphas then
        for alpha in utils.loop(returned_alpha) do closure:free(alpha) end
      end
    end
    return alphas
  end,

  on_localassign = function(self, node)
    local closure = latest()
    local ids = {}
    for name in node.left:children() do
      table.insert(ids, closure:new_local(name))
    end
    local alphas = self:accept(node.right, ids)
    for i, id in ipairs(ids) do
      assert(alphas[i] == id)
    end
    return STATEMENT
  end,

  on_block = function(self, node)
    -- TODO: add block
    for child in node:children() do
      self:accept(child)
    end
    return STATEMENT
  end,
}


local tree = parser([[local a, b = "", 3, true, true]])
-- main closure
enter()
interpreter:accept(tree)
-- close()