-- 3 steps: remove nullables, remove all cycles, and finally remove immediate left recursion

local left_recursion_elimination = {}

local ll1 = require 'll1'
local utils = require 'utils'

local function hash(production)
  return table.concat({unpack(production)}, '^^^')
end

local function normalize(production)
  local new = {}
  for object in utils.loop(production) do
    if object ~= '' then
      table.insert(new, object)
    end
  end
  return new
end

local function null_out(production, i, nullable_indices)
  local new = {unpack(production)}
  local changed = {}
  local index = 1
  while true do
    local okay = i % 2 == 0
    
    if okay then
      new[nullable_indices[index]] = ''
      table.insert(changed, nullable_indices[index])
    end
    
    i = math.floor(i / 2)
    if i == 0 then break end
    index = index + 1
  end
  return normalize(new)
end

local function insert_into(new_nonterminal, production, production_hashes)
  local h = hash(production)
  if not production_hashes[h] and #production ~= 0 then
    table.insert(new_nonterminal, production)
    production_hashes[h] = true
  end
end

local function eliminate_nullables(configuration)
  local nullables = {}
  for variable, nonterminal in pairs(configuration) do
    local first_set = nonterminal:first(configuration)
    if first_set[''] then
      nullables['$' .. variable] = true
    end
  end
  
  local new_actions = {}
  for variable, nonterminal in pairs(configuration) do
    -- let's construct a hashset of the original productions
    local seen_productions = {}
    for production in utils.loop(nonterminal) do
      seen_productions[hash(production)] = true
    end
    
    -- let's compute the null-eliminated expansion
    local new_nonterminal = {}
    local production_hashes = {}
    for production in utils.loop(nonterminal) do
      local action = production.action
      local nullable_indices = {}
      for i, object in ipairs(production) do
        if nullables[object] then
          table.insert(nullable_indices, i)
        end
      end
      if #nullable_indices ~= 0 then
        -- compute the combinatorial transfer to naturals
        for i=0,2^#nullable_indices - 1 do
          local new_production, changed = null_out(production, i, nullable_indices)
          insert_into(new_nonterminal, new_production, production_hashes)
        end
      else
        insert_into(new_nonterminal, normalize(production), production_hashes)
      end
    end
    new_actions[variable] = new_nonterminal
    assert(#new_nonterminal ~= 0)
  end
  return ll1.configure(new_actions)
end

-- testing
local configuration = ll1.configure {
  root = {
    {'$S'},
  },
  S = {
    {'$X', '$X'},
    {'$Y'},
  },
  X = {
    {'a', '$X', 'b'},
    {''},
  },
  Y = {
    {'a', '$Y', 'b'},
    {'$Z'},
  },
  Z = {
    {'b', '$Z', 'a'},
    {''},
  }
}

local new_configuration = eliminate_nullables(configuration)
print(new_configuration:pretty())

return left_recursion_elimination