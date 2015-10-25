-- Dumb regular expressions

-- Step 1: Parse regular expressions
-- they are of the form
--   e = x | e e | (e | e) | e*

function parse_re(str)
  local stack = {''}
  for i = 1, str:len() do
    local c = string.char(str:byte(i))
    local item = pop(stack)
    if c == "|" then
      item = introduce_or(item)
    elseif c == "*" then
      item = star(item)
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
  cst = stack[1]
  ast = reduce_groups(cst)
  --ast = reduce_concat(ast)
  return ast
end

function pop(stack)
  return table.remove(stack)
end

function push(item, stack)
  table.insert(stack, item)
end

function concat(left, right)
  if left == '' then return right end
  if left[1] == 'or' then
    local l = left[2]
    local r = left[3]
    return {'or', l, concat(r, right)}
  else
    return {'concat', left, right}
  end
end

function introduce_or(left)
  return {'or', left, ''}
end

function group(item)
  return {'group', item}
end

function star(item)
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

function reduce_groups(tree)
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

function reduce_concat_total(tree)
  if type(tree) == "string" then
    return tree
  elseif tree[1] == "star" then
    return {"star", reduce_concat(tree[2])}
  elseif tree[1] == "or" then
    return {"or", reduce_concat(tree[2]), reduce_concat(tree[3])}
  else
    local left = reduce_concat(tree[2])
    local right = reduce_concat(tree[3])
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

function new_context()
  return {
    id = 0,
    get = function(self)
      self.id = self.id + 1
      return self.id
    end
  }
end

function copy(t) 
  return {table.unpack(t)} 
end

function combine(left, right)
  for i, v in ipairs(right) do
    table.insert(left, v)
  end
  return left
end

function translate_to_nfa(context, tree)
  if type(tree) == 'string' then
    local l = context:get()
    local r = context:get()
    return {l, r, {{l, r, tree}}}
  elseif tree[1] == 'star' then
    local l = context:get()
    local r = context:get()
    local subgraph = translate_to_nfa(context, tree[2])
    local l_ = subgraph[1]
    local r_ = subgraph[2]
    local edges = subgraph[3]
    table.insert(edges, {l, l_, ''})
    table.insert(edges, {r_, l_, ''})
    table.insert(edges, {r_, r, ''})
    table.insert(edges, {l, r, ''})
    return {l, r, edges}
  elseif tree[1] == 'concat' then
    local subgraph_on_left = translate_to_nfa(context, tree[2])
    local subgraph_on_right = translate_to_nfa(context, tree[3])
    local l_1 = subgraph_on_left[1]
    local r_1 = subgraph_on_left[2]
    local l_2 = subgraph_on_right[1]
    local r_2 = subgraph_on_right[2]
    local edges = combine(subgraph_on_left[3], subgraph_on_right[3])
    table.insert(edges, {r_1, l_2, ''})
    return {l_1, r_2, edges}
  elseif tree[1] == 'or' then
    local l = context:get()
    local r = context:get()
    local subgraph_on_left = translate_to_nfa(context, tree[2])
    local subgraph_on_right = translate_to_nfa(context, tree[3])
    local l_1 = subgraph_on_left[1]
    local r_1 = subgraph_on_left[2]
    local l_2 = subgraph_on_right[1]
    local r_2 = subgraph_on_right[2]
    local edges = combine(subgraph_on_left[3], subgraph_on_right[3])
    table.insert(edges, {l, l_1, ''})
    table.insert(edges, {l, l_2, ''})
    table.insert(edges, {r_1, r, ''})
    table.insert(edges, {r_2, r, ''})
    return {l, r, edges}
  end
end

function dot(graph)
  -- collect all of the vertices
  --[[
  digraph {
    rankdir=LR;
    size="2,10"
    node [shape=circle,label=""];
    1 [label=""];
    1 -> 2[label="1"];
  }
  --]]
  local str = [[digraph {
  rankdir=LR;
  size="3"
  node[shape=circle,label=""];
]]
  for i, edge in ipairs(graph[3]) do
    local l, r, c = unpack(edge)
    str = str .. '  ' .. l .. ' -> ' .. r .. '[label="' .. c .. '"];\n'
  end
  return str .. '}'
end

x = parse_re("a(b)c|e*")
y = translate_to_nfa(new_context(), x)
print(dot(y))