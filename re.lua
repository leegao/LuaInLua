-- Dumb regular expressions

-- Step 1: Parse regular expressions
-- they are of the form
--   e = x | e e | (e | e) | e* | e+


local graph = require "graph"
local utils = require "utils"
local worklist = require "worklist"

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

local function group(item)
  return {'group', item}
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
    return reduce_groups(tree[2])
  elseif tree[1] == "star" then
    return {"star", reduce_groups(tree[2])}
  else
    return {tree[1], reduce_groups(tree[2]), reduce_groups(tree[3])}
  end
end


local function parse_re(str)
  local stack = {''}
  for i = 1, str:len() do
    local c = string.char(str:byte(i))
    local item = pop(stack)
    if c == "|" then
      item = introduce_or(item)
    elseif c == "*" then
      item = star(item)
    elseif c == "+" then
      item = plus(item)
    elseif c == "(" then
      push(item, stack)
      item = ''
    elseif c == ")" then
      item = group(item)
      item = concat(pop(stack), item)
    else
      item = concat(item, c)
    end
    push(item, stack)
  end
  local cst = stack[1]
  local ast = reduce_groups(cst)
  --ast = reduce_concat(ast)
  return ast
end

local function reduce_concat_total(tree)
  if type(tree) == "string" then
    return tree
  elseif tree[1] == "star" then
    return {"star", reduce_concat_total(tree[2])}
  elseif tree[1] == "or" then
    return {"or", reduce_concat_total(tree[2]), reduce_concat_total(tree[3])}
  else
    local left = reduce_concat_total(tree[2])
    local right = reduce_concat_total(tree[3])
    -- either c, c -> cc or 
    -- cat(., c), c -> cat(., cc) or 
    -- c, cat(c, .) -> cat(cc, .) or 
    -- cat(., c), cat(c, .) -> cat(cat(., cc), .)
    if type(left) == "string" and type(right) == "string" then
      return left .. right
    elseif left[1] == "concat" and type(left[3]) == "string" and type(right) == "string" then
      return {"concat", left[2], left[3] .. right}
    elseif right[1] == "concat" and type(right[2]) == "string" and type(left) == "string" then
      return {"concat", left .. right[2], right[3]}
    elseif left[1] == "concat" and right[1] == "concat" and type(left[3]) == "string" and type(right[2]) == "string" then
      return {"concat", {"concat", left[2], left[3] .. right[2]}, right[3]}
    end
  end
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
  end
end

local epsilon_closure = worklist {
  -- what is the domain? Sets of nodes
  initialize = function(self, node, _)
    return {[node] = true}
  end,
  transfer = function(self, node, input, graph, pred)
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
    transitions = function(self, context, nodes)
      local transitions = {}
      for node in pairs(nodes) do
        for succ, symbol in pairs(context.graph.forward[node]) do
          if symbol ~= '' then
            if not transitions[symbol] then transitions[symbol] = {} end
            transitions[symbol][succ] = true
          end
        end
      end
      for symbol, successors in pairs(transitions) do
        local classes = re.character_class(symbol)
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

local function subset_construction(first, last, nfa_context, dfa_context)
  local closure = epsilon_closure:reverse(nfa_context.graph)
  if not dfa_context then dfa_context = new_context() end
  local hash_to_dfa_node = {}
  
  local function hash(state)
    local keys = {}
    for key in pairs(state) do
      table.insert(keys, key)
    end
    table.sort(keys)
    return table.concat(keys, ',')
  end
  
  local function new_vertex(closure)
    local h = hash(closure)
    if hash_to_dfa_node[h] then
      return hash_to_dfa_node[h], true
    end
    local id = dfa_context:get(closure)
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
    local states = dfa_context.graph.nodes[node]
    local transitions = closure:transitions(nfa_context, states)
    for symbol, nodes in pairs(transitions) do
      local succ, seen = new_vertex(nodes)
      dfa_context.graph:edge(node, succ, symbol)
      if not seen then
        dfa_construction(succ)
      end
    end
  end
  local start = new_vertex(closure[first])
  dfa_construction(start)
  return dfa_context
end

function re.compile(pattern)
  local regex_tree = parse_re(pattern)
  local nfa_context = new_context()
  local start, finish = unpack(translate_to_nfa(nfa_context, regex_tree))
  nfa_context:accept(finish)
  local dfa_context = subset_construction(start, finish, nfa_context)
  return dfa_context.graph
end

function re.character_class(character)
  -- return the trace of its inheritance tree
  -- char < ... < .
  local trace = {}
  table.insert(trace, character)
  
  table.insert(trace, '.')
  return trace
end

return re