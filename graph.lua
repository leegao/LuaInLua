-- graph datastructure
-- For now, let's just go with tagged nodes and edges, with some helper functions for 
-- forward and reverse traversal

local graph = {}
graph.__index = graph

function graph.create()
  local g = {
    nodes = {},
    forward = {},
    reverse = {},
    accepted = {},
    forward_tags = {}
  }
  setmetatable(g, graph)
  return g
end
setmetatable(graph, {__call = graph.create})

function graph.vertex(self, node, tag)
  if not self.nodes[node] then
    self.nodes[node] = tag
  end
  return self
end

function graph.edge(self, left, right, tag)
  if type(left) ~= 'table' then left = {left, true} end
  if type(right) ~= 'table' then right = {right, true} end
  self:vertex(unpack(left))
  self:vertex(unpack(right))
  if not self.forward[left[1]] then self.forward[left[1]] = {} end
  if not self.forward[right[1]] then self.forward[right[1]] = {} end
  if not self.reverse[left[1]] then self.reverse[left[1]] = {} end
  if not self.reverse[right[1]] then self.reverse[right[1]] = {} end
  if not self.forward_tags[left[1]] then self.forward_tags[left[1]] = {} end
  if tag == nil then tag = true end
  if not self.forward[left[1]][right[1]] then 
    self.forward[left[1]][right[1]] = tag
    if not self.forward_tags[left[1]][tag] then self.forward_tags[left[1]][tag] = {} end
    table.insert(self.forward_tags[left[1]][tag], right[1])
    self.reverse[right[1]][left[1]] = tag
  end
  return self
end

-- returns an iterator for each node, its actions, and a map of forward and reverse transitions
function graph.vertices(self)
  local node, tag = next(self.nodes, nil)
  return function()
    local forward = self.forward[node]
    local reverse = self.reverse[node]
    local value = {node, tag, forward, reverse}
    node, tag = next(self.nodes, node)
    return table.unpack(value)
  end
end

local function dfs(self, start, seen, solution)
  if seen[start] then
    return
  end
  table.insert(solution, start)
  seen[start] = true
  for child in pairs(self.forward[start]) do
    dfs(self, child, seen, solution)
  end
end

function graph.dfs(self, ...)
  local starts = {...}
  if next(starts, nil) == nil then
    starts = self:entrances()
  end
  local solution = {}
  local seen = {}
  for _, start in ipairs(starts) do
    dfs(self, start, seen, solution)
  end
  local i = 1
  return function()
    local node = solution[i]
    local tag = self.nodes[node]
    local forward = self.forward[node]
    local reverse = self.reverse[node]
    local value = {node, tag, forward, reverse}
    i = i + 1
    return table.unpack(value)
  end
end

local function reverse_dfs(self, start, seen, solution)
  if seen[start] then
    return
  end
  table.insert(solution, start)
  seen[start] = true
  for child in pairs(self.reverse[start]) do
    reverse_dfs(self, child, seen, solution)
  end
end

function graph.reverse_dfs(self, ...)
  local starts = {...}
  if next(starts, nil) == nil then
    starts = self:exits()
  end
  local solution = {}
  local seen = {}
  for _, start in ipairs(starts) do
    reverse_dfs(self, start, seen, solution)
  end
  local i = 1
  return function()
    local node = solution[i]
    local tag = self.nodes[node]
    local forward = self.forward[node]
    local reverse = self.reverse[node]
    local value = {node, tag, forward, reverse}
    i = i + 1
    return table.unpack(value)
  end
end

function graph.exits(self)
  local exits = {}
  for node, _, forward in self:vertices() do
    if next(forward) == nil then
      table.insert(exits, node)
    end
  end
  return exits
end

function graph.entrances(self)
  local entrances = {}
  for node, _, _, reverse in self:vertices() do
    if next(reverse) == nil then
      table.insert(entrances, node)
    end
  end
  return entrances
end

function graph.edges(self)
  local first = next(self.forward, nil)
  local second = first and next(self.forward[first], nil)
  local function continue()
    if not first then
      return
    end
    if second then
      second = next(self.forward[first], second)
    else
      first = next(self.forward, first)
      second = first and next(self.forward[first], nil)
    end
  end
  return function()
    -- left, right, tag
    while (first or second) and not (first and second) do
      continue()
    end
    if not first and not second then
      return
    end
    local ret = {first, second, self.forward[first][second]}
    continue()
    return unpack(ret)
  end
end

function graph.dot(self, format)
  if not format then format = function() return '' end end
  -- collect all of the vertices
  --[[
  digraph {
    rankdir=LR;
    size="2,10"
    node [shape=doublecircle]; 2;
    node [shape=circle,label=""];
    1 [label=""];
    1 -> 2[label="1"];
  }
  --]]
  local str = [[digraph {
  rankdir=LR;
  size="8,5"
]]
  if next(self.accepted, nil) ~= nil then
    str = str .. '  node[shape=doublecircle,label=""];'
    for node in pairs(self.accepted) do
      str = str .. ' ' .. node
    end
    str = str .. ';\n'
  end
  str = str .. '  node[shape=circle,label=""];\n'
  for node in pairs(self.nodes) do
    str = str .. '  ' .. node .. format(self, node) .. ';\n'
  end
  for l, r, c in self:edges() do
    local label = (c ~= true and tostring(c)) or ''
    str = str .. '  ' .. l .. ' -> ' .. r .. '[label="' .. label .. '"];\n'
  end
  return str .. '}'
end

return graph