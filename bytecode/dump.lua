local dump = {}

local undump = require "bytecode.undump" -- needed for sizet info
local opcode = require "bytecode.opcode"
local writer = require "bytecode.writer"
local ir = require 'bytecode.ir'
local utils = require 'common.utils'
local parser = require 'lua.parser'
local compiler = require 'lua.interpreter'

--undump.sizeof_int = ?
--undump.sizeof_sizet = ?
--undump.sizeof_instruction = ?
--undump.sizeof_number = 8

local function generic_list(ctx, list, serializer, size)
  local n = #list
  local out = ctx.writer
  out:int(n, size)
  for object in utils.loop(list) do
    serializer(ctx, object)
  end
end

function dump.dump_code(ctx, code)
  local out = ctx.writer
  generic_list(
    ctx,
    code,
    function(ctx, instruction)
      out:int(opcode.serialize(instruction), undump.sizeof_instruction)
    end)
end

function dump.dump_constants(ctx, constants)
  local out = ctx.writer
  generic_list(
    ctx,
    constants,
    function(_, object)
      local t = type(object)
      if t == 'number' then
        out:byte(3)
        out:double(object)
      elseif t == 'boolean' then
        out:byte(1)
        out:byte(object and 1 or 0)
      elseif t == 'string' then
        out:byte(4)
        out:string(object, undump.sizeof_sizet)
      else
        out:byte(0)
      end
    end)
  generic_list(ctx, constants.functions, dump.dump_function)
end

function dump.dump_upvalues(ctx, upvalues)
  local out = ctx.writer
  generic_list(
    ctx,
    upvalues,
    function(_, upvalue) out:byte(upvalue.instack):byte(upvalue.index) end)
end

function dump.dump_debug(ctx, debug)
  local out = ctx.writer
  out:string("" or debug.source or "", undump.sizeof_sizet) -- debug.source
  generic_list(ctx, {} or debug.lineinfo or {}, function(_, info) out:int(info) end)
  generic_list(
    ctx,
    {} or debug.locals or {},
    function(_, object) out:string(object.name, undump.sizeof_sizet):int(object.first_pc):int(object.last_pc) end)
  generic_list(ctx, {} or debug.upvalues or {}, function(_, name) out:string(name, undump.sizeof_sizet) end)
end

function dump.dump_header(ctx)
  local out = ctx.writer
  out:int(0x61754c1b)
     :byte(0x52)
     :byte(0)
     :byte(1)
     :byte(undump.sizeof_int)
     :byte(undump.sizeof_sizet)
     :byte(undump.sizeof_instruction)
     :byte(undump.sizeof_number)
     :byte(0)
     :int(0x0a0d9319)
     :short(0x0a1a)
end

function dump.dump_function(ctx, closure)
  local out = ctx.writer
  out:int(1 or closure.first_line)
  out:int(1 or closure.last_line)
  out:byte(closure.nparams)
  out:byte(closure.is_vararg and 0 or 1)
  out:byte(100) -- closure.stack_size
  dump.dump_code(ctx, closure.code)
  dump.dump_constants(ctx, closure.constants)
  dump.dump_upvalues(ctx, closure.upvalues)
  dump.dump_debug(ctx, closure.debug)
end


local tree = parser[[
  -- local a = 3
  print(3)
]]
local compiler = require 'lua.interpreter'
local prototype = compiler(tree)
for pc, op in ipairs(prototype.code) do
  print(pc, op)
end
print("Constants")
for id, const in ipairs(prototype.constants) do
  print(id, const)
end
print("Upvalues")
for id, up in ipairs(prototype.upvalues) do
  print(id, up.instack, up.index)
end
print()
local original = string.dump(function() print(3) end)
local original_prototype = undump.undump(original)
for pc, op in ipairs(original_prototype.code) do
  print(pc, op)
end
print("Constants")
for id, const in ipairs(original_prototype.constants) do
  print(id, const)
end
print("Upvalues")
for id, up in ipairs(original_prototype.upvalues) do
  print(id, up.instack, up.index)
end
--
--local prototype = undump.undump(original)

local ctx = {writer = writer.new_writer()}
ctx.writer:configure(undump.sizeof_int)
dump.dump_header(ctx)
dump.dump_function(ctx, prototype)
original = tostring(ctx.writer)

local ctx = {writer = writer.new_writer()}
ctx.writer:configure(undump.sizeof_int)
dump.dump_header(ctx)
dump.dump_function(ctx, original_prototype)

local foo = loadstring(tostring(original))
print(foo)

local new = tostring(ctx.writer)
for i = 1, math.max(#original, #new) do
  print(i, original:byte(i), new:byte(i), original:byte(i) == new:byte(i))
end

print(original == new)

print()
prototype = undump.undump(tostring(ctx.writer))
for pc, op in ipairs(prototype.code) do
  print(pc, op)
end
print("Constants")
for id, const in ipairs(prototype.constants) do
  print(id, const)
end
print("Upvalues")
for id, up in ipairs(prototype.upvalues) do
  print(id, up.instack, up.index)
end
print()

foo()
return dump