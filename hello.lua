local ll1 = require 'll1.ll1'
local parser = require 'lua.parser'
local utils = require 'common.utils'
local config = ll1.configure(parser.grammar)
--print(config:pretty())
--print(utils.to_list(config:follow('block')))
--print(config:follows():dot())
ll1.yacc(parser.grammar)
-- print(utils.to_list(config:get_dependency_graph().reverse['suffixedexp\'star#1']))
--print(utils.to_list(config:first('stat')))

--local seen = {['suffixedexp\'star#1'] = true}
--for node, _, forward, reverse in config:get_dependency_graph():reverse_dfs('suffixedexp\'star#1') do
--  if seen[node] then
--    print(node)
--    for rev, tag in pairs(reverse) do
--      for suffix in pairs(tag) do
--        local first = ll1.first(config, suffix)
--        if first[''] then 
--          print('', rev, utils.to_string(suffix))
--          seen[rev] = true 
--        end
--        if first['LBRACE'] or first['String'] or first['LBRACK'] or first['LPAREN'] then
--          if not first[''] then print('', rev, utils.to_string(suffix)) end
--          print('', '', utils.to_list(ll1.first(config, suffix)))
--        end
--      end
--    end
--  end
--end

--ll1.yacc(parser.grammar)
parser "RETURN LBRACE Number PLUS Number RBRACE"