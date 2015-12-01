-- Compiles and loads a piece of lua code
local parser = require 'lua.parser'
local compiler = require 'lua.interpreter'
local dump = require 'bytecode.dump'

local function main(file)
  local tree = parser(io.open(file, 'r'):read('*all'))
  local prototype = compiler(tree)
  local bytecode = dump.dump(prototype)
  local func, err = loadstring(tostring(bytecode))
  if err then
    print("Error during bytecode loading, dumping state...")
    print("Code")
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
    error(err)
  end
  return func, bytecode, prototype, function()
    print("Code")
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
  end
end

return main