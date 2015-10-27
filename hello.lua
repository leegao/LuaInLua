local re = require "re"

print "Hello World"

local g = re.compile("%d3|2x")
local lol = "43"
local matched, history = re.match(g, lol)
print(g:dot(function(graph, node)
  local str = {}
  for i, state in ipairs(history) do
    if state == node then
      table.insert(str, lol:sub(1, i - 1))
    end
  end
  return '[label="' .. table.concat(str, ', ') .. '"]'
end))