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

function utils.shallow_copy(t) 
  return {table.unpack(t)} 
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

return utils