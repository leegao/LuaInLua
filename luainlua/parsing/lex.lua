-- Use regular expressions to compile and construct a tokenizer
-- A tokenizer is an iterator over strings

local lex = {}
local re = require "luainlua.parsing.re"
local alphabetical = re.compile("[a-zA-Z0-9_]")

local function lexicographical(a, b)
  assert(type(a) == 'string' and type(b) == 'string')
  return a > b
end

local function boundary(last, first)
  -- make sure that alpha(last) xor alpha(first)
  if not last then return false end
  if not first then return true end
  local alpha_last = alphabetical:match(last)
  local alpha_first = alphabetical:match(first)
  return (alpha_last and not alpha_first) or (not alpha_last)
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
  local first = self:position()
  if #current == 0 then return end

  -- go through the set of words and see if any of them matches
  for _, word in ipairs(action_node.words) do
    if current:sub(1, #word) == word and boundary(word:sub(-1), peek(current, #word + 1)) then
      -- matched a word, so consume and go on
      self.current = current:sub(#word + 1)
      local last = self:position()
      self:set_location(first, last)
--      print(word, first, last, self:get_location()[1][2], self:get_location()[2][2])
      return action_node.word_map[word](word, self)
    end
  end
  
  -- go through the automatons next
  for _, automaton in ipairs(action_node.local_automatons) do
    local word, history = automaton:match(current)
    if word then
      self.current = current:sub(#word + 1)
      local last = self:position()
      self:set_location(first, last)
--      print(word, first, last, self:get_location()[1][2], self:get_location()[2][2])
      return action_node.automaton_map[automaton.pattern](word, self)
    end
  end
  
  error('Not tokenizable in ' .. self.state .. ': ' .. self.current)
end

function context:go(state)
  assert(self.configuration[state], ("State %s does not exist."):format(state))
  assert(self.configuration.state ~= state, ("You are already in state %s."):format(state))
  self.state = state
end

function context:position()
  return #self.string - #self.current + 1
end

function context:set_location(first, last)
  local first_line = self:get_line_of(first)
  local last_line = self:get_line_of(last)
  self.location = {{first, first_line}, {last, last_line}}
end

function context:get_location()
  return self.location
end

function context:get_line_of(position)
  -- TODO: binary search instead
  for line, stopper in ipairs(self.newlines) do
    if stopper >= position then return line end
  end
  return 1
end

local function new_context(configuration, str)
  local ctx = {
    configuration = configuration,
    state = 'root',
    string = str,
    current = str,
    location = {0, 0},
    newlines = {}
  }
  -- compute the locations of all of the newlines
  for i = 1, #str do
    if str:byte(i) == 10 then
      table.insert(ctx.newlines, i)
    end
  end
  table.insert(ctx.newlines, #str)
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
      if not token and #context.current == 0 and context.state ~= 'root' then
        error('Unexpectedly terminated in state ' .. context.state)
      end
      return token
    end
  end
end

return lex