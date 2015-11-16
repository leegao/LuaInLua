-- See A No-Frills Introduction to Lua 5.1 VM Instructions
-- and http://www.lua.org/source/5.2/lundump.c.html#luaU_undump for changes

local opcode = require "bytecode.opcode"
local reader  = require "bytecode.reader"

local function header(ctx)
  assert(ctx:int() == 0x61754c1b) -- ESC. Lua
  assert(ctx:byte() == 0x52) -- version
  assert(ctx:byte() == 0) -- format version
  assert(ctx:byte() == 1) -- little endian
  assert(ctx:byte(), 4) -- sizeof(int)
  local sizet = assert(ctx:byte()) -- sizeof(size_t)
  assert(ctx:byte() == 4) -- sizeof(Instruction)
  assert(ctx:byte() == 8) -- sizeof(number)
  assert(ctx:byte() == 0) -- is integer
  assert(ctx:int() == 0x0a0d9319) -- TAIL
  assert(ctx:short() == 0x0a1a) -- MORE TAIL
  return sizet
end

local function generic_list(ctx, f)
  local n = ctx:int()
  local ret = {}
  for i=1,n do
    table.insert(ret, f(ctx))
  end
  return ret
end

local function constant(ctx)
  local type = ctx:byte()
  if type == 0 then
    return nil
  elseif type == 1 then
    return ctx:byte() ~= 0
  elseif type == 3 then
    return ctx:double()
  elseif type == 4 then
    return ctx:string()
  end
end

local function func(ctx)
  local first_line   = ctx:int()
  local last_line    = ctx:int()
  local nparams      = ctx:byte()
  local is_vararg    = ctx:byte()
  local stack_size   = ctx:byte()
  
--  local instructions = generic_list(ctx, function(ctx) return opcode.instruction(reader.int(ctx)) end)
--  local constants    = generic_list(ctx, constant)
--
--  local protos       = generic_list(ctx, func)
--
--  local line_num     = generic_list(ctx, reader.int)
--  local locals       = generic_list(ctx, function(ctx) return setmetatable({ctx:string(), ctx:int(), ctx:int()},
--              {__tostring = function(self) return self[1] end,
--              __eq = function(self, other) return tostring(self) == tostring(other) end}) end)
--  local upvalues     = generic_list(ctx, reader.string)
  
  return {
    first_line   = first_line,
    last_line    = last_line,
    nparams      = nparams,
    is_vararg    = is_vararg,
    stack_size   = stack_size,
  }
end


local ctx = reader.new_reader(string.dump(loadfile 'hello.lua'))

local sizet = header(ctx)

ctx:configure(sizet)
func(ctx)

return {header=header, func=func}