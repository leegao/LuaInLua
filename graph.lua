-- graph datastructure
-- For now, let's just go with tagged nodes and edges, with some helper functions for 
-- forward and reverse traversal

local graph = {}
graph.__index = graph

function graph.create()
  local g = {
    nodes = {},
    forward = {},
    reverse = {}
  }
  setmetatable(g, graph)
  return g
end

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
  if tag == nil then tag = true end
  if not self.forward[left[1]][right[1]] then 
    self.forward[left[1]][right[1]] = tag
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

function graph.dfs(self, start)
  local solution = {}
  dfs(self, start, {}, solution)
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

local g = graph.create()
g:edge(1, 2)
g:edge(1, 3)
g:edge(2, 3)
g:edge(2, 4)
g:edge(3, 5)
for node, tag, forward, reverse in g:reverse_dfs() do
  print(node, tag, forward)
end

print(table.unpack(g:exits()))
print(table.unpack(g:entrances()))

return graph