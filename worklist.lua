-- construct the least fixed point of a transfer on some graph
local graph = require "graph"
local utils = require "utils"
local worklist = {}

function worklist.transfer(self, node, input, graph, pred)
  error "transfer is unimplemented"
end

function worklist.merge(self, left, right)
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

local function new_solution(worklist, graph)
  local solution = {}
  local prefix = [[digraph {
  rankdir=LR;
  size="3"
  node[shape=circle,label=""];
]]
  local mt = worklist.solution or {}
  function mt.dot()
    local str = prefix
    for node in graph:vertices() do
      local label = (solution[node] and worklist:tostring(graph, node, solution[node])) or ''
      str = str .. '  ' .. tostring(node) .. '[label="' .. label .. '"];\n'
    end
    for l, r, c in graph:edges() do
      local label = (c ~= true and tostring(c)) or ''
      str = str .. '    ' .. l .. ' -> ' .. r .. '[label="' .. label .. '"];\n'
    end
    return str .. '}'
  end
  setmetatable(solution, {__index = mt})
  return solution
end

function worklist.forward(self, graph)
  local solution = new_solution(self, graph)
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
      local this = self:transfer(x, solution[pred], graph, pred)
      new = (new and self:merge(new, this)) or this
    end
    if new and self:changed(old, new) then
      for succ in pairs(graph.forward[x]) do
        table.insert(worklist, succ)
      end
      solution[x] = new
    end
  end
  return solution
end

function worklist.reverse(self, graph)
  local solution = new_solution(self, graph)
  for node, tag in graph:vertices() do
    solution[node] = self:initialize(node, tag)
  end
  local worklist = {}
  for node in graph:reverse_dfs() do
    table.insert(worklist, node)
  end
  
  while #worklist ~= 0 do
    local x = table.remove(worklist, 1)
    local tag = graph.nodes[x]
    local old = utils.copy(solution[x])
    local new = nil
    for pred in pairs(graph.forward[x]) do
      local this = self:transfer(x, solution[pred], graph, pred)
      new = (new and self:merge(new, this)) or this
    end
    if new and self:changed(old, new) then
      for succ in pairs(graph.reverse[x]) do
        table.insert(worklist, succ)
      end
      solution[x] = new
    end
  end
  return solution
end

return worklist