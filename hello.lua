local ll1 = require 'll1.ll1'
local parser = require 'lua.parser'
local utils = require 'common.utils'
local config = ll1.configure(parser.grammar)
local re = require 'parsing.re'
--print(config:pretty())
--print(utils.to_list(config:follow('block')))
--print(config:follows():dot())
--ll1.yacc(parser.grammar)
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
--local srcs = {}
--for line in io.lines 'lua/parser.lua' do
--  table.insert(srcs, line)
--end
--debug.sethook(
--  function(...) 
--    local info = debug.getinfo(2)
--    local info2 = debug.getinfo(4)
--    if not info.name and info.short_src == './lua/parser.lua' and info2.short_src == './ll1/ll1.lua' then
--      -- print("call: " .. info.short_src .. ':' .. info.currentline .. ':')
--      local local_src = srcs[info.linedefined]
--      if local_src:sub(1, #'__GRAMMAR__.grammar["') == '__GRAMMAR__.grammar["' then
--        local _, index = debug.getlocal(4, 7)
--        local _, conf = debug.getlocal(4, 1)
--        local _, state = debug.getlocal(4, 3)
--        local production = conf.configuration[state][index]
--        print(utils.to_string(production))
--        print("call: " .. info.short_src .. ':' .. info.currentline .. ':', srcs[info.linedefined])
--      end
--    end
--  end, 
--  "c")

--local tree = parser 'function graph.vertices(self) end'

local tree = parser(io.open('ll1/ll1.lua', 'r'):read('*all'))
local ast = require 'lua.ast'

local visitor = ast {
  before = function(self, node)
    local keys = {}
    if self['on_' .. node.kind] then
      return true
    end
    for key in pairs(node) do 
      if type(key) == 'string' and key ~= 'kind' and key ~= 'parent' then 
        table.insert(keys, key) 
      end 
    end
    table.sort(keys)
    print(node.kind, unpack(keys))
  end,
  on_block = function(self, node)
    -- ret
    return true
  end,
  on_localassign = function(self, node)
    -- left, right
    return true
  end,
  on_names = function(self, node)
    -- list of leaves of Names
    return true
  end,
  on_leaf = function(self, node)
    -- tokens
    return true
  end,
  on_explist = function(self, node)
    -- list of node 'exp's
    return true
  end,
  on_table = function(self, node)
    -- list of table node 'elements'
    return true
  end,
  on_call = function(self, node)
    -- target, args
    return true
  end,
  on_args = function(self, node)
    -- list of node 'exp's
    return true
  end,
  on_unop = function(self, node)
    -- operator, operand
    return true
  end,
  on_element = function(self, node)
    -- index, value
    return true
  end,
  on_function = function(self, node)
    -- parameters, body
    return true
  end,
  on_parameters = function(self, node)
    -- list of names, vararg
    return true
  end,
  on_return = function(self, node)
    -- explist
    return true
  end,
  on_selfcall = function(self, node)
    -- target, args
    return true
  end,
  on_index = function(self, node)
    -- left, right
    return true
  end,
  on_if = function(self, node)
    -- cond, block, elseifs, else
    return true
  end,
  on_foreach = function(self, node)
    -- names, iterator, block
    return true
  end,
  on_binop = function(self, node)
    -- left, right
    return true
  end,
  on_assignments = function(self, node)
    -- left, right
    return true
  end,
  on_lvalue = function(self, node)
    -- list of lvals (primaryexp suffix*)
    return true
  end,
  on_else = function(self, node)
    -- block
    return true
  end,
  on_localfunctiondef = function(self, node)
    -- name, function
    return true
  end,
  on_functiondef = function(self, node)
    -- funcname, function
    return true
  end,
  on_funcnames = function(self, node)
    -- list of funcname*, colon
    return true
  end,
  on_empty = function(self, node)
    -- nothing
    return true
  end,
  on_elseif = function(self, node)
    -- block cond
    return true
  end,
}

visitor:accept(tree)