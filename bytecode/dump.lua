local dump = {}

local undump = require "bytecode.undump" -- needed for sizet info
local opcode = require "bytecode.opcode"
local writer = require "bytecode.writer"
local ir = require 'bytecode.ir'
local parser = require 'lua.parser'
local compiler = require 'lua.interpreter'

--undump.sizeof_int = ?
--undump.sizeof_sizet = ?
--undump.sizeof_instruction = ?
--undump.sizeof_number = 8

function dump.dump_function(ctx, closure)
  local out = ctx.writer
  out:int(closure.first_line)
  out:int(closure.last_line)
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