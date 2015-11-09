local lex = require 'lex'
local re = require 're'
local ll1 = require 'll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['rexpr'] = {[1] = {[1] = ''}, [2] = {[1] = '$expr'}, [3] = {[1] = '+', [2] = '$expr'}}, ['root'] = {[1] = {[1] = '$expr'}}, ['consts'] = {[1] = {[1] = 'NUMBER'}, [2] = {[1] = 'STRING'}, [3] = {[1] = 'TRUE'}, [4] = {[1] = 'FALSE'}}, ['expr'] = {[1] = {[1] = '$consts', [2] = '$rexpr'}, [2] = {[1] = 'ID', [2] = '$rexpr'}, [3] = {[1] = 'FUN', [2] = 'ID', [3] = 'ARROW', [4] = '$expr'}, [4] = {[1] = 'LPAREN', [2] = '$expr', [3] = 'RPAREN', [4] = '$rexpr'}}}
__GRAMMAR__.grammar[1] = '/Users/leegao/sideproject/ParserSiProMo/testing/experimental_parser.table'
local string_stack = {}
local function id(token) return function(...) return {token, ...} end end
local function ignore(...) return end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end
local tokenizer = lex.lex {
  root = {
    {'+', id 'PLUS'},
    {'fun', id 'FUN'},
    {'->', id 'ARROW'},
    {'(', id 'LPAREN'},
    {')', id 'RPAREN'},
    {re '%s+', ignore},
    {re '%d+', id 'NUMBER'},
    {re '%d+%.%d+', id 'NUMBER'},
    {re '(%a|_)(%a|%d|_|\')*', id 'ID'},
    {'"', function(piece, lexer) lexer:go 'string'; push('', string_stack) end},
  },
  string = {
    {'"', function(piece, lexer) 
      lexer:go 'root'
      return {'STRING', pop(string_stack)}
    end},
    {re '.', function(piece, lexer) 
      push(pop(string_stack) .. piece, string_stack)
    end}
  },
}
local take2 = function(token) return {kind = 'tok', unpack(token, 1, 2)} end
  local last = function(...) return select(select('#', ...), ...) end
  local function rexpr(left, pair)
    local kind, right = unpack(pair)
    if not kind then return left end
    return {kind = kind, left, right}
  end
__GRAMMAR__.convert = function(token)
    return token[1]
  end
__GRAMMAR__.prologue = function(stream)
    local tokens = {}
    for token in tokenizer(stream) do
      table.insert(tokens, token)
    end
    return tokens
  end
__GRAMMAR__.epilogue = function(result)
    return result
  end
__GRAMMAR__.default_action = function(item)
    return item
  end
__GRAMMAR__.grammar["rexpr"][1].action = function(_1)
    return  {} 
  end
__GRAMMAR__.grammar["rexpr"][2].action = function(_1)
    return  {'app', _1} 
  end
__GRAMMAR__.grammar["rexpr"][3].action = function(_1, _2)
    return  {'plus', _2} 
  end
__GRAMMAR__.grammar["root"][1].action = function(_1)
    return _1
  end
__GRAMMAR__.grammar["consts"][1].action = function(_1)
    return  take2(_1) 
  end
__GRAMMAR__.grammar["consts"][2].action = function(_1)
    return  take2(_1) 
  end
__GRAMMAR__.grammar["consts"][3].action = function(_1)
    return  take2(_1) 
  end
__GRAMMAR__.grammar["consts"][4].action = function(_1)
    return  take2(_1) 
  end
__GRAMMAR__.grammar["expr"][1].action = function(_1, _2)
    return  rexpr(_1, _2) 
  end
__GRAMMAR__.grammar["expr"][2].action = function(_1, _2)
    return  rexpr(take2(_1), _2) 
  end
__GRAMMAR__.grammar["expr"][3].action = function(_1, _2, _3, _4)
    return  {kind = 'fun', take2(_2), _4} 
  end
__GRAMMAR__.grammar["expr"][4].action = function(_1, _2, _3, _4)
    return  rexpr(_2, _4) 
  end
__GRAMMAR__.ll1 = ll1(__GRAMMAR__.grammar)
return function(str)
  local tokens = {}
  for _, token in ipairs(__GRAMMAR__.prologue(str)) do
    table.insert(
      tokens, 
      setmetatable(
        token, 
        {__tostring = function(self) return __GRAMMAR__.convert(self) end}))
  end
  local result = __GRAMMAR__.ll1:parse(tokens)
  return __GRAMMAR__.epilogue(result)
end