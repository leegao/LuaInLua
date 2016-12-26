-- construct the least fixed point of a transfer on some graph
local graph = require "luainlua.common.graph"
local utils = require "luainlua.common.utils"
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
  size="8,5"
]]
  local mt = worklist.solution or {}
  function mt.dot()
    local str = prefix
    if next(graph.accepted, nil) ~= nil then
      str = str .. '  node[shape=doublecircle,label=""];'
      for node in pairs(graph.accepted) do
        str = str .. ' ' .. node
      end
      str = str .. ';\n'
    end
    str = str .. '  node[shape=circle,label=""];\n'
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
  self.partial_solution = solution
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
    local has_pred = false
    for pred in pairs(graph.reverse[x] or {}) do
      has_pred = true
      local this = self:transfer(x, solution[pred], graph, pred)
      new = (new and self:merge(new, this)) or this
    end
    if not has_pred then
      new = self:transfer(x, self:initialize(), graph)
    end
    if new and self:changed(old, new, x) then
      for succ in pairs(graph.forward[x] or {}) do
        table.insert(worklist, succ)
      end
      solution[x] = new
    end
  end
  self.partial_solution = nil
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
    local has_pred = false
    for pred in pairs(graph.forward[x] or {}) do
      has_pred = true
      local this = self:transfer(x, solution[pred], graph, pred)
      new = (new and self:merge(new, this)) or this
    end
    if not has_pred then
      new = self:transfer(x, self:initialize(), graph)
    end
    if new and self:changed(old, new) then
      for succ in pairs(graph.reverse[x] or {}) do
        table.insert(worklist, succ)
      end
      solution[x] = new
    end
  end
  return solution
end

return worklist