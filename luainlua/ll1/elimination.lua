-- 3 steps: remove nullables, remove all cycles, and finally remove immediate left recursion

local left_recursion_elimination = {}

local ll1 = require 'luainlua.ll1.ll1'
local utils = require 'luainlua.common.utils'
local graph = require 'luainlua.common.graph'
local worklist = require 'luainlua.common.worklist'

local function hash(production)
  return table.concat({unpack(production)}, '`')
end

local function normalize(production)
  local new = {}
  for object in utils.loop(production) do
    if object ~= '' then
      table.insert(new, object)
    end
  end
  return new
end

local function null_out(production, i, nullable_indices)
  local new = {unpack(production)}
  local changed = {}
  local index = 1
  while true do
    local okay = i % 2 == 0
    
    if okay then
      new[nullable_indices[index]] = ''
      table.insert(changed, nullable_indices[index])
    end
    
    i = math.floor(i / 2)
    if i == 0 then break end
    index = index + 1
  end
  return normalize(new)
end

local function insert_into(new_nonterminal, production, production_hashes)
  local h = hash(production)
  if not production_hashes[h] and #production ~= 0 then
    table.insert(new_nonterminal, production)
    production_hashes[h] = true
  end
end

local function eliminate_nullables(configuration)
  local nullables = {}
  for variable, nonterminal in pairs(configuration) do
    local first_set = configuration:first(variable)
    if first_set[''] then
      nullables['$' .. variable] = true
    end
  end
  
  local new_actions = {}
  for variable, nonterminal in pairs(configuration) do
    -- let's construct a hashset of the original productions
    local seen_productions = {}
    for production in utils.loop(nonterminal) do
      seen_productions[hash(production)] = true
    end
    
    -- let's compute the null-eliminated expansion
    local new_nonterminal = {}
    local production_hashes = {}
    for production in utils.loop(nonterminal) do
      local action = production.action
      local nullable_indices = {}
      for i, object in ipairs(production) do
        if nullables[object] then
          table.insert(nullable_indices, i)
        end
      end
      if #nullable_indices ~= 0 then
        -- compute the combinatorial transfer to naturals
        for i=0,2^#nullable_indices - 1 do
          local new_production, changed = null_out(production, i, nullable_indices)
          insert_into(new_nonterminal, new_production, production_hashes)
        end
      else
        insert_into(new_nonterminal, normalize(production), production_hashes)
      end
    end
    new_actions[variable] = new_nonterminal
    assert(#new_nonterminal ~= 0)
  end
  return ll1.configure(new_actions)
end

local function full_dependency_graph(configuration)
  -- find all forms of X -> Y
  local g = graph()
  g.configuration = configuration
  for variable, nonterminal in pairs(configuration) do
    for production in utils.loop(nonterminal) do
      for object in utils.loop(production) do
        if object:sub(1,1) == '$' then
          g:edge(object:sub(2), variable)
          g:edge(variable, object:sub(2))
        end
      end
    end
  end
  g:set_root('root')
  return g
end

-- computes the set of productions that A =*> goes to
local transitive_algorithm = worklist {
  -- what is the domain? Sets of productions
  initialize = function(self, _, _)
    return {}
  end,
  transfer = function(self, node, _, graph, pred)
    local transitive_set = self:initialize(node)
    local nonterminal = graph.configuration[node]
    local single_set = {}
    for production in utils.loop(nonterminal) do
      transitive_set[hash(production)] = production
      if #production == 1 and production[1]:sub(1, 1) == '$' then
        transitive_set = self:merge(
            transitive_set, 
            self.partial_solution[production[1]:sub(2)])
      end
    end
    return transitive_set
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
      merged[key] = right[key]
    end
    return merged
  end,
  tostring = function(self, _, node, input)
    local list = {}
    for key in pairs(input) do table.insert(list, key) end
    return node .. ' -> ' .. table.concat(list, ' | ')
  end
}

local function eliminate_cycles(configuration)
  local use_graph = full_dependency_graph(configuration)
  local transitive_set = transitive_algorithm:forward(use_graph)
  local cycle_set = {}
  for variable, transitionable in pairs(transitive_set) do
    if transitionable['$' .. variable] then
      cycle_set[variable] = true
    end
  end
  local noncyclic_set = {}
  for key, map in pairs(transitive_set) do
    noncyclic_set[key] = utils.kfilter(function(k, v) return not cycle_set[k:sub(2)] end, map)
  end
  
  local new_actions = {}
  for variable, nonterminal in pairs(configuration) do
    if variable ~= 'root' then
      -- look for productions that are exactly $Cyclic
      local productions_map = {}
      for production in utils.loop(nonterminal) do
        if #production == 1 and production[1]:sub(1, 1) == '$' then
          local other = production[1]:sub(2)
          if cycle_set[other] then
            for h, other_production in pairs(noncyclic_set[other]) do
              productions_map[h] = other_production
            end
          else
            productions_map[hash(production)] = production
          end
        else
          productions_map[hash(production)] = production
        end
      end
      new_actions[variable] = {}
      for _, production in pairs(productions_map) do
        table.insert(new_actions[variable], production)
      end
    else
      new_actions[variable] = nonterminal
    end
  end
  return ll1.configure(new_actions)
end

local function immediate_elimination(nonterminal)
  local variable = nonterminal.variable
  local new_variable = variable .. "'new"
  local recursive = {{''}, variable = new_variable}
  local other = {variable = variable}
  for production in utils.loop(nonterminal) do
    local local_production = utils.copy(production)
    print('\t', variable, utils.to_string(production))
    if local_production[1] == variable then
      assert(variable == table.remove(local_production, 1))
      table.insert(local_production, new_variable)
      table.insert(recursive, local_production)
    else
      table.insert(local_production, new_variable)
      table.insert(other, local_production)
    end
  end
  if #recursive == 1 then
    return nil
  else
    return other, recursive
  end
end

local function indirect_elimination(configuration)
  local actions = utils.copy(configuration)
  local variables = {}
  for node in configuration:get_dependency_graph():dfs() do table.insert(variables, node) end
  for i = 1,#variables do
    local old_left = actions[variables[i]]
    local new_left = utils.copy(old_left)
    local to_remove = {}
    for j = 1, #variables do
      if i ~= j then 
        local old_right = actions[variables[j]]
        -- find some production of the form A_i := A_j \gamma
        for k, production in ipairs(old_left) do
          if production[1] == '$' .. variables[j] then
            -- expand A_j out
            print(variables[i], variables[j], utils.to_string(production))
            for production_j in utils.loop(old_right) do
              local new_i_k = utils.copy(production_j)
              for l = 2, #production do
                table.insert(new_i_k, production[l])
              end
              table.insert(new_left, new_i_k)
              to_remove[k] = true
            end
          end
        end
      end
    end
    local needs_removing = {}
    for k in pairs(to_remove) do table.insert(needs_removing, k) end
    table.sort(needs_removing, function(a,b) return b > a end)
    for j in utils.loop(needs_removing) do
      print(j)
      table.remove(new_left, j)
    end
    -- rewrite A[i] 
    local normal, recursive = immediate_elimination(new_left)
    if normal then
      actions[variables[i]] = normal
      actions[recursive.variable:sub(2)] = recursive
    else
      actions[variables[i]] = new_left
    end
  end
  return ll1.configure(actions)
end

local function direct_factor_elimination(nonterminal)
  -- eliminate A -> a \gamma_1 | a \gamma_2 | ... a \gamma_n into
  -- A -> a $A'factored | \gamma_{n+1}
  -- A'factor#1 -> \gamma_1 | \gamma_2 | ... | \gamma_n
  -- we need to keep doing this until we hit a fixed point
  local action = {variable = nonterminal.variable}
  local new_variables = {}
  local variable = nonterminal.variable
  -- step 1: compute frequency table of common prefixes
  local prefix_freq = {}
  for i, production in ipairs(nonterminal) do
    if not prefix_freq[production[1]] then prefix_freq[production[1]] = {} end
    table.insert(prefix_freq[production[1]], i)
  end
  -- step 2: compute replacement table
  local replacement_id = 1
  for prefix, frequencies in pairs(prefix_freq) do
    if #frequencies == 1 then
      table.insert(action, nonterminal[frequencies[1]])
    else
      -- create a new variable
      local new_variable = variable .. '\'factor#' .. replacement_id
      local new_nonterminal = {variable = new_variable}
      replacement_id = replacement_id + 1
      for id in utils.loop(frequencies) do
        local new_production = utils.sublist(nonterminal[id], 2)
        if #new_production == 0 then new_production[1] = '' end
        table.insert(new_nonterminal, new_production)
      end
      table.insert(new_variables, new_nonterminal)
      table.insert(action, {prefix, new_variable})
    end
  end
  return action, new_variables
end

local function left_factor_elimination(configuration)
  local has_changes = false
  local actions = utils.copy(configuration)
  for variable, nonterminal in pairs(configuration) do
    local action, new_variables = direct_factor_elimination(nonterminal)
    if #new_variables ~= 0 then
      has_changes = true
      actions[action.variable:sub(2)] = action
      for new in utils.loop(new_variables) do
        actions[new.variable:sub(2)] = new
      end
    end
  end
  if has_changes then
    return left_factor_elimination(actions)
  end
  return ll1.configure(actions)
end

--[[--
-- testing
local configuration = ll1.configure {
  root = {
    {'$expr', action = id},
  },
  base = {
    {'consts', action = id},
    {'(', '$expr', ')', action = id},
  },
  expr = {
    {'$base'},
    {'$base', '+', '$expr'},
    {'$base', '$expr'},
    {'fun', 'identifier', '->', '$expr', action = id},
  },
}

local new_configuration = eliminate_nullables(configuration)
print(new_configuration:pretty())
new_configuration = eliminate_cycles(new_configuration)
print(new_configuration:pretty())
new_configuration = indirect_elimination(new_configuration)
print(new_configuration:pretty())
new_configuration = left_factor_elimination(new_configuration)
print(new_configuration:pretty())

ll1(new_configuration)
print(new_configuration:firsts():dot())
print(new_configuration:follows():dot())
--]]-- 

left_recursion_elimination.eliminate_nullables = eliminate_nullables
left_recursion_elimination.eliminate_cycles = eliminate_cycles
left_recursion_elimination.immediate_elimination = immediate_elimination
left_recursion_elimination.indirect_elimination = indirect_elimination
left_recursion_elimination.left_factor_elimination = left_factor_elimination
return left_recursion_elimination