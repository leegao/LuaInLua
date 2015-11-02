-- LL1 parser, which is somewhat limited :'(

local ll1 = {}

local utils = require 'utils'
local graph = require 'graph'
local worklist = require 'worklist'

local nonterminals = {}
local configurations = {}

local EPS = ''
local EOF = 256
local ERROR = -1

local function get_nonterminal(configuration, variable)
  if variable:sub(1, 1) == '$' then
    return configuration[variable:sub(2)]
  end
  return
end

local function get_terminals_from(configuration)
  local terminals = {}
  for variable, productions in pairs(configuration) do
    for production in utils.loop(productions) do
      for terminal in utils.loop(production) do
        if terminal ~= EPS and terminal ~= EOF then
          terminals[terminal] = true
        end
      end
    end
  end
  terminals[EOF] = true
  return terminals
end

local function first(configuration, production)
  local first_set = {}
  for _, token in ipairs(production) do
    -- check if token is a nonterminal or not
    local nonterminal = get_nonterminal(configuration, token)
    local is_nullable = false
    if nonterminal then
      -- let's get the first set there
      local local_first_set = nonterminal:first(configuration)
      if local_first_set[EPS] then
        is_nullable = true
        local_first_set[EPS] = nil
      end
      for local_token in pairs(local_first_set) do
        first_set[local_token] = true
      end
    else
      -- let's see if token is nullable
      if token == EPS then
        is_nullable = true
      else
        first_set[token] = true
      end
    end
    if not is_nullable then
      return first_set
    end
  end
  first_set[EPS] = true
  return first_set
end

function nonterminals:first(configuration)
  local first_set = {}
  for _, production in ipairs(self) do
    local local_first_set = first(configuration, production)
    for token in pairs(local_first_set) do
      first_set[token] = true
    end
  end
  return first_set
end

function configurations:uses(x)
  -- returns set of {variable, suffix_production} such that
  -- y -> \alpha $x \beta, then return {$y, \beta} or {$y, ''}
  local uses = {}
  for y, nonterminal in pairs(self) do
    for _, production in ipairs(nonterminal) do
      for i, object in ipairs(production) do
        if object == x then
          local suffix = utils.sublist(production, i + 1)
          table.insert(uses, {'$' .. y, suffix})
        end
      end
    end
  end
  return uses
end

function nonterminals:dependency(graph, configuration)
  if graph.nodes[self.variable:sub(2)] then
    return graph
  end
  local uses = configuration:uses(self.variable)
  for variable, suffix in utils.uloop(uses) do
    get_nonterminal(configuration, variable):dependency(graph, configuration)
    local first_set = first(configuration, suffix)
    setmetatable(
      first_set, 
      {__tostring = function(self) return table.concat(self, ', ') end})
    graph:edge(variable:sub(2), self.variable:sub(2), first_set)
  end
  return graph
end

local follow_algorithm = worklist {
  -- what is the domain? Sets of tokens
  initialize = function(self, node, _)
    if node == 'root' then return {[EOF] = true} end
    return {}
  end,
  transfer = function(self, node, follow_pred, graph, pred)
    local follow_set = self:initialize(node)
    follow_set = self:merge(follow_set, graph.forward[pred][node])
    if follow_set[EPS] then
      follow_set = self:merge(follow_set, follow_pred)
    end
    return follow_set
  end,
  changed = function(self, old, new)
    -- assuming monotone in the new direction
    for key in pairs(new) do
      if not old[key] then
        return true
      end
    end
    return false
  end,
  merge = function(self, left, right)
    local merged = utils.copy(left)
    for key in pairs(right) do
      merged[key] = true
    end
    return merged
  end,
  tostring = function(self, graph, node, input)
    local list = {}
    for key in pairs(input) do table.insert(list, key) end
    return node .. ' ' .. table.concat(list, ',')
  end
}

local yacc = {}

function ll1.yacc(actions)
  -- Associate the correct set of metatables to the nonterminals
  local configuration = {}
  for variable, productions in pairs(actions) do
    setmetatable(productions, {__index = nonterminals})
    productions.variable = '$' .. variable
    configuration[variable] = productions
  end
  setmetatable(configuration, {__index = configurations})
  
  local dependency_graph = graph.create()
  local first_sets = {}
  for variable, nonterminal in pairs(configuration) do
    first_sets[variable:sub(2)] = nonterminal:first(configuration)
    nonterminal:dependency(dependency_graph, configuration)
  end
  local follow_sets = follow_algorithm:forward(dependency_graph)
  local terminals = get_terminals_from(configuration)
  local transition_table = {}
  
  for variable in pairs(configuration) do
    transition_table[variable] = {}
    for terminal in pairs(terminals) do
      transition_table[variable][terminal] = ERROR
    end
  end
  
  for variable, productions in pairs(configuration) do
    for production in utils.loop(productions) do
      local firsts = first(configuration, production)
      for terminal in pairs(firsts) do
        if terminal ~= EPS and terminal ~= EOF then
          if transition_table[variable][terminal] ~= ERROR then 
            print(variable, terminal, table.concat(transition_table[variable][terminal], ', '))
          else
            transition_table[variable][terminal] = production
          end
        end
      end
      if firsts[EPS] then
        local follows = follow_sets[variable]
        for terminal in pairs(firsts) do
          if terminal ~= EPS and terminal ~= EOF then
            if transition_table[variable][terminal] ~= ERROR then 
              print(variable, terminal, table.concat(transition_table[variable][terminal], ', '))
            else
              transition_table[variable][terminal] = production
            end
          end
        end
      end
    end
  end
  
  setmetatable(transition_table, {__index = yacc})
  
  return transition_table
end

local function consume(tokens)
  return table.remove(tokens, 1)
end
local function peek(tokens)
  return tokens[1]
end
local function enqueue(tokens, item)
  table.insert(tokens, 1, item)
end

function yacc:parse(tokens, state)
  if not state then state = 'root' end
  local token = peek(tokens)
  local production = self[state][token]
  local args = {}
  for node in utils.loop(production) do
    if node:sub(1, 1) == '$' then
      local ret = self:parse(tokens, node:sub(2))
      table.insert(args, ret)
    else
      local token = consume(tokens)
      assert(node == token)
      table.insert(args, token)
    end
  end
  return production.action(unpack(args))
end

local ignore = function(...) return end
local id = function(...) return {...} end

-- expr = $consts | identifier | fun $x -> $expr
-- consts = number | string | true | false
local parser = ll1.yacc {
  root = {
    {'$expr', action = id},
  },
  expr = {
    {'$consts', action = id},
    {'identifier', action = id},
    {'fun', 'identifier', '->', '$expr', action = id},
  },
  consts = {
    {'number', action = id},
    {'string', action = id},
    {'true', action = id},
    {'false', action = id},
  }
}

local tree = parser:parse{"fun", "identifier", "->", "fun", "identifier", "->", "identifier"}

return ll1