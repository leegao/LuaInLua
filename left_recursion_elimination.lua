-- 3 steps: remove nullables, remove all cycles, and finally remove immediate left recursion

local left_recursion_elimination = {}

local ll1 = require 'll1'
local utils = require 'utils'

local function hash(production)
  return utils.dump {unpack(production)}
end

local function eliminate_nullables(configuration)
  local nullables = {}
  for variable, nonterminal in pairs(configuration) do
    local first_set = nonterminal:first(configuration)
    if first_set[''] then
      nullables['$' .. variable] = true
    end
  end
  
  for variable, nonterminal in pairs(configuration) do
    -- let's construct a hashset of the original productions
    local seen_productions = {}
    for production in utils.loop(nonterminal) do
      seen_productions[hash(production)] = true
    end
    
    -- let's compute the null-eliminated expansion
    for production in utils.loop(nonterminal) do
      local action = production.action
      local nullable_indices = {}
      for i, object in ipairs(production) do
        if nullables[object] then
          table.insert(nullable_indices, i)
        end
      end
      -- compute the combinatorial transfer to naturals
      print(variable, table.concat(production, ' '))
      for i=0,2^#nullable_indices - 2 do
        print(i)
      end
    end
  end
end

-- testing
local configuration = ll1.configure {
  root = {
    {'$expr', action = id},
  },
  rexpr = {
    {'', action = id},
    {'$expr', action = id},
    {'+', '$expr', action = id},
  },
  expr = {
    {'$consts', '$rexpr', action = id},
    {'identifier', '$rexpr', action = id},
    {'fun', 'identifier', '->', '$expr', action = id},
    {'(', '$expr', ')', '$rexpr', action = id},
  },
  consts = {
    {'number', action = id},
    {'string', action = id},
    {'true', action = id},
    {'false', action = id},
  }
}

eliminate_nullables(configuration)

return left_recursion_elimination