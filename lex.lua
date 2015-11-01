-- Use regular expressions to compile and construct a tokenizer
-- A tokenizer is an iterator over strings

local lex = {}
local re = require "re"
r = re.compile

function lex.lex(actions)
  -- action maps a name -> regex -> action function
  -- think of it as a giant alternation that takes ordering into consideration
  
end

local lexer = lex.lex {
  root = {
    {'if',  function(piece, lexer) end},
    {'else', function(piece, lexer) end},
    {r '%s', function(piece, lexer) end},
    {'"', function(piece, lexer) lexer.go 'string' end},
  },
  string = {
    {'"', function(piece, lexer) lexer.go 'root' end}
  },
}



return lex