local parser = require "testing.elimination_parser"
local ll1 = require 'll1.ll1'
local elimination = require 'll1.elimination'

local config = ll1.configure(parser.grammar)
print(config:pretty())
local new_config = elimination.eliminate_cycles(config)
--print(new_config:pretty())
local no_rec = elimination.indirect_elimination(new_config)
print()
print(no_rec:pretty())
ll1(no_rec)