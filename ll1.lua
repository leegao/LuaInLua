-- LL1 parser, which is somewhat limited :'(

local ll1 = {}

local nonterminals = {}
local configurations = {}

local EPS = ''

local function get_nonterminal(configuration, variable)
  if variable:sub(1, 1) == '$' then
    return configuration[variable:sub(2)]
  end
  return
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

function ll1.yacc(actions)
  -- Associate the correct set of metatables to the nonterminals
  local configuration = {}
  for variable, productions in pairs(actions) do
    setmetatable(productions, {__index = nonterminals})
    configuration[variable] = productions
  end
  setmetatable(configuration, {__index = configurations})
  
  for variable, nonterminal in pairs(configuration) do
    local first_set = {}
    for token in pairs(nonterminal:first(configuration)) do table.insert(first_set, token) end
    print(variable, table.concat(first_set, ', '))
  end
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