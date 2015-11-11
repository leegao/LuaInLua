-- Use regular expressions to compile and construct a tokenizer
-- A tokenizer is an iterator over strings

local lex = {}
local re = require "parsing.re"
local alphabetical = re.compile("%a")

local function lexicographical(a, b)
  assert(type(a) == 'string' and type(b) == 'string')
  return a > b
end

local function boundary(last, first)
  -- make sure that alpha(last) xor alpha(first)
  if not last then return false end
  if not first then return true end
  local alpha_last = re.match(alphabetical, last)
  local alpha_first = re.match(alphabetical, first)
  return (alpha_last and not alpha_first) or (not alpha_last and alpha_first)
end

local function peek(word, n)
  if n > #word then
    return nil
  end
  return word:sub(n, n)
end

local context = {}
function context:next()
  -- consume off of the current using the current configuration state
  local action_node = self.configuration[self.state]
  local current = self.current
  if #current == 0 then return end

  -- go through the set of words and see if any of them matches
  for _, word in ipairs(action_node.words) do
    if current:sub(1, #word) == word and boundary(word:sub(-1), peek(word, #word + 1)) then
      -- matched a word, so consume and go on
      self.current = current:sub(#word + 1)
      return action_node.word_map[word](word, self)
    end
  end
  
  -- go through the automatons next
  for _, automaton in ipairs(action_node.local_automatons) do
    local word, history = automaton:match(current)
    if word then
      self.current = current:sub(#word + 1)
      return action_node.automaton_map[automaton.pattern](word, self)
    end
  end
  
  error('Not tokenizable in ' .. self.state .. ': ' .. self.current)
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
    local word_map = {}
    local automaton_map = {}
    local words = {}
    local local_automatons = {}
    for _, bundle in ipairs(action) do
      local sigil, act = unpack(bundle)
      if type(sigil) == 'string' then
        table.insert(words, sigil)
        word_map[sigil] = act
      else
        table.insert(local_automatons, sigil)
        automaton_map[sigil.pattern] = act
      end
    end
    table.sort(words, lexicographical)
    local action_node = {
      word_map = word_map, 
      automaton_map = automaton_map, 
      words = words, 
      local_automatons = local_automatons}
    configuration[name] = action_node
  end
  return function(str)
    local context = new_context(configuration, str)
    return function()
      local token = context:next()
      while not token and #context.current ~= 0 do
        token = context:next()
      end
      return token
    end
  end
end

return lex