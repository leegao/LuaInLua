local ll1 = require 'll1.ll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['var'] = {[1] = {[1] = '$prefixexp', [2] = '[', [3] = '$exp', [4] = ']'}, [2] = {[1] = 'name'}, ['variable'] = '$var'}, ['root'] = {[1] = {[1] = '$prefixexp'}, ['variable'] = '$root'}, ['exp'] = {[1] = {[1] = '$prefixexp'}, [2] = {[1] = 'nil'}, ['variable'] = '$exp'}, ['args'] = {[1] = {[1] = '(', [2] = ')'}, ['variable'] = '$args'}, ['functioncall'] = {[1] = {[1] = '$prefixexp', [2] = '$args'}, ['variable'] = '$functioncall'}, ['prefixexp'] = {[1] = {[1] = '(', [2] = '$exp', [3] = ')'}, [2] = {[1] = '$functioncall'}, [3] = {[1] = '$var'}, ['variable'] = '$prefixexp'}}
__GRAMMAR__.grammar[1] = 'testing/elimination_parser.table'
__GRAMMAR__.convert = function(token) return token[1] end
__GRAMMAR__.prologue = function(str)
  local tokens = {}
  for token in str:gmatch("%S+") do
    table.insert(tokens, {token})
  end
  return tokens
end
__GRAMMAR__.epilogue = function(...) return ... end
__GRAMMAR__.default_action = function(...) return {...} end
__GRAMMAR__.grammar["var"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["root"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functioncall"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][3].action = __GRAMMAR__.default_action
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