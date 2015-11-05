-- 3 steps: remove nullables, remove all cycles, and finally remove immediate left recursion

local left_recursion_elimination = {}

local ll1 = require 'll1'
local utils = require 'utils'

local function hash_function(production)
  return utils.dump {unpack(production)}
end

local function eliminate_nullables(configuration)
  local nullables = {}
  for variable, nonterminal in pairs(configuration) do
    local first_set = nonterminal:first(configuration)
    if first_set[''] then
      nullables[variable:sub(2)] = true
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