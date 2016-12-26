local lex = require "parsing.lex"
local re = require "parsing.re"
local r = re.compile

local string_stack = {}
local function id(...) return ... end
local function ignore(...) return end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end
local tokenizer = lex.lex {
  root = {
    {'if',  id},
    {'else', id},
    {'then', id},
    {'(', id},
    {')', id},
    {r '%s+', ignore},
    {r '%a(%a|%d)*', id},
    {r '%d+', id},
    {'"', function(piece, lexer) 
      lexer:go 'string'
      push(piece, string_stack)
    end},
    {r '/%*', function(piece, lexer) lexer:go 'comment' end},
  },
  string = {
    {'"', function(piece, lexer) 
      lexer:go 'root'
      return pop(string_stack) .. piece
    end},
    {r '.', function(piece, lexer) 
      push(pop(string_stack) .. piece, string_stack)
    end}
  },
  comment = {
    {r '%*/', function(piece, lexer) lexer:go 'root' end},
    {r '.', ignore},
  }
}

for token in tokenizer('if lol32 then func(1) else  /* omg */ "abcd"') do
  print(token)
end
