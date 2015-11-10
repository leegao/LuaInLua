-- Frontend parser for the parser
--[[--
Here's the grammar we're looking for

root := $top

top_opts := CONVERT CODE top_opt' | DEFAULT CODE top_opt' | PROLOGUE CODE top_opt' | EPILOGUE CODE top_opt' | TOP_LEVEL CODE top_opt' | QUOTE QUOTED $valid_rhs
top_opts' := $top_opts | eps
production := PRODUCTION IDENTIFIER $production'
production' := STRING | eps
production_list := $production $production_list'
production_list' := eps | $production_list
single_rhs := IDENTIFIER | VARIABLE | EPS | QUOTED | '(' $rhs_list ')
valid_rhs := $single_rhs valid_postfix
valid_postfix := %eps | '+' | '*' | '?'
rhs_list := $valid_rhs $rhs_list_
rhs_list_ := %eps | $rhs_list
top := $top_opts $top_no_convert | $top_no_convert
top_no_convert := $production_list $rules | $rules
nonterminal := $rhs_list $nonterminal'
nonterminal' := CODE nonterminal'' | REFERENCE nonterminal'' | SEMICOLON | OR $nonterminal
nonterminal'' := eps | OR $nonterminal
single_rule := IDENTIFIER GETS $nonterminal
rules := $single_rule $rules | %eps
--]]--

local ll1 = require 'll1'
local utils = require 'utils'
local tokenizer = require 'll1_tokenizer'

local id = function(...) return ... end
local ignore = function() return {} end

local conf = {}
function conf:finalize()
  if not self.convert then
    self.convert = "function(token) return token[1] end"
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
    table.insert(tokens, {token})
  end
  return tokens
end
]]
  end
  if not self.epilogue then
    self.epilogue = 'function(...) return ... end'
  end
  if not self.top_level then
    self.top_level = ''
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
  if not self.quotes then
    self.quotes = {}
  end
  return self
end

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local function flatten(configuration, object)
  if object[1] == 'QUOTED' and configuration.quotes[object[2]] then
    return configuration.quotes[object[2]]
  else
    return object[2]
  end
end

local function new_context(variable)
  return {
    name = function(self, name)
      index = '$'..name
      if not self[index] then self[index] = 1 end
      local result = ("%s'%s#%s"):format(variable, name, self[index])
      self[index] = self[index] + 1
      return result
    end,
    variable = function(self)
      return variable
    end
  }
end

local function star(object, variable)
  return {
    variable = '$' .. variable,
    {object[2], '$' .. variable,  action = trim "function(item, list) table.insert(list, item); return list end"},
    {'',  action = trim "function() return {} end"},
  }, variable
end

local synthesis = {}

function synthesis.local_synthesis(configuration, raw_production, context)
  -- depth first search
  local raw_action = raw_production.action
  local production = {}
  local new_synthesis = {}
  -- compute the action
  if raw_action and raw_action[1] == 'CODE' then
    production.action = action[2]
  elseif action and action[1] == 'REFERENCE' then
    -- function(_1, _2, ...) 
    --   local all = {_1, _2, ...}
    local n = #production
    local all = {}
    for i = 1,n do table.insert(all, '_' .. i) end
    all = table.concat(all, ', ')
    production.action = trim([[
function(%s)
return %s
end
]]):format(all, action[2]:gsub("*all", all))
  end
  -- Each object in the raw production is either a token, a nonterminal, or a postfix, the last 2 induces new nonterminals
  for raw_object in utils.loop(raw_production) do
    if raw_object.kind == 'token' then
      local object = (flatten(configuration, raw_object))
      table.insert(production, object)
    elseif raw_object.kind == 'productions' then
      -- second is a set of nonterminals, let's construct that
      local variable = context:name('group')
      table.insert(production, '$' .. variable)
      local new_productions, new = synthesis.synthesize_nonterminals(configuration, variable, raw_object[2])
      table.insert(new_synthesis, new_productions)
      for more in utils.loop(new) do
        table.insert(new_synthesis, more)
      end
    elseif raw_object.kind == 'postfix' then
      local variable = context:name(raw_object[1])
      local inner = raw_object[2]
      table.insert(production, '$' .. variable)
      -- The inner tree can be either a token or another list of productions. 
      if inner.kind == 'productions' then
        -- take care of the inner group first
        local inner_variable = context:name('group')
        local new_productions, new = synthesis.synthesize_nonterminals(configuration, inner_variable, inner[2])
        inner = {'VARIABLE', '$' .. inner_variable, kind = 'token'}
        table.insert(new_synthesis, new_productions)
        for more in utils.loop(new) do
          table.insert(new_synthesis, more)
        end
      else
        inner[2] = flatten(configuration, inner)
      end
      assert(inner.kind == 'token')
      -- Something* := %eps | Something Something*
      -- Something+ := Something Something*
      -- Something? := %eps | Something
      if raw_object[1] == 'star' then
        local new = star(inner, variable)
        table.insert(new_synthesis, new)
      elseif raw_object[1] == 'plus' then
        local new_star, star_var = star(inner, context:name('star'))
        local new_plus = {
          variable = '$' .. variable,
          {inner[2], '$' .. star_var, 
          action = trim [[
  function(item, list)
    table.insert(list, item)
    return list
  end
]]}}
        table.insert(new_synthesis, new_star)
        table.insert(new_synthesis, new_plus)
      else
        local new_maybe = {
          variable = '$' .. variable,
          {inner[2],  action = trim "function(item) return {item} end"},
          {'',  action = trim "function() return {} end"},
        }
        table.insert(new_synthesis, new_maybe)
      end
    else
      error "Unknown kind"
    end
  end
  return production, new_synthesis
end

function synthesis.synthesize_nonterminals(configuration, variable, raw_productions)
  local productions = {}
  local new_synthesis = {}
  local context = new_context(variable)
  for raw_production in utils.loop(raw_productions) do
    local production, more = synthesis.local_synthesis(configuration, raw_production, context)
    table.insert(productions, production)
    for new in utils.loop(more) do
      table.insert(new_synthesis, new)
    end
  end
  productions.variable = '$' .. variable
  -- productions.synthesized_from = raw_productions
  return productions, new_synthesis
end

local function synthesize(configuration, raw)
  local actions = {}
  for variable, raw_productions in pairs(raw) do
    local nonterminal, more = synthesis.synthesize_nonterminals(configuration, variable, raw_productions)
    actions[variable] = nonterminal
    for new in utils.loop(more) do
      actions[new.variable:sub(2)] = new
    end
  end
  return actions
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
        last.top_level = trim(code[2]) .. '\n' .. last.top_level
        return last
      end},
    {'DEFAULT_ACTION', 'CODE', '$configuration_', 
      action = function(_, code, last)
        assert(not last.default_action, 'You\'ve already specified another default action.')
        last.default_action = code[2]
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
    {'QUOTE', 'QUOTED', 'IDENTIFIER', '$configuration_', 
      action = function(_, quote, id, last)
        if not last.quotes then last.quotes = {} end
        last.quotes[quote[2]] = id[2]
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
-- single_rhs := IDENTIFIER | VARIABLE | EPS | QUOTED | '(' $nonterminal ')
-- valid_rhs := $single_rhs valid_postfix
-- valid_postfix := %eps | '+' | '*' | '?'
  single_rhs = {
    {'IDENTIFIER', action = function(id) id.kind = 'token'; return id end}, 
    {'VARIABLE', action = function(id) id.kind = 'token'; return id end}, 
    {'EPS', action = function() return {'EPS', '', kind = 'token'} end},
    {'QUOTED', action = function(quoted) quoted.kind = 'token'; return quoted end},
    {'LPAREN', '$nonterminal', 'RPAREN', action = function(_, nonterminal, _) return {'PRODUCTIONS', nonterminal, kind = 'productions'} end}
  },
  valid_postfix = {
    {'', action = function() return 'nothing' end},
    {'PLUS', action = function() return 'plus' end},
    {'STAR', action = function() return 'star' end},
    {'MAYBE', action = function() return 'maybe' end},
  },
  valid_rhs = {
    {'$single_rhs', '$valid_postfix', 
      action = function(object, postfix)
        if object[1] == 'EPS' and postfix ~= 'nothing' then
          error("Cannot use extended operation on nothing.")
        end
        if postfix == 'nothing' then
          return object
        end
        return {postfix, object, kind = 'postfix'}
      end},
  },
  rhs_list = {
    {'$valid_rhs', "$rhs_list_", 
      action = function(object, production)
        table.insert(production, 1, object)
        return production
      end},
  },
  rhs_list_ = {
    {'', action = function() return {} end},
    {'$rhs_list', action = id},
  },
  top = {
    {'$conf', '$top_no_convert', 
      action = function(configuration, rules)
        configuration:finalize()
        -- convert productions over 
        return {configuration, rules}
      end},
    {'$top_no_convert', 
      action = function(rules)
        local configuration = setmetatable({}, {__index = conf})
        configuration:finalize()
        return {configuration, rules}
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
        table.insert(nonterminal, production)
        return nonterminal
      end},
  },
  ["nonterminal'"] = {
    {'CODE', "$nonterminal''", 
      action = function(code, nonterminal)
        return {code, nonterminal}
      end},
    {'REFERENCE', "$nonterminal''",
      action = function(ref, nonterminal)
        return {ref, nonterminal}
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
    {'$single_rule', '$rules', 
      action = function(rule, rules)
        local id, nonterminal = unpack(rule)
        rules[id] = nonterminal
        return rules
      end},
    {'', action = function() return {} end}
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
  local configuration, raw = unpack(result)
  -- all nonterminals are unpacked, which means some productions may have postfixes or nonterminals
  local actions = synthesize(configuration, raw)
  local name = configuration.default
  local functions = {}
  local code = ''
  for namespace in utils.loop(configuration.requires) do
    code = code .. ('local %s = require \'%s\'\n'):format(namespace, namespace)
  end
  code = code .. ('local %s = {}\n'):format(configuration.default)

  for variable, nonterminal in pairs(actions) do
    functions[variable] = {}
    for production in utils.loop(nonterminal) do
      table.insert(functions[variable], trim(production.action or ('%s.default_action'):format(configuration.default)))
      production.action = nil
    end
  end
  local function escape(id)
    return table.concat(
      utils.map(
        function(char) 
          if char == ("'"):byte() then 
            return "\\'" 
          else 
            return string.char(char) 
          end 
        end, 
        {id:byte(1, #id)}))
  end
  
  code = code .. configuration.default .. '.grammar = ' .. utils.dump(actions, escape) .. '\n'
  if configuration.file then
    code = code .. ('%s.grammar[1] = \'%s.table\'\n'):format(configuration.default, configuration.file)
  end
  if configuration.top_level ~= '' then
    code = code .. trim(configuration.top_level) .. '\n'
  end
  
  for key in utils.loop {'convert', 'prologue', 'epilogue', 'default_action'} do
    code = code .. ('%s.%s = %s\n'):format(configuration.default, key, trim(configuration[key]))
  end
  
  for variable, nonterminal in pairs(actions) do
    for i in ipairs(nonterminal) do
      code = code .. ('%s.grammar["%s"][%s].action = %s\n'):format(configuration.default, variable, i, functions[variable][i])
    end
  end
  code = code .. ('%s.ll1 = ll1(%s.grammar)\n'):format(name, name)
  code = code .. trim([[
return setmetatable(
  %s, 
  {__call = function(this, str)
    local tokens = {}
    for _, token in ipairs(this.prologue(str)) do
      table.insert(
        tokens, 
        setmetatable(
          token, 
          {__tostring = function(self) return this.convert(self) end}))
    end
    local result = this.ll1:parse(tokens)
    return this.epilogue(result)
  end})
]]):format(name)
  return code, configuration
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

local code, configuration = parse(io.open('/Users/leegao/sideproject/ParserSiProMo/lua/grammar.ylua'):read("*all"))
os.remove(configuration.file .. '.table')
local func, status = loadstring(code)
if not func then
  error("ERROR: " .. status)
end
local succ, other_parser = pcall(func) -- lets just try it out and "warm the cache"
if not succ then
  error("ERROR: " .. other_parser)
end
if configuration.file then
  local file = io.open(configuration.file .. '.lua', 'w')
  file:write(code)
  file:close()
end
