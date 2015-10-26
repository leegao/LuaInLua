-- construct the least fixed point of a transfer on some graph
local graph = require "graph"
local worklist = {}

function worklist.transfer_edge(self, left, right, tag)
  error "transfer_edge unimplemented"
end

function worklist.transfer_node(self, node, tag)
  error "transfer_node unimplemented"
end

function worklist.merge(self, state_left, state_right)
  error "merge unimplemented"
end

function worklist.initialize(self, node, tag)
  error "initialize unimplemented"
end

function worklist.create(self, graph)
  local w = {}
  setmetatable(w, {__index = worklist})
  return w
end
setmetatable(worklist, {__call = worklist.create})

return worklist