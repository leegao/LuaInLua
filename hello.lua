local re = require "re"

print "Hello World"

local function visualize(pattern, str)
  local graph = re.compile(pattern)
  local matched, history = re.match(graph, str)
  return graph:dot(function(graph, node)
    local tab = {}
    for i, state in ipairs(history) do
      if state == node then
        table.insert(tab, str:sub(1, i - 1))
      end
    end
    return '[label="' .. table.concat(tab, ', ') .. '"]'
  end)
end

print(visualize("(ab|f+k+)*", "abfffkkabab"))