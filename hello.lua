-- local ll1 = require 'll1.ll1'
local parser = require 'luainlua.lua.parser'
local utils = require 'luainlua.common.utils'
local re = require 'luainlua.parsing.re'
local undump = require 'luainlua.bytecode.undump'

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

local luac = require "luainlua.luac"
local dump = require "luainlua.bytecode.dump"
local undump = require "luainlua.bytecode.undump"

--local prototype = undump.undump(function(...) print(...) end)
--for pc, op in ipairs(prototype.code) do
--  print(pc, op)
--end
--
--local foo, bytecode, prototype, dumper = luac "testing/hello_world.lua"
--dumper()
--foo()

local compiler, bytecode, prototype, dumper = luac.luac "luainlua/lua/compiler.lua"
-- dumper()
compiler = compiler()
local tree = parser(io.open("luainlua/lua/compiler.lua", 'r'):read('*all'))
local prototype = compiler(tree)
local bytecode = dump.dump(prototype)
local compiler, err = loadstring(tostring(bytecode))
compiler = compiler()
local tree = parser(io.open("luainlua/lua/compiler.lua", 'r'):read('*all'))
local prototype = compiler(tree)
local bytecode = dump.dump(prototype)
local compiler, err = loadstring(tostring(bytecode))
compiler = compiler()
local tree = parser(io.open("luainlua/testing/hello_world.lua", 'r'):read('*all'))
local prototype = compiler(tree)
local bytecode = dump.dump(prototype)
local func, err = loadstring(tostring(bytecode))
func()
--local foo = luac "testing/hello_world.lua"
--foo()