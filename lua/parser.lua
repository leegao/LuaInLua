local ll1 = require 'll1.ll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['stat\'group#2\'maybe#1'] = {[1] = {[1] = '$stat\'group#2\'group#1'}, [2] = {[1] = ''}, ['variable'] = '$stat\'group#2\'maybe#1'}, ['suffixedexp\'star#1'] = {[1] = {[1] = '$suffixedexp\'group#1', [2] = '$suffixedexp\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$suffixedexp\'star#1'}, ['parlist'] = {[1] = {[1] = '...'}, [2] = {[1] = '$parlist\'plus#1', [2] = '$parlist\'group#2'}, ['variable'] = '$parlist'}, ['stat\'group#3'] = {[1] = {[1] = 'elseif', [2] = '$exp', [3] = 'then', [4] = '$block'}, ['variable'] = '$stat\'group#3'}, ['suffixedexp\'group#1'] = {[1] = {[1] = '$args'}, [2] = {[1] = ':', [2] = 'Name', [3] = '$args'}, [3] = {[1] = '[', [2] = '$exp', [3] = ']'}, [4] = {[1] = '.', [2] = 'Name'}, ['variable'] = '$suffixedexp\'group#1'}, ['exp'] = {[1] = {[1] = '$exp\'group#1', [2] = '$binop', [3] = '$exp'}, ['variable'] = '$exp'}, ['stat\'group#1'] = {[1] = {[1] = '$namelist', [2] = '$stat\'group#1\'maybe#1'}, [2] = {[1] = 'function', [2] = 'Name', [3] = '$funcbody'}, ['variable'] = '$stat\'group#1'}, ['binop'] = {[1] = {[1] = 'or'}, [2] = {[1] = 'and'}, [3] = {[1] = '~='}, [4] = {[1] = '=='}, [5] = {[1] = '>='}, [6] = {[1] = '>'}, [7] = {[1] = '<='}, [8] = {[1] = '<'}, [9] = {[1] = '..'}, [10] = {[1] = '%'}, [11] = {[1] = '^'}, [12] = {[1] = '/'}, [13] = {[1] = '*'}, [14] = {[1] = '-'}, [15] = {[1] = '+'}, ['variable'] = '$binop'}, ['assignment'] = {[1] = {[1] = '=', [2] = '$explist'}, [2] = {[1] = ',', [2] = '$suffixedexp', [3] = '$assignment'}, ['variable'] = '$assignment'}, ['functiondef'] = {[1] = {[1] = 'function', [2] = '$funcbody'}, ['variable'] = '$functiondef'}, ['assignment_or_call\'maybe#1'] = {[1] = {[1] = '$assignment'}, [2] = {[1] = ''}, ['variable'] = '$assignment_or_call\'maybe#1'}, ['stat\'star#1'] = {[1] = {[1] = '$stat\'group#3', [2] = '$stat\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$stat\'star#1'}, ['explist'] = {[1] = {[1] = '$exp', [2] = '$explist\'star#1'}, ['variable'] = '$explist'}, ['funcname'] = {[1] = {[1] = 'Name', [2] = '$funcname\'star#1', [3] = '$funcname\'maybe#1'}, ['variable'] = '$funcname'}, ['stat\'maybe#1'] = {[1] = {[1] = '$stat\'group#4'}, [2] = {[1] = ''}, ['variable'] = '$stat\'maybe#1'}, ['tableconstructor\'maybe#1'] = {[1] = {[1] = '$fieldlist'}, [2] = {[1] = ''}, ['variable'] = '$tableconstructor\'maybe#1'}, ['assignment_or_call\'star#1'] = {[1] = {[1] = '$assignment_or_call\'group#1', [2] = '$assignment_or_call\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$assignment_or_call\'star#1'}, ['assignment_or_call\'group#1'] = {[1] = {[1] = '$args', ['tag'] = 'call'}, [2] = {[1] = ':', [2] = 'Name', [3] = '$args'}, [3] = {[1] = '[', [2] = '$exp', [3] = ']'}, [4] = {[1] = '.', [2] = 'Name'}, ['variable'] = '$assignment_or_call\'group#1'}, ['assignment_or_call'] = {[1] = {[1] = '$primaryexp', [2] = '$assignment_or_call\'star#1', [3] = '$assignment_or_call\'maybe#1'}, ['variable'] = '$assignment_or_call'}, ['fieldlist'] = {[1] = {[1] = '$field', [2] = '$fieldlist\'star#1'}, ['variable'] = '$fieldlist'}, ['funcbody'] = {[1] = {[1] = '(', [2] = '$funcbody\'maybe#1', [3] = ')', [4] = '$block', [5] = 'end'}, ['variable'] = '$funcbody'}, ['explist\'star#1'] = {[1] = {[1] = '$explist\'group#1', [2] = '$explist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$explist\'star#1'}, ['stat\'group#4'] = {[1] = {[1] = 'else', [2] = '$block'}, ['variable'] = '$stat\'group#4'}, ['parlist\'group#2'] = {[1] = {[1] = '...'}, [2] = {[1] = 'Name'}, ['variable'] = '$parlist\'group#2'}, ['parlist\'plus#1'] = {[1] = {[1] = '$parlist\'group#1', [2] = '$parlist\'star#1'}, ['variable'] = '$parlist\'plus#1'}, ['stat\'group#1\'maybe#1'] = {[1] = {[1] = '$stat\'group#1\'group#1'}, [2] = {[1] = ''}, ['variable'] = '$stat\'group#1\'maybe#1'}, ['parlist\'star#1'] = {[1] = {[1] = '$parlist\'group#1', [2] = '$parlist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$parlist\'star#1'}, ['retstat\'maybe#1'] = {[1] = {[1] = '$explist'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#1'}, ['funcname\'maybe#1'] = {[1] = {[1] = '$funcname\'group#2'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'maybe#1'}, ['exp\'group#1'] = {[1] = {[1] = '$unop', [2] = 'exp'}, [2] = {[1] = '$tableconstructor'}, [3] = {[1] = '$suffixedexp'}, [4] = {[1] = '$functiondef'}, [5] = {[1] = '...'}, [6] = {[1] = 'String'}, [7] = {[1] = 'Number'}, [8] = {[1] = 'true'}, [9] = {[1] = 'false'}, [10] = {[1] = 'nil'}, ['variable'] = '$exp\'group#1'}, ['field'] = {[1] = {[1] = '$exp', ['tag'] = 'exp'}, [2] = {[1] = 'Name', [2] = '=', [3] = '$exp', ['tag'] = 'assign'}, [3] = {[1] = '[', [2] = '$exp', [3] = ']', [4] = '=', [5] = '$exp'}, ['variable'] = '$field'}, ['funcbody\'maybe#1'] = {[1] = {[1] = '$parlist'}, [2] = {[1] = ''}, ['variable'] = '$funcbody\'maybe#1'}, ['tableconstructor'] = {[1] = {[1] = '{', [2] = '$tableconstructor\'maybe#1', [3] = '}'}, ['variable'] = '$tableconstructor'}, ['suffixedexp'] = {[1] = {[1] = '$primaryexp', [2] = '$suffixedexp\'star#1'}, ['variable'] = '$suffixedexp'}, ['fieldlist\'group#1'] = {[1] = {[1] = '$fieldsep', [2] = '$field'}, ['variable'] = '$fieldlist\'group#1'}, ['stat\'group#2'] = {[1] = {[1] = '$namelist', [2] = 'in', [3] = '$explist', [4] = 'do', [5] = '$block', [6] = 'end', ['tag'] = 'foreach'}, [2] = {[1] = 'Name', [2] = '=', [3] = '$exp', [4] = ',', [5] = '$exp', [6] = '$stat\'group#2\'maybe#1', [7] = 'do', [8] = '$block', [9] = 'end', ['tag'] = 'forcounter'}, ['variable'] = '$stat\'group#2'}, ['args\'maybe#1'] = {[1] = {[1] = '$explist'}, [2] = {[1] = ''}, ['variable'] = '$args\'maybe#1'}, ['retstat'] = {[1] = {[1] = 'return', [2] = '$retstat\'maybe#1', [3] = '$retstat\'maybe#2'}, ['variable'] = '$retstat'}, ['block'] = {[1] = {[1] = '$block\'star#1'}, ['variable'] = '$block'}, ['namelist\'star#1'] = {[1] = {[1] = '$namelist\'group#1', [2] = '$namelist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$namelist\'star#1'}, ['namelist\'group#1'] = {[1] = {[1] = ',', [2] = 'Name'}, ['variable'] = '$namelist\'group#1'}, ['unop'] = {[1] = {[1] = '#'}, [2] = {[1] = 'not'}, [3] = {[1] = '-'}, ['variable'] = '$unop'}, ['namelist'] = {[1] = {[1] = 'Name', [2] = '$namelist\'star#1'}, ['variable'] = '$namelist'}, ['args'] = {[1] = {[1] = 'String'}, [2] = {[1] = '$tableconstructor'}, [3] = {[1] = '(', [2] = '$args\'maybe#1', [3] = ')'}, ['variable'] = '$args'}, ['root'] = {[1] = {[1] = '$block'}, ['variable'] = '$root'}, ['parlist\'group#1'] = {[1] = {[1] = 'Name', [2] = ',', ['tag'] = 'namelist'}, ['variable'] = '$parlist\'group#1'}, ['stat'] = {[1] = {[1] = 'local', [2] = '$stat\'group#1'}, [2] = {[1] = 'function', [2] = '$funcname', [3] = '$funcbody'}, [3] = {[1] = 'for', [2] = '$stat\'group#2'}, [4] = {[1] = 'if', [2] = '$exp', [3] = 'then', [4] = '$block', [5] = '$stat\'star#1', [6] = '$stat\'maybe#1', [7] = 'end'}, [5] = {[1] = 'repeat', [2] = '$block', [3] = 'until', [4] = '$exp'}, [6] = {[1] = 'while', [2] = '$exp', [3] = 'do', [4] = '$block', [5] = 'end'}, [7] = {[1] = 'do', [2] = '$block', [3] = 'end'}, [8] = {[1] = 'goto', [2] = 'Name'}, [9] = {[1] = 'break'}, [10] = {[1] = '$label'}, [11] = {[1] = '$assignment_or_call'}, [12] = {[1] = ';'}, ['variable'] = '$stat'}, ['stat\'group#1\'group#1'] = {[1] = {[1] = '=', [2] = '$explist'}, ['variable'] = '$stat\'group#1\'group#1'}, ['stat\'group#2\'group#1'] = {[1] = {[1] = ',', [2] = '$exp'}, ['variable'] = '$stat\'group#2\'group#1'}, ['funcname\'group#2'] = {[1] = {[1] = ':', [2] = 'Name'}, ['variable'] = '$funcname\'group#2'}, ['funcname\'group#1'] = {[1] = {[1] = '.', [2] = 'Name'}, ['variable'] = '$funcname\'group#1'}, ['block\'star#1'] = {[1] = {[1] = '$stat', [2] = '$block\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$block\'star#1'}, ['funcname\'star#1'] = {[1] = {[1] = '$funcname\'group#1', [2] = '$funcname\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'star#1'}, ['primaryexp'] = {[1] = {[1] = '(', [2] = '$exp', [3] = ')'}, [2] = {[1] = 'Name'}, ['variable'] = '$primaryexp'}, ['fieldlist\'star#1'] = {[1] = {[1] = '$fieldlist\'group#1', [2] = '$fieldlist\'star#1'}, [2] = {[1] = ''}, ['variable'] = '$fieldlist\'star#1'}, ['label'] = {[1] = {[1] = '::', [2] = 'Name', [3] = '::'}, ['variable'] = '$label'}, ['explist\'group#1'] = {[1] = {[1] = ',', [2] = '$exp'}, ['variable'] = '$explist\'group#1'}, ['fieldsep'] = {[1] = {[1] = ';'}, [2] = {[1] = ','}, ['variable'] = '$fieldsep'}, ['retstat\'maybe#2'] = {[1] = {[1] = ';'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#2'}}
__GRAMMAR__.grammar[1] = 'lua/parser.table'
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
__GRAMMAR__.grammar["stat'group#2'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'group#2'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["suffixedexp'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["suffixedexp'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["parlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#3"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["suffixedexp'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["suffixedexp'group#1"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["suffixedexp'group#1"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["suffixedexp'group#1"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#1"][2].action = __GRAMMAR__.default_action
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
__GRAMMAR__.grammar["assignment"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functiondef"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment_or_call'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["assignment_or_call'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["stat'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["explist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["tableconstructor'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["tableconstructor'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["assignment_or_call'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["assignment_or_call'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["assignment_or_call'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment_or_call'group#1"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment_or_call'group#1"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment_or_call'group#1"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["assignment_or_call"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcbody"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["explist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'group#4"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'group#2"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'plus#1"][1].action = function(item, list)
    table.insert(list, item)
    return list
  end
__GRAMMAR__.grammar["stat'group#1'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'group#1'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["parlist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["parlist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["retstat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["funcname'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcname'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][5].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][6].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][7].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][8].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][9].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["exp'group#1"][10].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcbody'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcbody'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["tableconstructor"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["suffixedexp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#2"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["args'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["retstat"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["namelist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["namelist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["namelist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["namelist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["root"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist'group#1"][1].action = __GRAMMAR__.default_action
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
__GRAMMAR__.grammar["stat'group#1'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat'group#2'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname'group#2"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["block'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["funcname'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["funcname'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["primaryexp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["primaryexp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist'star#1"][1].action = function(item, list) table.insert(list, item); return list end
__GRAMMAR__.grammar["fieldlist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["label"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist'group#1"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat'maybe#2"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#2"][2].action = function() return {} end
__GRAMMAR__.grammar["parlist'star#1"].conflict = {}
__GRAMMAR__.grammar["parlist'star#1"].conflict["Name"] =  function(self, tokens)
  if tokens[2] == ',' then
    return self:go 'namelist'
  else
    return self:go ''
  end
end 
__GRAMMAR__.grammar["assignment_or_call'star#1"].conflict = {}
__GRAMMAR__.grammar["assignment_or_call'star#1"].conflict["("] =  function(self, tokens)
  -- always reduce to call
  return self:go 'call'
end 
__GRAMMAR__.grammar["stat'group#2"].conflict = {}
__GRAMMAR__.grammar["stat'group#2"].conflict["Name"] =  function(self, tokens)
  if tokens[2] == '=' then
    return self:go 'forcounter'
  else
    return self:go 'foreach'
  end
end 
__GRAMMAR__.grammar["field"].conflict = {}
__GRAMMAR__.grammar["field"].conflict["Name"] =  function(self, tokens)
  if tokens[2] == '=' then
    return self:go 'assign'
  else
    return self:go 'exp'
  end
end 
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