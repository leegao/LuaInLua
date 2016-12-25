local utils = {}

function utils.copy(t)
  if type(t) ~= "table" then return t end
  local seen = {} -- for circular references
  local function _copy(t, tab)
    for k,v in pairs(t) do
      if type(v) == "table" and not v.r and not v.k and not v.v then
        if not seen[v] then 
          seen[v] = {}
          _copy(v, seen[v])
          tab[k] = seen[v]
        end
      else
        tab[k] = v
      end
    end
    
    setmetatable(tab, getmetatable(t) or {})
  end
  local tab = {}
  _copy(t, tab)
  return tab
end

function utils.to_list(set)
  local tab = {}
  for item in pairs(set) do table.insert(tab, item) end
  return setmetatable(tab, {__tostring = function(self) return table.concat(self, ', ') end})
end

function utils.to_string(list)
  return setmetatable(utils.copy(list), {__tostring = function(self) return table.concat(self, ', ') end})
end

function utils.shallow_copy(t) 
  return {table.unpack(t)} 
end

function utils.kfilter(predicate, list)
  local solution = {}
  for k, v in pairs(list) do
    if predicate(k, v) then
      solution[k] = v
    end
  end
  return solution
end

function utils.filter(predicate, list)
  local solution = {}
  for _, v in ipairs(list) do
    if predicate(v) then
      table.insert(solution, v)
    end
  end
  return solution
end

function utils.map(transform, list)
  local solution = {}
  for k, v in pairs(list) do
    solution[k] = transform(v)
  end
  return solution
end

function utils.kmap(transform, list)
  local solution = {}
  for k, v in pairs(list) do
    solution[k] = transform(k, v)
  end
  return solution
end

function utils.contains(super, sub)
  local seen = {}
  for _, v in ipairs(super) do
    seen[v] = true
  end
  for _, v in ipairs(sub) do
    if not seen[v] then return false end
  end
  return true
end

function utils.sublist(tab, i, j)
  if not j then j = 0 end
  if j <= 0 then j = #tab + j end
  if i <= 0 then i = #tab + i end
  if i <= 0 then i = 1 end
  if j <= 0 then j = 1 end
  if i > #tab then i = #tab + 1 end
  if j > #tab then j = #tab end
  -- normalize
  local list = {}
  for k = i, j do
    table.insert(list, tab[k])
  end
  return list
end

function utils.loop(tab)
  local n = #tab
  local state = 1
  return function()
    local value = tab[state]
    state = state + 1
    return value
  end
end

function utils.uloop(tab)
  local next = ipairs({})
  local state = 0
  local iter = function()
    local value
    state, value = next(tab, state)
    if value then
      if unpack(value) then
        return unpack(value)
      else
        return iter()
      end
    end
  end
  return iter
end

function utils.rloop(tab)
  local state = #tab
  return function()
    local value = tab[state]
    state = state - 1
    return value
  end
end

local function normal_escape(object)
  return ('\\%03d'):rep(#object):format(object:byte(1, #object))
end

function utils.dump(object, escape, ignore)
  if ignore == nil then ignore = true end
  if escape == nil then escape = normal_escape end
  if type(object) == 'string' then
    return '\'' .. escape(object) .. '\''
  elseif type(object) == 'number' then
    return tostring(object)
  elseif type(object) == 'function' then
    if not ignore then
      error 'Cannot serialize a function'
    end
    return 'nil'
  elseif type(object) == 'boolean' then
    return tostring(object)
  elseif object == nil then
    return 'nil'
  end
  assert(type(object) == 'table')
  local strings = {}
  for key, value in pairs(object) do
    table.insert(strings, '[' .. utils.dump(key, escape, ignore) .. '] = ' .. utils.dump(value, escape, ignore))
  end
  return '{' .. table.concat(strings, ', ') .. '}'
end

return utils