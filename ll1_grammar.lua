-- Frontend parser for the parser
--[[--
Here's the grammar we're looking for

root := $top

top_opts := CONVERT CODE top_opt' | DEFAULT CODE top_opt' | PROLOGUE CODE top_opt' | EPILOGUE CODE top_opt'
top_opts' := $top_opts | eps
production := PRODUCTION IDENTIFIER $production'
production' := STRING | eps
production_list := $production $production_list'
production_list' := eps | $production_list
valid_rhs := IDENTIFIER | VARIABLE
rhs_list := $valid_rhs $rhs_list'
rhs_list' := eps | $rhs_list
single_rule := IDENTIFIER GETS $rhs_list
top := $top_opts $top_no_convert | $top_no_convert
top_no_convert := $production_list $rules | $rules
rules := $single_rule $rules'
rules' := CODE rules'' | SEMICOLON | OR $rules
rules'' := eps | OR $rules
--]]--

local ll1 = require 'll1'
local utils = require 'utils'
local tokenizer = require 'll1_tokenizer'

local id = function(...) return {...} end
local grammar = ll1 {
  '/Users/leegao/sideproject/ParserSiProMo/ll1_parsing.table',
  root = {{'$top', action = id}},
  convert = {
    {'CONVERT', 'CODE', '$convert2', action = id},
    {'DEFAULT', 'CODE', '$convert2', action = id},
    {'PROLOGUE', 'CODE', '$convert2', action = id},
    {'EPILOGUE', 'CODE', '$convert2', action = id},
    {'FILE', 'STRING', '$convert2', action = id},
    {'REQUIRE', 'STRING', '$convert2', action = id},
  },
  convert2 = {{'', action = id}, {'$convert', action = id}},
  production = {{'PRODUCTION', 'IDENTIFIER', '$production_', action = id}},
  production_ = {{'STRING', action = id}, {'', action = id}},
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
  single_rule = {{'IDENTIFIER', 'GETS', '$rhs_list', action = id}},
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
    {'CODE', "$rules''", action = id},
    {'OR', '$rules', action = id},
    {'SEMICOLON', action = id},
  },
  ["rules''"] = {
    {'', action = id},
    {'OR', '$rules', action = id},
  }
}

local function prologue(grammar, str)
  local tokens = {}
  for token in tokenizer(str) do
    table.insert(tokens, token)
  end
  return tokens
end

local function convert(token)
  return token[1]
end

local function epilogue(result)
  return result
end

local function parse(str)
  local tokens = {}
  for token in utils.loop(prologue(grammar, str)) do
    table.insert(
      tokens, 
      setmetatable(
        token, 
        {__tostring = function(self) return convert(self) end}))
  end
  local result = grammar:parse(tokens)
  return epilogue(result)
end

parse(io.open('/Users/leegao/sideproject/ParserSiProMo/parser.ylua'):read("*all"))