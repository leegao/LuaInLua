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
        out:string(object)
      else
        out:byte(0)
      end
    end)
  generic_list(ctx, constants.functions, dump.dump_function)
end

function dump.dump_function(ctx, closure)
  local out = ctx.writer
  out:int(closure.first_line)
  out:int(closure.last_line)
  out:byte(closure.nparams)
  out:byte(closure.is_vararg and 1 or 0)
  dump.dump_code(ctx, closure.code)
  dump.dump_constants(ctx, closure.constants)
--  dump.dump_upvalues(ctx, closure.upvalues)
--  dump.dump_debug(ctx, closure.debug)
end

local ctx = {writer = writer.new_writer()}
ctx.writer:configure(undump.sizeof_int)
local tree = parser[[
  function hello(world)
    return "Hello " .. world
  end
  print(hello("World?"))
]]
local compiler = require 'lua.interpreter'
local prototype = compiler(tree)

dump.dump_function(ctx, prototype)

return dump