-- Dumb regular expressions

-- Step 1: Parse regular expressions
-- they are of the form
--   e = x | e e | (e | e) | e* | e+ | e? | ctrl

local graph = require "luainlua.common.graph"
local utils = require "luainlua.common.utils"
local worklist = require "luainlua.common.worklist"

local re = {}

local function pop(stack)
  return table.remove(stack)
end

local function push(item, stack)
  table.insert(stack, item)
end

local function concat(left, right)
  if left == '' then return right end
  if left[1] == 'or' then
    local l = left[2]
    local r = left[3]
    return {'or', l, concat(r, right)}
  else
    return {'concat', left, right}
  end
end

local function introduce_or(left)
  return {'or', left, ''}
end

local function group(item, open)
  return {'group', item, open}
end

local function star(item)
  if item[1] == 'or' then
    local left = item[2]
    local right = item[3]
    return {'or', left, star(right)}
  elseif item[1] == 'concat' then
    local left = item[2]
    local right = item[3]
    return {'concat', left, star(right)}
  else
    return {'star', item}
  end
end

local function maybe(item)
  if item[1] == 'or' then
    local left = item[2]
    local right = item[3]
    return {'or', left, maybe(right)}
  elseif item[1] == 'concat' then
    local left = item[2]
    local right = item[3]
    return {'concat', left, maybe(right)}
  else
    return {'maybe', item}
  end
end

local function plus(item)
  if item[1] == 'or' then
    local left = item[2]
    local right = item[3]
    return {'or', left, plus(right)}
  elseif item[1] == 'concat' then
    local left = item[2]
    local right = item[3]
    return {'concat', left, plus(right)}
  else
    return concat(item, star(item))
  end
end

local function reduce_groups(tree)
  if type(tree) == "string" then
    return tree
  elseif tree[1] == "group" then
    if tree[3] == "(?" then
      return reduce_groups(tree[2])
    else
      return{tree[1], reduce_groups(tree[2]), tree[3]}
    end
  elseif tree[1] == "star" then
    return {"star", reduce_groups(tree[2])}
  elseif tree[1] == "maybe" then
    return {"maybe", reduce_groups(tree[2])}
  else
    return {tree[1], reduce_groups(tree[2]), reduce_groups(tree[3])}
  end
end

local function parse_re(str, character_classes)
  local stack = {''}
  local parenthesis = {}
  local group_id = 1
  local classes = utils.copy(character_classes)
  for c in character_classes:tokenize(str) do
    if type(c) == 'table' then
      table.insert(classes, c)
      c = c[1]
    end
    local item = pop(stack)
    if c == "|" then
      item = introduce_or(item)
    elseif c == "*" then
      item = star(item)
    elseif c == "+" then
      item = plus(item)
    elseif c == '?' then
      item = maybe(item)
    elseif c == "(" or c == "(?" then
      push(item, stack)
      local open = c
      if open == '(' then
        open = group_id
        group_id = group_id + 1
      end
      push(open, parenthesis)
      item = ''
    elseif c == ")" then
      local open = pop(parenthesis)
      item = group(item, open)
      item = concat(pop(stack), item)
    else
      item = concat(item, c)
    end
    push(item, stack)
  end
  local cst = stack[1]
  local ast = reduce_groups(cst)
  return ast, classes
end

local function new_context()
  return {
    id = 0,
    graph = graph(),
    get = function(self, tag)
      self.id = self.id + 1
      self.graph:vertex(tostring(self.id), tag)
      return tostring(self.id)
    end,
    accept = function(self, ...)
      for _, accepted in ipairs({...}) do
        self.graph.accepted[accepted] = true
      end
    end
  }
end

local function translate_to_nfa(context, tree)
  if type(tree) == 'string' then
    local l, r = context:get(), context:get()
    context.graph:edge(l, r, tree)
    return {l, r}
  elseif tree[1] == 'maybe' then
    local l, r = context:get(), context:get()
    local l_, r_ = unpack(translate_to_nfa(context, tree[2]))
    context.graph
        :edge(l, l_, '')
        :edge(r_, r, '')
        :edge(l, r, '')
    return {l, r}
  elseif tree[1] == 'star' then
    local l, r = context:get(), context:get()
    local l_, r_ = unpack(translate_to_nfa(context, tree[2]))
    context.graph
        :edge(l, l_, '')
        :edge(r_, l_, '')
        :edge(r_, r, '')
        :edge(l, r, '')
    return {l, r}
  elseif tree[1] == 'concat' then
    local l_1, r_1 = unpack(translate_to_nfa(context, tree[2]))
    local l_2, r_2 = unpack(translate_to_nfa(context, tree[3]))
    context.graph:edge(r_1, l_2, '')
    return {l_1, r_2}
  elseif tree[1] == 'or' then
    local l, r = context:get(), context:get()
    local l_1, r_1 = unpack(translate_to_nfa(context, tree[2]))
    local l_2, r_2 = unpack(translate_to_nfa(context, tree[3]))
    context.graph
        :edge(l, l_1, '')
        :edge(l, l_2, '')
        :edge(r_1, r, '')
        :edge(r_2, r, '')
    return {l, r}
  elseif tree[1] == 'group' then
    local l, r = unpack(translate_to_nfa(context, tree[2]))
    context.graph.nodes[l] = {'open', tree[3]}
    context.graph.nodes[r] = {'close', tree[3]}
    return {l, r}
  end
end

local epsilon_closure = worklist {
  -- what is the domain? Sets of nodes
  initialize = function(self, node, _)
    return node and {[node] = true} or {}
  end,
  transfer = function(self, node, input, graph, pred)
    if not pred then return {[node] = true} end
    -- if the incoming is epsilon, then add, otherwise pass
    local tag = graph.reverse[pred][node]
    if tag == '' then
      local new = utils.copy(input)
      new[node] = true
      return new
    end
    return {[node] = true}
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
  tostring = function(self, _, node, state)
    local keys = {}
    for key in pairs(state) do
      table.insert(keys, key)
    end
    return tostring(node) .. ' {' .. table.concat(keys, ', ') .. '}'
  end,
  
  solution = {
    transitions = function(self, context, nodes, character_classes)
      local transitions = {}
      for node in pairs(nodes) do
        for succ, symbol in pairs(context.graph.forward[node]) do
          if symbol ~= '' then
            if not transitions[symbol] then transitions[symbol] = {} end
            transitions[symbol][succ] = true
          end
        end
      end
      for symbol, _ in pairs(transitions) do
        local classes = re.character_class(symbol, character_classes)
        for _, class in ipairs(classes) do
          if transitions[class] then
            for key in pairs(transitions[class]) do transitions[symbol][key] = true end
          end
        end
      end
      for symbol, nodes in pairs(transitions) do
        transitions[symbol] = self:closure(context, nodes)
      end
      return transitions
    end,
    closure = function(self, _, nodes)
      local closure = {}
      for node in pairs(nodes) do
        closure[node] = true
        for succ in pairs(self[node]) do
          closure[succ] = true
        end
      end
      return closure
    end
  }
}

local function hash(state)
  local keys = {}
  for key in pairs(state) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return table.concat(keys, ',')
end

local function subset_construction(first, last, nfa_context, character_classes, dfa_context)
  local closure = epsilon_closure:reverse(nfa_context.graph)
  if not dfa_context then dfa_context = new_context() end
  local hash_to_dfa_node = {}
  
  local function new_vertex(closure)
    local h = hash(closure)
    if hash_to_dfa_node[h] then
      return hash_to_dfa_node[h], true
    end
    local open = {}
    for node in pairs(closure) do
      if type(nfa_context.graph.nodes[node]) == 'table' then
        table.insert(open, nfa_context.graph.nodes[node])
      end
    end
    local id = dfa_context:get({closure, open})
    for k in pairs(closure) do
      if k == last then
        dfa_context:accept(id)
        break
      end
    end
    hash_to_dfa_node[h] = id
    return id, false
  end
  
  local function dfa_construction(node)
    local states, open = unpack(dfa_context.graph.nodes[node])
    local transitions = closure:transitions(nfa_context, states, character_classes)
    for symbol, nodes in pairs(transitions) do
      local succ, seen = new_vertex(nodes)
      dfa_context.graph:edge(node, succ, symbol, true)
      if not seen then
        dfa_construction(succ)
      end
    end
  end
  local start = new_vertex(closure[first])
  dfa_construction(start)
  return dfa_context
end

local function re_match(graph, str, character_classes)
  if not character_classes then character_classes = re.default_classes end
  local ptr = '1'
  local history = {ptr}
  for i = 1, #str do
    local char = string.char(str:byte(i))
    local classes = re.character_class(char, character_classes)
    local local_match = false
    for _, class in ipairs(classes) do
      if graph.forward_tags[ptr] and graph.forward_tags[ptr][class] then
        local_match = true
        assert(#graph.forward_tags[ptr][class] == 1)
        ptr = unpack(graph.forward_tags[ptr][class])
        table.insert(history, ptr)
        break;
      end
    end
    if not local_match then
      return graph:trace(history, str)
    end
  end
  return graph:trace(history, str)
end

function re.compile(pattern, character_classes)
  local regex_tree
  if not character_classes then character_classes = re.default_classes end
  regex_tree, character_classes = parse_re(pattern, character_classes)
  local nfa_context = new_context()
  local start, finish = unpack(translate_to_nfa(nfa_context, regex_tree))
  nfa_context:accept(finish)
  local dfa_context = subset_construction(start, finish, nfa_context, character_classes)
  dfa_context.graph.pattern = pattern
  function dfa_context.graph:match(str) return re_match(self, str, character_classes) end
  return dfa_context.graph
end

function re.character_class(character, character_classes)
  -- return the trace of its inheritance tree
  -- char < ... < .
  local trace = {}
  table.insert(trace, character)
  for _, class in ipairs(character_classes) do
    local sigil, equivalence_class = unpack(class)
    if type(equivalence_class) == 'table' and equivalence_class[character] then
      table.insert(trace, sigil)
    elseif type(equivalence_class) == 'function' and equivalence_class(character) then
      table.insert(trace, sigil)
    end
  end
  table.insert(trace, '.')
  return trace
end

local function classify(list)
  local set = {}
  for _, key in ipairs(list) do
    set[tostring(key)] = true
  end
  return set
end

function re.create_character_class(classes)
  local mt = {}
  function mt.tokenize(self, str)
    return function()
      if #str == 0 then
        return
      end
      for _, class in ipairs(classes) do
        local sigil = unpack(class)
        -- try to do a full match
        if str:sub(1, #sigil) == sigil then
          str = str:sub(#sigil + 1)
          return sigil
        end
      end
      for _, class in pairs(classes) do
        if type(class) == "function" then
          local match, action = class(str)
          if match then
            str = str:sub(#match + 1)
            return {match, action}
          end
        end
      end
      local c = str:sub(1,1)
      str = str:sub(2)
      if c == '(' and str:sub(1, 1) == '?' then
        c = '(?'
        str = str:sub(2)
      end
      return c
    end
  end
  setmetatable(classes, {__index = mt})
  return classes
end

local function peep(word, n)
  if n > #word then
    return nil
  end
  return word:sub(n, n)
end

re.default_classes = re.create_character_class {
  {'%d', classify {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}},
  {'%a', classify {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 
      'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
      't', 'u', 'v', 'w', 'x', 'y', 'z',
      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
      "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
      "W", "X", "Y", "Z"}},
  {'%l', classify {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 
      'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
      't', 'u', 'v', 'w', 'x', 'y', 'z'}},
  {'%u', classify {
      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
      "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
      "W", "X", "Y", "Z"}},
  {'%s', classify {' ', '\t', '\n', '\r'}},
  {'%%', classify {'%'}},
  {'%(', classify {'('}},
  {'%)', classify {')'}},
  {'%.', classify {'.'}},
  {'%+', classify {'+'}},
  {'%|', classify {'|'}},
  {'%*', classify {'*'}},
  -- Generate character classes using string keyed functions
  bracket_set_notation = function(pattern)
    -- [abc-x] or [^z]
    if pattern:sub(1,1) ~= '[' or #pattern <= 2 then return end
    local complement, start = false, 2
    if pattern:sub(2,2) == '^' then complement, start = true, 3 end
    -- find the matching ]
    local characters = {}
    local in_range = false
    for i = start, #pattern do
      local char = string.char(pattern:byte(i))
      if char == ']' then
        return pattern:sub(1, i), function(s)
          if not complement then
            return characters[s]
          else
            return not characters[s]
          end
        end
      elseif peep(pattern, i + 1) == '-' then
        in_range = char
      else
        if not in_range then
          characters[char] = true
        elseif char ~= '-' then
          -- get all of the characters between in_range and char
          assert(char >= in_range)
          for b = in_range:byte(), char:byte() do
            characters[string.char(b)] = true
          end
          in_range = false
        end
      end
    end
    return
  end,
}

return setmetatable(re, {__call = function(self, pattern, class) return self.compile(pattern, class) end})