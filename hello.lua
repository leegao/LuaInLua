local ll1 = require 'll1'
local parser = require 'lua.parser'
local utils = require 'utils'
local config = ll1.configure(parser.grammar)
--print(config:pretty())
--print(utils.to_list(config:follow('block')))
config:follows():dot()

--print(utils.to_list(config:follow('stat\'group#3')))
ll1.yacc(parser.grammar)