-- construct the least fixed point of a transfer on some graph
local graph = require "graph"
local worklist = {}

function worklist.transfer(self, node, input, tag, pred)
  error "transfer is unimplemented"
end

function worklist.merge(self, state_left, state_right)
  error "merge is unimplemented"
end

function worklist.initialize(self, node, tag)
  error "initialize is unimplemented"
end

function worklist.changed(self, old, new)
  error "changed is unimplemented"
end

function worklist.create(self, instance)
  setmetatable(instance, {__index = worklist})
  return instance
end
setmetatable(worklist, {__call = worklist.create})

function worklist.forward(self, graph)
  local solution = {}
  for node, tag in graph:vertices() do
    solution[node] = self:initialize(node, tag)
  end
  local worklist = {}
  for node in graph:dfs() do
    table.insert(worklist, node)
  end
  
  while #worklist ~= 0 do
    local x = table.remove(worklist, 1)
    local tag = graph.nodes[x]
    local old = solution[x]
    local new = nil
    for pred in pairs(graph.reverse[x]) do
      local this = self:transfer(x, solution[pred], tag, pred)
      new = (new and self:merge(new, this)) or this
    end
  end
end

w = worklist {
  initialize = function(self, node, tag)
    return {node = true}
  end
}

g = graph()
g:edge(1, 2)
g:edge(2, 3)
g:edge(1, 4)
w:forward(g)

return worklist