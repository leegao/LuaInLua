local ll1_tokenizer = require 'll1_tokenizer'
local ll1 = require 'll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['root'] = {[1] = {[1] = '$expr'}}, ['rexpr'] = {[1] = {[1] = ''}, [2] = {[1] = '$expr'}, [3] = {[1] = 'PLUS', [2] = '$expr'}}, ['consts'] = {[1] = {[1] = 'NUMBER'}, [2] = {[1] = 'STRING'}, [3] = {[1] = 'TRUE'}, [4] = {[1] = 'FALSE'}}, ['expr'] = {[1] = {[1] = '$consts', [2] = '$rexpr'}, [2] = {[1] = 'ID', [2] = '$rexpr'}, [3] = {[1] = 'FUN', [2] = 'ID', [3] = 'ARROW', [4] = '$expr'}, [4] = {[1] = 'LPAREN', [2] = '$expr', [3] = 'RPAREN', [4] = '$rexpr'}}}
__GRAMMAR__.grammar[1] = '/Users/leegao/sideproject/ParserSiProMo/experimental_parser.table'
__GRAMMAR__.convert = function(...) return ... end
__GRAMMAR__.prologue = function(str)
  local tokens = {}
  for token in str:gmatch("%S+") do
    table.insert(tokens, token)
  end
  return tokens
end
__GRAMMAR__.epilogue = function(...) return ... end
__GRAMMAR__.default_action = function(...) return {...} end
__GRAMMAR__.grammar.root[1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.rexpr[1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.rexpr[2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.rexpr[3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.consts[1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.consts[2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.consts[3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.consts[4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.expr[1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.expr[2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.expr[3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar.expr[4].action = __GRAMMAR__.default_action
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