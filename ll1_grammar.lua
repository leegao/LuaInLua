-- Frontend parser for the parser
--[[--
Here's the grammar we're looking for

root := $top

convert := CONVERT CODE
production := PRODUCTION IDENTIFIER STRING
production_list := $production $production_list'
production_list' := eps | $production_list
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
  convert = {{'CONVERT', 'CODE', action = id}},
  production = {{'PRODUCTION', 'IDENTIFIER', 'STRING', action = id}},
  production_list = {
    {'$production', "$production_list'", action = id},
  },
  ['production_list\''] = {
    {'', action = id},
    {'$production_list', action = id},
  },
  valid_rhs = {{'IDENTIFIER', action = id}, {'VARIABLE', action = id}},
  rhs_list = {{'$valid_rhs', "$rhs_list'", action = id}},
  ["rhs_list'"] = {
    {'', action = id},
    {'$rhs_list', action = id},
  },
  --[[--
  single_rule := IDENTIFIER GETS $rhs_list CODE
  nonterminal := CODE $nonterminal'' | $nonterminal'
  nonterminal' := $single_rule $nonterminal''
  nonterminal'' := $nonterminal' | eps
  top := $convert $top_no_convert | $top_no_convert
  top_no_convert := $production_list $rules | $rules
  rules := $single_rule $rules'
  rules' := eps | $rules
  --]]--
  single_rule = {{'IDENTIFIER', 'GETS', '$rhs_list', 'CODE', action = id}},
  nonterminal = {
    {'CODE', "$nonterminal''", action = id},
    {"$nonterminal'", action = id},
  },
  ["nonterminal'"] = {{'$single_rule', "$nonterminal''", action = id}},
  ["nonterminal''"] = {{"$nonterminal'", action = id}, {'', action = id}},
  top = {
    {'$convert', '$top_no_convert', action = id},
    {'$top_no_convert', action = id},
  },
  top_no_convert = {
    {'$production_list', '$rules', action = id},
    {'$rules', action = id},
  },
  rules = {
    {'$single_rule', "$rules'", action = id},
  },
  ["rules'"] = {
    {'', action = id},
    {'$rules', action = id},
  }
}