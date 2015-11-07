-- Frontend parser for the parser
--[[--
Here's the grammar we're looking for

root := $top

top_opts := CONVERT CODE top_opt' | DEFAULT CODE top_opt' | PROLOGUE CODE top_opt' | EPILOGUE CODE top_opt' | TOP_LEVEL CODE top_opt'
top_opts' := $top_opts | eps
production := PRODUCTION IDENTIFIER $production'
production' := STRING | eps
production_list := $production $production_list'
production_list' := eps | $production_list
valid_rhs := IDENTIFIER | VARIABLE | EPS
rhs_list := $valid_rhs $rhs_list'
rhs_list' := eps | $rhs_list
top := $top_opts $top_no_convert | $top_no_convert
top_no_convert := $production_list $rules | $rules
nonterminal := $rhs_list $nonterminal'
nonterminal' := CODE nonterminal'' | REFERENCE nonterminal'' | SEMICOLON | OR $nonterminal
nonterminal'' := eps | OR $nonterminal
single_rule := IDENTIFIER GETS $nonterminal
rules := $single_rule $rules'
rules' := eps | $rules
--]]--

local ll1 = require 'll1'
local utils = require 'utils'
local tokenizer = require 'll1_tokenizer'

local id = function(...) return ... end
local ignore = function() return {} end

local conf = {}
function conf:finalize()
  if not self.convert then
    self.convert = "function(...) return ... end"
  end
  if not self.default then
    self.default = "__GRAMMAR__"
  end
  if not self.prologue then
    print("WARNING", "You really should specify a prologue, which will convert a string into a list of tokens.")
    self.prologue = [[
function(str)
  local tokens = {}
  for token in str:gmatch("%S+") do
    table.insert(tokens, token)
  end
  return tokens
end
]]
  end
  if not self.epilogue then
    self.epilogue = 'function(...) return ... end'
  end
  if not self.toplevel then
    self.toplevel = ''
  end
  if not self.file then
    print("Warning", "Are you sure you want to disable caching of this grammar? Specify %FILE otherwise.")
  end
  if not self.requires then
    self.requires = {'ll1'}
  end
  if not self.default_action then
    self.default_action = 'function(...) return {...} end'
  end
  return self
end

local grammar = ll1 {
--  '/Users/leegao/sideproject/ParserSiProMo/ll1_parsing.table',
  root = {{'$top', action = id}},
  conf = {
    {'CONVERT', 'CODE', '$configuration_', 
      action = function(_, code, last)
        assert(not last.convert, 'You\'ve already specified another converter.')
        last.convert = code[2]
        return last
      end},
    {'DEFAULT', 'STRING', '$configuration_', 
      action = function(_, name, last)
        assert(not last.default, 'You\'ve already specified another default name.')
        last.default = name[2]
        return last
      end},
    {'PROLOGUE', 'CODE', '$configuration_', 
      action = function(_, code, last)
        assert(not last.prologue, 'You\'ve already specified another prologue.')
        last.prologue = code[2]
        return last
      end},
    {'EPILOGUE', 'CODE', '$configuration_', 
      action = function(_, code, last)
        assert(not last.epilogue, 'You\'ve already specified another epilogue.')
        last.epilogue = code[2]
        return last
      end},
    {'TOP_LEVEL', 'CODE', '$configuration_', 
      action = function(_, code, last)
        if not last.top_level then last.top_level = '' end
        last.top_level = code[2] .. '\n' .. last.top_level
        return last
      end},
    {'FILE', 'STRING', '$configuration_', 
      action = function(_, file, last)
        assert(not last.file, 'You\'ve already specified another file root.')
        last.file = file[2]
        return last
      end},
    {'REQUIRE', 'STRING', '$configuration_', 
      action = function(_, namespace, last)
        if not last.requires then last.requires = {'ll1'} end
        if namespace[2] ~= 'll1' then
          table.insert(last.requires, 1, namespace[2])
        end
        return last
      end},
  },
  configuration_ = {
    {'', 
      action = function() 
        return setmetatable({}, {__index = conf}) 
      end}, 
    {'$conf', 
      action = function(code) 
        return code 
      end}},
  
  production = {
    {'PRODUCTION', 'IDENTIFIER', '$production_', 
      action = function(_, id, self)
        self.id = id
        return self
      end},
  },
  production_ = {
    {'STRING', 
      action = function(str)
        return {string = str}
      end}, 
    {'', action = function() return {} end},
  },
  production_list = {
    {'$production', "$production_list'", 
      action = function(production, list)
        table.insert(list, production)
        return list
      end},
  },
  ['production_list\''] = {
    {'', action = function() return {} end},
    {'$production_list', action = function(list) return list end},
  },
  valid_rhs = {
    {'IDENTIFIER', action = id}, 
    {'VARIABLE', action = id}, 
    {'EPS', action = function() return {'EPS', ''} end}
  },
  rhs_list = {
    {'$valid_rhs', "$rhs_list'", 
      action = function(object, production)
        table.insert(production, 1, object[2])
        return production
      end}
  },
  ["rhs_list'"] = {
    {'', action = function() return {} end},
    {'$rhs_list', action = id},
  },
  top = {
    {'$conf', '$top_no_convert', 
      action = function(configuration, rules)
        configuration:finalize()
        return {configuration, rules}
      end},
    {'$top_no_convert', 
      action = function(rules)
        return {setmetatable({}, conf), rules}
      end},
  },
  top_no_convert = {
    {'$production_list', '$rules', 
      action = function(_, rules) return rules end},
    {'$rules', action = id},
  },
  nonterminal = {
    {'$rhs_list', "$nonterminal'", 
      action = function(production, pair)
        local action, nonterminal = unpack(pair)
        production.action = action
        table.insert(nonterminal, 1, production)
        return nonterminal
      end},
  },
  ["nonterminal'"] = {
    {'CODE', "$nonterminal''", 
      action = function(code, nonterminal)
        return {code[2], nonterminal}
      end},
    {'REFERENCE', "$nonterminal''",
      action = function(ref, nonterminal)
        return {ref[2], nonterminal}
      end},
    {'OR', '$nonterminal', 
      action = function(_, nonterminal)
        return {nil, nonterminal}
      end},
    {'SEMICOLON', 
      action = function()
        return {nil, {}}
      end},
  },
  ["nonterminal''"] = {
    {'', action = function() return {} end},
    {'OR', '$nonterminal', 
      action = function(_, nonterminal)
        return nonterminal
      end},
  },
  single_rule = {
    {'IDENTIFIER', 'GETS', '$nonterminal', 
      action = function(id, _, nonterminals)
        return {id[2], nonterminals}
      end}
  },
  rules = {
    {'$single_rule', '$rules_', 
      action = function(rule, rules)
        local id, nonterminal = unpack(rule)
        rules[id] = nonterminal
        return rules
      end}
  },
  rules_ = {
    {'', action = function() return {} end}, 
    {'$rules', action = id}
  },
}

local function prologue(str, grammar)
  local tokens = {}
  for token in tokenizer(str) do
    table.insert(tokens, token)
  end
  return tokens
end

local function convert(token)
  return token[1]
end

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local function epilogue(result)
  local configuration, actions = unpack(result)
  local name = configuration.default
  local functions = {}
  for namespace in utils.loop(configuration.requires) do
    print(('require \'%s\''):format(namespace))
  end
  print(('local %s = {}'):format(configuration.default))
  
  for variable, nonterminal in pairs(actions) do
    functions[variable] = {}
    for production in utils.loop(nonterminal) do
      table.insert(functions[variable], trim(production.action or ('%s.default_action'):format(configuration.default)))
      production.action = nil
    end
  end
  local grammar = ll1(actions) -- to validate
  
  print(configuration.default .. '.grammar = ' .. utils.dump(actions, id))
  if configuration.file then
    print(('%s.grammar[1] = \'%s.table\''):format(configuration.default, configuration.file))
  end
  if configuration.toplevel ~= '' then
    print(configuration.toplevel)
  end
  
  for key in utils.loop {'convert', 'prologue', 'epilogue', 'default_action'} do
    print(('%s.%s = %s'):format(configuration.default, key, trim(configuration[key])))
  end
  
  for variable, nonterminal in pairs(actions) do
    for i in ipairs(nonterminal) do
      print(('%s.grammar.%s[%s].action = %s'):format(configuration.default, variable, i, functions[variable][i]))
    end
  end
  print(('%s.ll1 = ll1(%s.grammar)'):format(name, name))
  local parse_string = trim([[
return function(str)
  local tokens = {}
  for _, token in ipairs(%s.prologue(str)) do
    table.insert(
      tokens, 
      setmetatable(
        token, 
        {__tostring = function(self) return %s.convert(self) end}))
  end
  local result = %s.ll1:parse(tokens)
  return %s.epilogue(result)
end
]]):format(name, name, name, name)
  print(parse_string)
  return result
end

local function parse(str)
  local tokens = {}
  for token in utils.loop(prologue(str, grammar)) do
    table.insert(
      tokens, 
      setmetatable(
        token, 
        {__tostring = function(self) return convert(self) end}))
  end
  local result = grammar:parse(tokens)
  return epilogue(result)
end

parse(io.open('/Users/leegao/sideproject/ParserSiProMo/parser.ylua'):read("*all"))