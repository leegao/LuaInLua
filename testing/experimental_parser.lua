local lex = require 'lex'
local re = require 're'
local ll1 = require 'll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['expr\'star#1'] = {[1] = {[1] = 'ID', [2] = '$expr\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$expr\'star#1'}, ['expr\'group#1'] = {[1] = {[1] = 'ID'}, [2] = {[1] = '$consts'}, [3] = {[1] = 'LPAREN', [2] = '$expr', [3] = 'RPAREN'}, ['variable'] = '$expr\'group#1'}, ['expr\'plus#1'] = {[1] = {[1] = 'ID', [2] = '$expr\'star#1'}, ['variable'] = '$expr\'plus#1'}, ['expr\'maybe#1'] = {[1] = {[1] = '$expr\'group#2'}, [2] = {[1] = ''}, ['variable'] = '$expr\'maybe#1'}, ['consts'] = {[1] = {[1] = 'false'}, [2] = {[1] = 'true'}, [3] = {[1] = 'STRING'}, [4] = {[1] = 'NUMBER'}, ['variable'] = '$consts'}, ['expr'] = {[1] = {[1] = 'FUN', [2] = '$expr\'plus#1', [3] = 'ARROW', [4] = '$expr'}, [2] = {[1] = '$expr\'group#1', [2] = '$expr\'maybe#1'}, ['variable'] = '$expr'}, ['root'] = {[1] = {[1] = '$expr'}, ['variable'] = '$root'}, ['expr\'group#2'] = {[1] = {[1] = '$expr'}, [2] = {[1] = 'PLUS', [2] = '$expr'}, ['variable'] = '$expr\'group#2'}}
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
__GRAMMAR__.grammar["expr'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["expr'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["expr'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr'group#1"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr'group#1"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr'plus#1"][1].action = function(item, list)
    table.insert(list, item)
    return list
  end
__GRAMMAR__.grammar["expr'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["expr'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["consts"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["consts"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["consts"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["consts"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["root"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["expr'group#2"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.ll1 = ll1(__GRAMMAR__.grammar)
return setmetatable(
  __GRAMMAR__, 
  {__call = function(this, str)
    local tokens = {}
    for _, token in ipairs(this.prologue(str)) do
      table.insert(
        tokens, 
        setmetatable(
          token, 
          {__tostring = function(self) return this.convert(self) end}))
    end
    local result = this.ll1:parse(tokens)
    return this.epilogue(result)
  end})