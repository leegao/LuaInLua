-- See A No-Frills Introduction to Lua 5.1 VM Instructions
-- and http://www.lua.org/source/5.2/lundump.c.html#luaU_undump for changes

local opcode = require "luainlua.bytecode.opcode"
local reader = require "luainlua.bytecode.reader"
local ir = require 'luainlua.bytecode.ir'

local undump = {}

--chunk.sizeof_int = 4
--chunk.sizeof_sizet = 4
--chunk.sizeof_instruction = 4
undump.sizeof_number = 8

local function generic_list(ctx, parser, size)
  local n = ctx:int(size)
  local ret = {}
  for i = 1, n do
    table.insert(ret, parser(ctx))
  end
  return ret
end

local function constant(ctx)
  local type = ctx:byte()

  if type == 0 then
    return {} -- nil
  elseif type == 1 then -- boolean
    return ctx:byte() ~= 0
  elseif type == 3 then
    return ctx:double()
  elseif type == 4 then
    return ctx:string(undump.sizeof_sizet)
  else
    error "Cannot parse constant"
  end
end

function undump.load_header(ctx)
  assert(ctx:int() == 0x61754c1b, "Make sure you're running vanilla Lua 5.2") -- ESC. Lua
  assert(ctx:byte() == 0x52, "Make sure you're running vanilla Lua 5.2") -- version
  assert(ctx:byte() == 0, "Not expecting extensions.") -- format version
  assert(ctx:byte() == 1, "Not expecting big-endianess.") -- little endian
  if not undump.sizeof_int then
    undump.sizeof_int = assert(ctx:byte()) -- sizeof(int)
    undump.sizeof_sizet = assert(ctx:byte()) -- sizeof(size_t)
    undump.sizeof_instruction = assert(ctx:byte()) -- sizeof(Instruction)
  else
    assert(ctx:byte() == undump.sizeof_int) -- sizeof(int)
    assert(ctx:byte() == undump.sizeof_sizet) -- sizeof(size_t)
    assert(ctx:byte() == undump.sizeof_instruction) -- sizeof(Instruction)
  end
  assert(ctx:byte() == undump.sizeof_number) -- sizeof(number)
  assert(ctx:byte() == 0) -- is integer
  assert(ctx:int() == 0x0a0d9319) -- TAIL
  assert(ctx:short() == 0x0a1a) -- MORE TAIL
  return
end


function undump.load_code(ctx)
  local ir = ctx:get_ir()
  local n = ctx:int()
  local instructions = {}
  for i = 1, n do
    local int = ctx:int(undump.sizeof_instruction)
    local instruction = opcode.instruction(ir, int, i)
    local serialized = opcode.serialize(instruction)
    assert(serialized == int, serialized .. ' versus ' .. int)
    table.insert(instructions, instruction)
  end
  return instructions
end

function undump.load_constants(ctx)
  local constants = generic_list(ctx, constant)
  constants.functions = generic_list(ctx, undump.load_function)
  return constants
end

function undump.load_upvalues(ctx)
  return generic_list(
    ctx,
    function(ctx)
      return {instack = ctx:byte(), index = ctx:byte()}
    end
  )
end

function undump.load_debug(ctx)
  local source = ctx:string(undump.sizeof_sizet)
  local lineinfo = generic_list(ctx, function(ctx) return ctx:int() end)
  local locals = generic_list(
    ctx,
    function(ctx)
      return {name = ctx:string(undump.sizeof_sizet), first_pc = ctx:int(), last_pc = ctx:int()}
    end
  )
  local upvalues = generic_list(ctx, function(ctx) return ctx:string(undump.sizeof_sizet) end)
  return {
    source = source,
    lineinfo = lineinfo,
    locals = locals,
    upvalues = upvalues,
  }
end

function undump.load_function(ctx)
  table.insert(ctx.ir_stack, ir())
  local first_line   = ctx:int()
  local last_line    = ctx:int()
  local nparams      = ctx:byte() -- 27
  local is_vararg    = ctx:byte()
  local stack_size   = ctx:byte()
  local code         = undump.load_code(ctx)
  local constants    = undump.load_constants(ctx)
  local upvalues     = undump.load_upvalues(ctx)
  local debug        = undump.load_debug(ctx)

  local ir_context = table.remove(ctx.ir_stack)
  local func = {
    first_line   = first_line,
    last_line    = last_line,
    nparams      = nparams,
    is_vararg    = is_vararg,
    stack_size   = stack_size,
    code         = code,
    constants    = constants,
    upvalues     = upvalues,
    debug        = debug,
    ir_context   = ir_context,
  }
  ir_context:configure(func)
  return func
end

-- Configure the chunk reader for the first time
undump.load_header(reader.new_reader(string.dump(loadstring '')))

function undump.undump(str_or_function)
  local str = str_or_function
  if type(str_or_function) == 'function' then
    str = string.dump(str_or_function)
  end
  assert(type(str) == 'string', "You can only undump functions or bytecode")
  local ctx = reader.new_reader(str)
  ctx:configure(undump.sizeof_int)
  ctx.ir_stack = {}
  function ctx:get_ir()
    return self.ir_stack[#self.ir_stack]
  end
  undump.load_header(ctx) -- verify
  local func = undump.load_function(ctx)
  assert(ctx[2] > #ctx[1], "There is some extra data left inside the bytecode.")
  -- TODO: Verify bytecode
  return func
end

return undump