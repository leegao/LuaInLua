local re = require "re"
local utils = require "utils"

print "Hello World"

local function format_open(open)
  print(open)
  return open[1] .. '(' .. open[2] .. ')'
end

local function visualize(pattern, str)
  local graph = re.compile(pattern)
  local matched, history = re.match(graph, str)
  return graph:dot(
    function(node, graph)
      local tab = {}
      for i, state in ipairs(history) do
        if state == node then
          table.insert(tab, str:sub(1, i - 1))
        end
      end
      local groups = table.concat(utils.map(format_open, graph.nodes[node][2]), ', ')
      return '[label="' .. node .. ' {' .. table.concat(tab, ', ') .. '} ' .. groups .. '"]'
    end,
    function(c, l, r, graph)
      local tab = {}
      for key in pairs(c) do table.insert(tab, key) end
      return table.concat(tab, ', ')
    end)
end

-- Let's get the tokens to a regex parser
print(visualize(".+(a).+", "(a|b|cc.+)*"))