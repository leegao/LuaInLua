-- Frontend parser for the parser
--[[--
Here's the grammar we're looking for

root := $top

convert := CONVERT CODE
production := PRODUCTION IDENTIFIER STRING
production_list := $production $production_opt_list | $production
valid_rhs := IDENTIFIER | VARIABLE
rhs_list := $valid_rhs $rhs_list'
rhs_list' := eps | $rhs_list
single_rule := IDENTIFIER GETS $rhs_list CODE
nonterminal := CODE $nonterminal'' | $nonterminal'
nonterminal' := $single_rule nonterminal'
nonterminal'' := $nonterminal' | eps
top := $convert $top_no_convert | $top_no_convert
top_no_convert := $production_list $rules | $rules
rules := $single_rule $rules'
rules' := eps | $rules
--]]--

local ll1 = require 'll1'
local tokenizer = require 'll1_tokenizer'

local id = function(...) return {...} end
local grammar = ll1 {
  root = {{'$top', action = id}},
  convert = {{'CONVERT', 'CODE'}, action = id},
}