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
valid_rhs := IDENTIFIER | VARIABLE
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
  if not self.require then
    self.require = {}
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
        if not last.requires then last.requires = {} end
        table.insert(last.requires, 1, namespace[2])
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
  valid_rhs = {{'IDENTIFIER', action = id}, {'VARIABLE', action = id}},
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
--        print(utils.dump(configuration, function(...) return ... end))
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
    {'', action = {}},
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

local function epilogue(result)
  print(utils.dump(result, id))
  return result
end

local function parse(str)
  local tokens = {}
  for token in utils.loop(prologue(str, grammar)) do
    print(token[2])
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