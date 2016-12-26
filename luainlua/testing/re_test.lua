local re = require "parsing.re"
local utils = require "common.utils"

local function format_open(open)
  return open[1] .. '(' .. open[2] .. ')'
end

local function visualize(pattern, str)
  local graph = re.compile(pattern)
  local matched, history = graph:match(str)
  return graph:dot(
    function(node, graph)
      local tab = {}
      for i, state in ipairs(history) do
        if state == node then
          table.insert(tab, str:sub(1, i - 1))
        end
      end
      local closure = {}
      if (graph.nodes[node][1]) then
        for k in pairs(graph.nodes[node][1]) do table.insert(closure, k) end
      end
      local groups = table.concat(utils.map(format_open, graph.nodes[node][2]), ', ')
      return '[label="' .. node .. ' {' .. table.concat(tab, ', ') .. '} ' .. groups .. ' [' .. table.concat(closure, ', ') .. ']' .. '"]'
    end,
    function(c, l, r, graph)
      local tab = {}
      for key in pairs(c) do table.insert(tab, key) end
      return table.concat(tab, ', ')
    end)
end
-- Let's get the tokens to a regex parser
print(visualize("//ab?d", "//adasdfsdf\n"))