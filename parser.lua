local ll1 = require 'll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['funcbody'] = {[1] = {[1] = '(', [2] = '$funcbody\'maybe#1', [3] = ')', [4] = '$block', [5] = 'end'}, ['variable'] = '$funcbody'}, ['varlist\'star#1'] = {[1] = {[1] = '$varlist\'group#1', [2] = '$varlist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$varlist\'star#1'}, ['stat\'maybe#1'] = {[1] = {[1] = '$stat\'group#1'}, [2] = {[1] = ''}, ['variable'] = '$stat\'maybe#1'}, ['stat\'group#1'] = {[1] = {[1] = '=', [2] = '$explist'}, ['variable'] = '$stat\'group#1'}, ['label'] = {[1] = {[1] = '::', [2] = 'Name', [3] = '::'}, ['variable'] = '$label'}, ['functioncall'] = {[1] = {[1] = '$prefixexp', [2] = ':', [3] = 'Name', [4] = '$args'}, [2] = {[1] = '$prefixexp', [2] = 'args'}, ['variable'] = '$functioncall'}, ['stat'] = {[1] = {[1] = 'local', [2] = '$namelist', [3] = '$stat\'maybe#1'}, [2] = {[1] = 'local', [2] = 'function', [3] = 'Name', [4] = '$funcbody'}, [3] = {[1] = 'function', [2] = '$funcname', [3] = 'funcbody'}, [4] = {[1] = 'for', [2] = '$namelist', [3] = 'in', [4] = '$explist', [5] = 'do', [6] = '$block', [7] = 'end'}, [5] = {[1] = 'for', [2] = 'Name', [3] = '=', [4] = '$exp', [5] = ',', [6] = '$exp', [7] = '$stat\'maybe#2', [8] = 'do', [9] = '$block', [10] = 'end'}, [6] = {[1] = 'if', [2] = '$exp', [3] = 'then', [4] = '$block', [5] = '$stat\'star#1', [6] = '$stat\'maybe#3', [7] = 'end'}, [7] = {[1] = 'repeat', [2] = '$block', [3] = 'until', [4] = '$exp'}, [8] = {[1] = 'while', [2] = '$exp', [3] = 'do', [4] = '$block', [5] = 'end'}, [9] = {[1] = 'do', [2] = '$block', [3] = 'end'}, [10] = {[1] = 'goto', [2] = 'Name'}, [11] = {[1] = 'break'}, [12] = {[1] = '$label'}, [13] = {[1] = '$functioncall'}, [14] = {[1] = '$varlist', [2] = '=', [3] = '$explist'}, [15] = {[1] = ';'}, ['variable'] = '$stat'}, ['namelist\'star#1'] = {[1] = {[1] = '$namelist\'group#1', [2] = '$namelist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$namelist\'star#1'}, ['args'] = {[1] = {[1] = 'String'}, [2] = {[1] = '$tableconstructor'}, [3] = {[1] = '(', [2] = '$args\'maybe#1', [3] = ')'}, ['variable'] = '$args'}, ['fieldlist\'star#1'] = {[1] = {[1] = '$fieldlist\'group#1', [2] = '$fieldlist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$fieldlist\'star#1'}, ['block\'maybe#1'] = {[1] = {[1] = '$retstat'}, [2] = {[1] = ''}, ['variable'] = '$block\'maybe#1'}, ['namelist\'group#1'] = {[1] = {[1] = ',', [2] = 'Name'}, ['variable'] = '$namelist\'group#1'}, ['funcname\'group#2'] = {[1] = {[1] = ':', [2] = 'Name'}, ['variable'] = '$funcname\'group#2'}, ['varlist\'group#1'] = {[1] = {[1] = ',', [2] = '$var'}, ['variable'] = '$varlist\'group#1'}, ['args\'maybe#1'] = {[1] = {[1] = '$explist'}, [2] = {[1] = ''}, ['variable'] = '$args\'maybe#1'}, ['parlist'] = {[1] = {[1] = '...'}, [2] = {[1] = '$namelist', [2] = '$parlist\'maybe#1'}, ['variable'] = '$parlist'}, ['fieldlist\'group#1'] = {[1] = {[1] = '$fieldsep', [2] = '$field'}, ['variable'] = '$fieldlist\'group#1'}, ['parlist\'group#1'] = {[1] = {[1] = ',', [2] = '...'}, ['variable'] = '$parlist\'group#1'}, ['prefixexp'] = {[1] = {[1] = '(', [2] = '$exp', [3] = ')'}, [2] = {[1] = '$functioncall'}, [3] = {[1] = '$var'}, ['variable'] = '$prefixexp'}, ['explist'] = {[1] = {[1] = '$exp', [2] = '$explist\'star#1'}, ['variable'] = '$explist'}, ['functiondef'] = {[1] = {[1] = 'function', [2] = '$funcbody'}, ['variable'] = '$functiondef'}, ['field'] = {[1] = {[1] = '$exp'}, [2] = {[1] = 'Name', [2] = '=', [3] = '$exp'}, [3] = {[1] = '[', [2] = '$exp', [3] = ']', [4] = '=', [5] = '$exp'}, ['variable'] = '$field'}, ['varlist'] = {[1] = {[1] = '$var', [2] = '$varlist\'star#1'}, ['variable'] = '$varlist'}, ['tableconstructor\'maybe#1'] = {[1] = {[1] = '$fieldlist'}, [2] = {[1] = ''}, ['variable'] = '$tableconstructor\'maybe#1'}, ['fieldsep'] = {[1] = {[1] = ';'}, [2] = {[1] = ','}, ['variable'] = '$fieldsep'}, ['stat\'group#4'] = {[1] = {[1] = 'else', [2] = '$block'}, ['variable'] = '$stat\'group#4'}, ['fieldlist'] = {[1] = {[1] = '$field', [2] = '$fieldlist\'star#1', [3] = '$fieldlist\'maybe#1'}, ['variable'] = '$fieldlist'}, ['funcname\'maybe#1'] = {[1] = {[1] = '$funcname\'group#2'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'maybe#1'}, ['tableconstructor'] = {[1] = {[1] = '{', [2] = '$tableconstructor\'maybe#1', [3] = '}'}, ['variable'] = '$tableconstructor'}, ['block\'star#1'] = {[1] = {[1] = '$stat', [2] = '$block\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$block\'star#1'}, ['var'] = {[1] = {[1] = '$prefixexp', [2] = '.', [3] = 'Name'}, [2] = {[1] = '$prefixexp', [2] = '[', [3] = '$exp', [4] = ']'}, [3] = {[1] = 'Name'}, ['variable'] = '$var'}, ['explist\'star#1'] = {[1] = {[1] = '$explist\'group#1', [2] = '$explist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$explist\'star#1'}, ['explist\'group#1'] = {[1] = {[1] = ',', [2] = '$exp'}, ['variable'] = '$explist\'group#1'}, ['funcname'] = {[1] = {[1] = 'Name', [2] = '$funcname\'star#1', [3] = '$funcname\'maybe#1'}, ['variable'] = '$funcname'}, ['block'] = {[1] = {[1] = '$block\'star#1', [2] = '$block\'maybe#1'}, ['variable'] = '$block'}, ['root'] = {[1] = {[1] = '$block'}, ['variable'] = '$root'}, ['binop'] = {[1] = {[1] = 'or'}, [2] = {[1] = 'and'}, [3] = {[1] = '~='}, [4] = {[1] = '=='}, [5] = {[1] = '>='}, [6] = {[1] = '>'}, [7] = {[1] = '<='}, [8] = {[1] = '<'}, [9] = {[1] = '..'}, [10] = {[1] = '%'}, [11] = {[1] = '^'}, [12] = {[1] = '/'}, [13] = {[1] = '*'}, [14] = {[1] = '-'}, [15] = {[1] = '+'}, ['variable'] = '$binop'}, ['retstat\'maybe#2'] = {[1] = {[1] = ';'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#2'}, ['namelist'] = {[1] = {[1] = 'Name', [2] = '$namelist\'star#1'}, ['variable'] = '$namelist'}, ['stat\'group#3'] = {[1] = {[1] = 'elseif', [2] = '$exp', [3] = 'then', [4] = '$block'}, ['variable'] = '$stat\'group#3'}, ['parlist\'maybe#1'] = {[1] = {[1] = '$parlist\'group#1'}, [2] = {[1] = ''}, ['variable'] = '$parlist\'maybe#1'}, ['stat\'maybe#3'] = {[1] = {[1] = '$stat\'group#4'}, [2] = {[1] = ''}, ['variable'] = '$stat\'maybe#3'}, ['fieldlist\'maybe#1'] = {[1] = {[1] = '$fieldsep'}, [2] = {[1] = ''}, ['variable'] = '$fieldlist\'maybe#1'}, ['retstat'] = {[1] = {[1] = 'return', [2] = '$retstat\'maybe#1', [3] = '$retstat\'maybe#2'}, ['variable'] = '$retstat'}, ['funcbody\'maybe#1'] = {[1] = {[1] = '$parlist'}, [2] = {[1] = ''}, ['variable'] = '$funcbody\'maybe#1'}, ['unop'] = {[1] = {[1] = '#'}, [2] = {[1] = 'not'}, [3] = {[1] = '-'}, ['variable'] = '$unop'}, ['stat\'star#1'] = {[1] = {[1] = '$stat\'group#3', [2] = '$stat\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$stat\'star#1'}, ['funcname\'star#1'] = {[1] = {[1] = '$funcname\'group#1', [2] = '$funcname\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'star#1'}, ['exp'] = {[1] = {[1] = '$unop', [2] = 'exp'}, [2] = {[1] = '$exp', [2] = 'binop', [3] = '$exp'}, [3] = {[1] = '$tableconstructor'}, [4] = {[1] = '$prefixexp'}, [5] = {[1] = '$functiondef'}, [6] = {[1] = '...'}, [7] = {[1] = 'String'}, [8] = {[1] = 'Number'}, [9] = {[1] = 'true'}, [10] = {[1] = 'false'}, [11] = {[1] = 'nil'}, ['variable'] = '$exp'}, ['retstat\'maybe#1'] = {[1] = {[1] = '$explist'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#1'}, ['funcname\'group#1'] = {[1] = {[1] = '.', [2] = 'Name'}, ['variable'] = '$funcname\'group#1'}, ['stat\'group#2'] = {[1] = {[1] = ',', [2] = '$exp'}, ['variable'] = '$stat\'group#2'}, ['stat\'maybe#2'] = {[1] = {[1] = '$stat\'group#2'}, [2] = {[1] = ''}, ['variable'] = '$stat\'maybe#2'}}
__GRAMMAR__.grammar[1] = '/Users/leegao/sideproject/ParserSiProMo/parser.table'
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
__GRAMMAR__.grammar["funcbody"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["varlist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["varlist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["label"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functioncall"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functioncall"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][5].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][6].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][7].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][8].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][9].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][10].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][11].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][12].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][13].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][14].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][15].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["namelist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["namelist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["args"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["fieldlist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["block'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["block'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["namelist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["varlist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["args'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["parlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functiondef"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["varlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["tableconstructor'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["tableconstructor'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["fieldsep"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#4"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcname'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["tableconstructor"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["block'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["var"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["explist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["explist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["root"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][5].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][6].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][7].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][8].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][9].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][10].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][11].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][12].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][13].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][14].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][15].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat'maybe#2"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#2"][2].action = function() return {} end
__GRAMMAR__.grammar["namelist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#3"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["parlist'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'maybe#3"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'maybe#3"][2].action = function() return {} end
__GRAMMAR__.grammar["fieldlist'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["fieldlist'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["retstat"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcbody'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcbody'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["unop"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["stat'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["funcname'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["funcname'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][5].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][6].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][7].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][8].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][9].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][10].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][11].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["funcname'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'maybe#2"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'maybe#2"][2].action = function() return {} end
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