-- Use regular expressions to compile and construct a tokenizer
-- A tokenizer is an iterator over strings

local lex = {}
local re = require "re"
r = re.compile

local function lexicographical(a, b)
  assert(type(a) == 'string' and type(b) == 'string')
  return #a > #b or a > b
end

local context = {}
function context:next()
  -- consume off of the current using the current configuration state
  local action_node = self.configuration[self.state]
--  action_map = action_map, 
--  word_map = word_map, 
--  automaton_map = automaton_map, 
--  words = words, 
--  local_automatons = local_automatons
end

function context:go(state)
  assert(self.configuration[state] and self.configuration.state ~= state)
  self.state = state
end

local function new_context(configuration, str)
  local ctx = {
    configuration = configuration,
    state = 'root',
    string = str,
    current = str,
  }
  setmetatable(ctx, {__index = context})
  return ctx
end

function lex.lex(actions)
  -- action maps a name -> regex -> action function
  -- think of it as a giant alternation that takes ordering into consideration
  local configuration = {}
  for name, action in pairs(actions) do
    local action_map = {}
    local word_map = {}
    local automaton_map = {}
    local words = {}
    local local_automatons = {}
    for _, bundle in ipairs(action) do
      local sigil, act = unpack(bundle)
      action_map[sigil] = act
      if type(sigil) == 'string' then
        table.insert(words, sigil)
        word_map[sigil] = act
      else
        table.insert(local_automatons, sigil.pattern)
        automaton_map[sigil.pattern] = sigil
      end
    end
    table.sort(words, lexicographical)
    local action_node = {
      action_map = action_map, 
      word_map = word_map, 
      automaton_map = automaton_map, 
      words = words, 
      local_automatons = local_automatons}
    configuration[name] = action_node
  end
  return function(str)
    local context = new_context(configuration, str)
    return function()
      return context:next()
    end
  end
end

local tokenizer = lex.lex {
  root = {
    {'if',  function(piece, lexer) end},
    {'else', function(piece, lexer) end},
    {r '%s', function(piece, lexer) end},
    {'"', function(piece, lexer) lexer:go 'string' end},
  },
  string = {
    {'"', function(piece, lexer) lexer:go 'root' end}
  },
}

for token in tokenizer('if else   ""') do
  
end

return lex