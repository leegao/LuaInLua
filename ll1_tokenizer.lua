-- Frontend lexer for the parser

local lex = require 'lex'
local re = require 're'

local code_stack = {}
local function id(token) return function(...) return {token, ...} end end
local function ignore(...) return end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end

return lex.lex {
  root = {
    {'%%convert', id 'CONVERT'},
    {'%%prologue', id 'PROLOGUE'},
    {':=', id 'GETS'},
    {'|', id 'OR'},
    {re '$%a(%a|%d)*', id 'VARIABLE'},
    {re '%a(%a|%d)*', id 'IDENTIFIER'},
    
    {'{:', function(piece, lexer) lexer:go 'code'; push('', code_stack) end},
    
    {re '%s+', ignore},
    {re '/%*', function(piece, lexer) lexer:go 'comment' end},
    {re '//.*[\r\n]+', ignore}
  },
  code = {
    {':}', function(piece, lexer) 
      lexer:go 'root'
      return pop(code_stack)
    end},
    {re '.', function(piece, lexer) 
      push(pop(code_stack) .. piece, code_stack)
    end}
  },
  comment = {
    {re '%*/', function(piece, lexer) lexer:go 'root' end},
    {re '.', ignore},
  }
}