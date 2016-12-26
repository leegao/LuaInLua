local ll1 = require 'll1.ll1'
local utils = require 'common.utils'

local ignore = function(...) return end
local id = function(...) 
  return setmetatable({...}, {__tostring = function(self)
    return '{' .. table.concat(utils.map(tostring, self), ', ') .. '}' 
  end})
end

-- expr = $consts rexpr' | identifier rexpr' | fun $x -> $expr | ($expr) $rexpr
-- rexpr' = EPS | $expr | + $expr
-- consts = number | string | true | false
local parser = ll1 {
--  '/Users/leegao/sideproject/ParserSiProMo/testing/test_parser.lua',
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
    {'a', '1', action = id, tag = 'a1'},
    {'a', '2', action = id, tag = 'a2'},
    conflict = {
      a = function(state, tokens)
        if tostring(tokens[2]) == '1' then
          return state:go 'a1'
        else
          return state:go 'a2'
        end
      end
    }
  }
}
local tree, trace = parser:parse{"fun", "identifier", "->", "fun", "identifier", "->", "identifier", "+", "a", "1"}

for state, token, tokens, production, args in utils.uloop(trace) do
  local args_str = args and table.concat(utils.map(tostring, args), ', ') or 'ERROR'
  local prod = (production ~= ERROR and table.concat(production, ' ')) or 'ERROR'
  print(state, table.concat(tokens, ' '))
  print('  Prod', prod, '{'..args_str..'}')
end