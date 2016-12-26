-- LL1 parser, which is somewhat limited :'(

local ll1 = {}

local utils = require 'luainlua.common.utils'
local graph = require 'luainlua.common.graph'
local worklist = require 'luainlua.common.worklist'

local nonterminals = {}
local configurations = {}

local EPS = ''
local EOF = '$$EOF$$'
local ERROR = -1

-- computes the first sets of nonterminals
local first_algorithm = worklist {
  -- what is the domain? Sets of tokens
  initialize = function(self, _, _)
    return {}
  end,
  transfer = function(self, node, _, graph, pred)
    local first_set = self:initialize(node)
    local configuration = graph.configuration
    local nonterminals = configuration[node]
    if not nonterminals then
      error(("Variable $%s does not exist."):format(node))
    end
    for production in utils.loop(nonterminals) do
      local nullable = true
      for object in utils.loop(production) do
        if object:sub(1, 1) == '$' then
          local partial_first_set = utils.copy(self.partial_solution[object:sub(2)])
          local eps = partial_first_set[EPS]
          partial_first_set[EPS] = nil
          first_set = self:merge(first_set, partial_first_set)
          if not eps then 
            nullable = false
            break 
          end
        else
          if object ~= EPS then 
            first_set[object] = true
            nullable = false
            break
          end
        end
      end
      if nullable then
        first_set[EPS] = true
      end
    end
    return first_set
  end,
  changed = function(self, old, new, x)
    -- assuming monotone in the new direction
    -- print(utils.to_list(old), utils.to_list(new))
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
  tostring = function(self, _, node, input)
    local list = {}
    for key in pairs(input) do table.insert(list, key) end
    return node .. ' ' .. table.concat(list, ',')
  end
}

local follow_algorithm = worklist {
  -- what is the domain? Sets of tokens
  initialize = function(self, node, _)
    if node == 'root' then return {[EOF] = true} end
    return {}
  end,
  transfer = function(self, node, follow_pred, graph, pred)
    if node == 'root' then return {[EOF] = true} end

    local follow_set = self:initialize(node)
    local configuration = graph.configuration
    for suffix in pairs(graph.forward[pred][node]) do
      follow_set = self:merge(follow_set, ll1.first(configuration, suffix))
    end
    -- TODO: first set may be null even when the production itself is not nullable
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
  tostring = function(self, _, node, input)
    local list = {}
    for key in pairs(input) do table.insert(list, key) end
    return node .. ' ' .. table.concat(list, ',')
  end
}

local function get_nonterminal(configuration, variable)
  if variable:sub(1, 1) == '$' then
    return configuration[variable:sub(2)]
  end
  return
end

local function get_terminals_from(configuration)
  local terminals = {}
  for _, productions in pairs(configuration) do
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

function configurations:get_dependency_graph()
  if not self.graph then
    local dependency_graph = graph.create()
    dependency_graph.configuration = self
    for _, nonterminal in pairs(self) do
      nonterminal:dependency(dependency_graph, self)
    end
    dependency_graph:set_root('root')
    getmetatable(self)['__index']['graph'] = dependency_graph
  end
  return self.graph
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

function configurations:firsts()
  if not self.cached_firsts then
    getmetatable(self)['__index']['cached_firsts'] = first_algorithm:forward(full_dependency_graph(self))
  end
  return utils.copy(self.cached_firsts)
end

function configurations:follows()
  if not self.cached_follows then
    getmetatable(self)['__index']['cached_follows'] = follow_algorithm:forward(self:get_dependency_graph())
  end
  return utils.copy(self.cached_follows)
end

function configurations:first(variable)
  return self:firsts()[variable]
end

function configurations:follow(variable)
  return self:follows()[variable]
end

local function merge(left, right)
  local merged = utils.copy(left)
    for key in pairs(right) do
      merged[key] = true
    end
    return merged
end

function ll1.first(configuration, production)
  local first_set = {}
  for object in utils.loop(production) do
    if object:sub(1, 1) == '$' then
      local partial_first_set = utils.copy(configuration:first(object:sub(2)))
      local eps = partial_first_set[EPS]
      partial_first_set[EPS] = nil
      first_set = merge(first_set, partial_first_set)
      if not eps then return first_set end
    else
      if object ~= EPS then first_set[object] = true; return first_set end
    end
  end
  first_set[EPS] = true
  return first_set
end

function nonterminals:first(configuration)
  configuration:first(self.variable:sub(2))
end

local function prettify(production)
  local result = {}
  for object in utils.loop(production) do
    local new
    if object:sub(1,1) == '$' then
      new = object
    else
      new = ("'%s'"):format(object)
    end
    table.insert(result, new)
  end
  return result
end

function configurations:pretty()
  local str = ''
  for variable, nonterminals in pairs(self) do
    local productions = {}
    for production in utils.loop(nonterminals) do
      table.insert(productions, table.concat(prettify(production), ' '))
    end
    str = str .. variable .. '\t\t' .. ':=    ' .. table.concat(productions, ' | ') .. ';\n'
  end
  return str
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
  graph:vertex(self.variable:sub(2))
  local uses = configuration:uses(self.variable)
  for variable, suffix in utils.uloop(uses) do
    get_nonterminal(configuration, variable):dependency(graph, configuration)
--    setmetatable(
--      suffix, 
--      {__tostring = function(self) return table.concat(ll1.first(configuration, suffix), ', ') end})
    graph:edge(variable:sub(2), self.variable:sub(2), suffix, true)
  end
  return graph
end


local yacc = {}

function ll1.configure(actions)
  -- Associate the correct set of metatables to the nonterminals
  local configuration = {}
  for variable, productions in pairs(actions) do
    if variable ~= 1 then
      setmetatable(productions, {__index = nonterminals})
      productions.variable = '$' .. variable
      configuration[variable] = productions
    end
  end
  return setmetatable(configuration, {__index = utils.copy(configurations)})
end

function ll1.yacc(actions)
  -- Associate the correct set of metatables to the nonterminals
  local configuration = ll1.configure(actions)
  local first_sets = configuration:firsts()
  local follow_sets = configuration:follows()
  local terminals = get_terminals_from(configuration)
  local transition_table = {}
  
  for variable in pairs(configuration) do
    transition_table[variable] = {}
    for terminal in pairs(terminals) do
      transition_table[variable][terminal] = ERROR
    end
  end
  
  for variable, productions in pairs(configuration) do
    for i, production in ipairs(productions) do
      local firsts = ll1.first(configuration, production)
      for terminal in pairs(firsts) do
        if terminal ~= EPS then
          if transition_table[variable][terminal] ~= ERROR and transition_table[variable][terminal] ~= i then
            -- check to see if there's an oracle
            if configuration[variable].conflict and type(configuration[variable].conflict[terminal]) == 'function' then
              if type(transition_table[variable][terminal]) == 'number' then
                transition_table[variable][terminal] = {transition_table[variable][terminal]}
              end
              table.insert(transition_table[variable][terminal], i)
            else
              print('ERROR', variable, terminal, table.concat(configuration[variable][transition_table[variable][terminal]], ', '), transition_table[variable][terminal])
              print('', '', '<>', table.concat(production, ', '), i)
            end
          else
            transition_table[variable][terminal] = i
          end
        end
      end
      if firsts[EPS] then
        local follows = follow_sets[variable]
        for terminal in pairs(follows) do
          if terminal ~= EPS then
            if transition_table[variable][terminal] ~= ERROR and transition_table[variable][terminal] ~= i then 
              -- check to see if there's an oracle
              if configuration[variable].conflict and type(configuration[variable].conflict[terminal]) == 'function' then
                if type(transition_table[variable][terminal]) == 'number' then
                  transition_table[variable][terminal] = {transition_table[variable][terminal]}
                end
                table.insert(transition_table[variable][terminal], i)
              else
                print('ERROR', variable, terminal, table.concat(configuration[variable][transition_table[variable][terminal]], ', '), transition_table[variable][terminal])
                print('', '', '<>', table.concat(production, ', '), i)
              end
            else
              transition_table[variable][terminal] = i
            end
          end
        end
      end
    end
  end
  
  local y = utils.copy(yacc)
  y.configuration = configuration
  setmetatable(transition_table, {__index = y})
  
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
local function id(...)
  return ...
end
local function next100tokens(tokens)
  print("The next 100 tokens are:")
  print(unpack(utils.sublist(utils.map(function(x) return "'" .. x[2] .. "'" end, tokens), 1, 100)))
end

function yacc:parse(tokens, state, trace)
  if not state then state = 'root' end
  if not trace then trace = {} end
  local token = peek(tokens)
  if not token then token = EOF end
  local converted_token = tostring(token)
  local production_index = self[state][converted_token]
  if not production_index then
    next100tokens(tokens)
    print("Error", state, token, "Unknown token")
    return ERROR, trace
  end
  -- check if we have an oracle
  if type(production_index) ~= 'number' then
    if type(production_index) ~= 'table' then
      next100tokens(tokens)
      print("Error", state, production_index, "Unknown oracle")
      return ERROR, trace
    end
    local oracle = setmetatable(
      utils.copy(production_index), 
      {
        __index = {
          go = function(conflicts, tag)
            for to in utils.loop(conflicts) do
              if self.configuration[state][to].tag == tag or (tag == EPS and self.configuration[state][to][1] == EPS) then
                return to
              end
            end
            print("Warning " .. tag .. " is not valid")
            return ERROR
          end
        }
      }
    )
    production_index = self.configuration[state].conflict[tostring(token)](oracle, tokens)
    if not production_index then
      next100tokens(tokens)
      print("Error", state, token, "Unknown token")
      return ERROR, trace
    end
  end
  local production = self.configuration[state][production_index]
  -- local local_trace = {state, converted_token, utils.copy(tokens), production}
  -- table.insert(trace, local_trace)
  if production_index == ERROR then
    next100tokens(tokens)
    print("Error", state, tostring(token), "Candidates are:")
    for production in utils.loop(self.configuration[state]) do
      print('', '', table.concat(utils.map(function(x) return (x == '' and 'eps') or tostring(x) end, production), ' '))
    end
    return ERROR, trace
  end
  local args = {}
  for node in utils.loop(production) do
    if node:sub(1, 1) == '$' then
      local ret = self:parse(tokens, node:sub(2), trace)
      if ret == ERROR then
        print("  From", state, token, table.concat(utils.map(tostring, production), ' '))
        return ERROR, trace
      end
      table.insert(args, ret)
    elseif converted_token ~= EOF and node ~= EPS then
      local token = consume(tokens)
      if not token then token = EOF end
      if node ~= tostring(token) then
        next100tokens(tokens)
        print("ERROR", state, tostring(token), "Expected: " .. tostring(node))
        return ERROR, trace
      end
      table.insert(args, token)
    elseif converted_token ~= EOF and node == EPS then
      -- don't do anything
      assert(production[1] == EPS)
    else
      local token = consume(tokens)
      if token then
        next100tokens(tokens)
        print("ERROR", state, tostring(token), "Expected: " .. EOF)
        return ERROR, trace
      end
    end
  end
  -- table.insert(local_trace, args)
  local success, result = pcall(production.action, unpack(args))
  if not success then
    next100tokens(tokens)
    print("ERROR", "Cannot call action: " .. result)
    print("  From", state, tostring(token), table.concat(utils.map(tostring, production), ' '))
    return ERROR, trace
  end
  if not result then
    next100tokens(tokens)
    local info = debug.getinfo(production.action, "Sl")
    print("ERROR", "Cannot have an action that returns nil", string.format("%s:%d", info.short_src, info.linedefined))
    print("  From", state, tostring(token), table.concat(utils.map(tostring, production), ' '))
    return ERROR, trace
  end
  return result, trace
end

function yacc:save(file)
  -- dump out the table
  -- if io.open(file, "r") then return end
  local serialized_dump = utils.dump {self, self.configuration}
  local stream = assert(io.open(file, "w"))
  stream:write('return ' .. serialized_dump)
  assert(stream:close())
  return self
end

function ll1.create(actions)
  actions = utils.copy(actions)
  local file = table.remove(actions)
  
  if not file then
    return ll1.yacc(actions)
  end
  
  local status, bundle = pcall(require, file:gsub('/', '.'):gsub('.lua$', ''))
  if not status then
    local transitions = ll1.yacc(actions)
    return transitions:save(file)
  end

--  local status, bundle = pcall(deserialize)
--  if not status then
--    return ll1.yacc(actions):save(file)
--  end
  
  local transitions, configuration = unpack(bundle)
  setmetatable(configuration, {__index = utils.copy(configurations)})
  local y = utils.copy(yacc)
  y.configuration = actions
  setmetatable(transitions, {__index = y})
  local sane = true
  for variable, productions in pairs(configuration) do
    for index, production in ipairs(productions) do
      if not actions[variable] or not actions[variable][index] then
        sane = false
        break
      end
      local action = actions[variable][index]
      production.action = action.action
      for j, object in ipairs(production) do
        if object ~= action[j] then
          sane = false
          break
        end
      end
    end
  end
  if sane then
    return transitions
  else
    return ll1.yacc(actions):save(file)
  end
end

return setmetatable(ll1, {__call = function(self, ...) return self.create(...) end})