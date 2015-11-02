-- LL1 parser, which is somewhat limited :'(

local ll1 = {}

local nonterminals = {}
local configurations = {}

local EPS = ''

local function get_nonterminal(configuration, variable)
  
end

local function nullable(configuration, production)
  local initial = production[1]
  if initial == EPS then
    return true
  end
  local nonterminal = get_productions(configuration, initial)
  if nonterminal then
    return nonterminal:nullable(configuration)
  end
  return false
end

function nonterminals:nullable(configuration)
  for _, production in ipairs(self) do
    if nullable(configuration, production) then
      return true
    end
  end
  return false
end

local function first(configuration, production)
  local initial = production[1]
  local first_set = {}
  local nonterminal = get_productions(configuration, initial)
  if nonterminal then
    return nonterminal:first(configuration)
  else
    return {[initial] = true}
  end
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

function ll1.yacc(actions)
  -- Associate the correct set of metatables to the nonterminals
  local configuration = {}
  for variable, productions = pairs(actions) do
    setmetatable(productions, {__index = nonterminals})
    configuration[variable] = productions
  end
  setmetatable(configuration, {__index = configurations})
end

-- expr = $consts | identifier | fun $x -> $expr
-- consts = number | string | true | false
ll1.yacc {
  expr = {
    {'$consts', action = ignore},
    {'identifier', action = ignore},
    {'fun', 'identifier', '->', '$expr', action = ignore},
  },
  consts = {
    {'number', action = ignore},
    {'string', action = ignore},
    {'true', action = ignore},
    {'false', action = ignore},
  }
}

return ll1