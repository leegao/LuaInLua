local ll1 = require 'll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['else_opt'] = {[1] = {[1] = 'else', [2] = '$block'}}, ['comma_exp_opt'] = {[1] = {[1] = ',', [2] = '$exp'}}, ['label'] = {[1] = {[1] = '::', [2] = 'Name', [3] = '::'}}, ['semicolon_opt'] = {[1] = {[1] = ';'}}, ['unop'] = {[1] = {[1] = '-'}, [2] = {[1] = 'not'}, [3] = {[1] = '#'}, [4] = {[1] = '~'}}, ['block'] = {[1] = {[1] = '$stat_list'}, [2] = {[1] = '$stat_list', [2] = '$retstat_opt'}}, ['field'] = {[1] = {[1] = '[', [2] = '$exp', [3] = ']', [4] = '=', [5] = '$exp'}, [2] = {[1] = 'Name', [2] = '=', [3] = '$exp'}, [3] = {[1] = '$exp'}}, ['exp'] = {[1] = {[1] = 'nil'}, [2] = {[1] = 'false'}, [3] = {[1] = 'true'}, [4] = {[1] = 'Numeral'}, [5] = {[1] = 'LiteralString'}, [6] = {[1] = '...'}, [7] = {[1] = '$functiondef'}, [8] = {[1] = '$prefixexp'}, [9] = {[1] = '$tableconstructor'}, [10] = {[1] = '$exp', [2] = '$binop', [3] = '$exp'}, [11] = {[1] = '$unop', [2] = '$exp'}}, ['namelist'] = {[1] = {[1] = 'Name', [2] = 'comma_name_list_opt'}}, ['explist'] = {[1] = {[1] = '$exp'}}, ['dot_name_list'] = {[1] = {[1] = '.', [2] = 'Name'}, [2] = {[1] = '$dot_name_list\''}}, ['tableconstructor'] = {[1] = {[1] = '{', [2] = '}'}, [2] = {[1] = '{', [2] = '$fieldlist_opt', [3] = '}'}}, ['comma_var_list'] = {[1] = {[1] = ',', [2] = '$var'}, [2] = {[1] = '$comma_var_list\''}}, ['var'] = {[1] = {[1] = 'Name'}, [2] = {[1] = '$prefixexp', [2] = '[', [3] = '$exp', [4] = ']'}, [3] = {[1] = '$prefixexp', [2] = '.', [3] = 'Name'}}, ['fieldsep_opt'] = {[1] = {[1] = '$fieldsep'}}, ['fieldsep_field_list'] = {[1] = {[1] = '$fieldsep', [2] = '$field'}, [2] = {[1] = '$fieldsep_field_list\''}}, ['fieldsep_field_list_opt'] = {[1] = {[1] = '$fieldsep_field_list'}}, ['fieldlist_opt'] = {[1] = {[1] = '$fieldlist'}}, ['comma_var_list\''] = {[1] = {[1] = '$comma_var_list'}}, ['prefixexp'] = {[1] = {[1] = '$var'}, [2] = {[1] = '$functioncall'}, [3] = {[1] = '(', [2] = '$exp', [3] = ')'}}, ['elseif_list_opt'] = {[1] = {[1] = '$elseif_list'}}, ['args'] = {[1] = {[1] = '(', [2] = ')'}, [2] = {[1] = '(', [2] = '$explist_opt', [3] = ')'}, [3] = {[1] = '$tableconstructor'}, [4] = {[1] = 'LiteralString'}}, ['eq_explist_opt'] = {[1] = {[1] = '=', [2] = '$explist'}}, ['functiondef'] = {[1] = {[1] = 'function', [2] = '$funcbody'}}, ['varlist'] = {[1] = {[1] = '$var'}, [2] = {[1] = '$var', [2] = '$comma_var_list\''}}, ['comma_name_list\''] = {[1] = {[1] = '$comma_name_list'}}, ['funcname'] = {[1] = {[1] = 'Name', [2] = '$colon_name_opt'}, [2] = {[1] = 'Name', [2] = '$dot_name_list_opt', [3] = '$colon_name_opt'}}, ['root'] = {[1] = {[1] = '$block'}}, ['dot_name_list\''] = {[1] = {[1] = '$dot_name_list'}}, ['comma_varargs_opt'] = {[1] = {[1] = ',', [2] = '...'}}, ['fieldsep_field_list\''] = {[1] = {[1] = '$fieldsep_field_list'}}, ['stat'] = {[1] = {[1] = ';'}, [2] = {[1] = '$varlist', [2] = '=', [3] = '$explist'}, [3] = {[1] = '$functioncall'}, [4] = {[1] = '$label'}, [5] = {[1] = 'break'}, [6] = {[1] = 'goto', [2] = 'Name'}, [7] = {[1] = 'do', [2] = '$block', [3] = 'end'}, [8] = {[1] = 'while', [2] = '$exp', [3] = 'do', [4] = '$block', [5] = 'end'}, [9] = {[1] = 'repeat', [2] = '$block', [3] = 'until', [4] = '$exp'}, [10] = {[1] = 'if', [2] = '$exp', [3] = 'then', [4] = '$block', [5] = '$else_opt', [6] = 'end'}, [11] = {[1] = 'if', [2] = '$exp', [3] = 'then', [4] = '$block', [5] = '$elseif_list_opt', [6] = '$else_opt', [7] = 'end'}, [12] = {[1] = 'for', [2] = 'Name', [3] = '=', [4] = '$exp', [5] = ',', [6] = '$exp', [7] = 'do', [8] = '$block', [9] = 'end'}, [13] = {[1] = 'for', [2] = 'Name', [3] = '=', [4] = '$exp', [5] = ',', [6] = '$exp', [7] = '$comma_exp_opt', [8] = 'do', [9] = '$block', [10] = 'end'}, [14] = {[1] = 'for', [2] = '$namelist', [3] = 'in', [4] = '$explist', [5] = 'do', [6] = '$block', [7] = 'end'}, [15] = {[1] = 'function', [2] = '$funcname', [3] = '$funcbody'}, [16] = {[1] = 'local', [2] = 'function', [3] = 'Name', [4] = '$funcbody'}, [17] = {[1] = 'local', [2] = '$namelist'}, [18] = {[1] = 'local', [2] = '$namelist', [3] = '$eq_explist_opt'}}, ['parlist_opt'] = {[1] = {[1] = '$parlist'}}, ['stat_list'] = {[1] = {[1] = '$stat'}, [2] = {[1] = '$stat', [2] = '$stat_list\''}}, ['comma_name_list_opt'] = {[1] = {[1] = '$comma_name_list'}}, ['elseif_list'] = {[1] = {[1] = 'elseif', [2] = '$exp', [3] = 'then', [4] = '$block', [5] = '$elseif_list\''}}, ['fieldlist'] = {[1] = {[1] = '$field', [2] = '$fieldsep_opt'}, [2] = {[1] = '$field', [2] = '$fieldsep_field_list_opt', [3] = '$fieldsep_opt'}}, ['elseif_list\''] = {[1] = {[1] = '$elseif_list'}}, ['retstat_opt'] = {[1] = {[1] = '$retstat'}}, ['explist_opt'] = {[1] = {[1] = '$explist'}}, ['funcbody'] = {[1] = {[1] = '(', [2] = ')', [3] = '$block', [4] = 'end'}, [2] = {[1] = '(', [2] = '$parlist_opt', [3] = ')', [4] = '$block', [5] = 'end'}}, ['functioncall'] = {[1] = {[1] = '$prefixexp', [2] = '$args'}, [2] = {[1] = '$prefixexp', [2] = ':', [3] = 'Name', [4] = '$args'}}, ['stat_list\''] = {[1] = {[1] = '$stat_list'}}, ['colon_name_opt'] = {[1] = {[1] = ':', [2] = 'Name'}}, ['parlist'] = {[1] = {[1] = '$namelist'}, [2] = {[1] = '$namelist', [2] = '$comma_varargs_opt'}, [3] = {[1] = '...'}}, ['retstat'] = {[1] = {[1] = 'return', [2] = '$semicolon_opt'}, [2] = {[1] = 'return', [2] = '$explist_opt', [3] = '$semicolon_opt'}}, ['fieldsep'] = {[1] = {[1] = ','}, [2] = {[1] = ';'}}, ['dot_name_list_opt'] = {[1] = {[1] = '$dot_name_list'}}, ['binop'] = {[1] = {[1] = '+'}, [2] = {[1] = '-'}, [3] = {[1] = '*'}, [4] = {[1] = '/'}, [5] = {[1] = '//'}, [6] = {[1] = '^'}, [7] = {[1] = '%'}, [8] = {[1] = '&'}, [9] = {[1] = '~'}, [10] = {[1] = '|'}, [11] = {[1] = '>>'}, [12] = {[1] = '<<'}, [13] = {[1] = '..'}, [14] = {[1] = '<'}, [15] = {[1] = '<='}, [16] = {[1] = '>'}, [17] = {[1] = '>='}, [18] = {[1] = '=='}, [19] = {[1] = '~='}, [20] = {[1] = 'and'}, [21] = {[1] = 'or'}}, ['comma_name_list'] = {[1] = {[1] = ',', [2] = 'Name'}, [2] = {[1] = '$comma_name_list\''}}}
-- __GRAMMAR__.grammar[1] = '/Users/leegao/sideproject/ParserSiProMo/lua/experimental.table'
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
__GRAMMAR__.grammar["else_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_exp_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["label"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["semicolon_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["unop"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["block"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["field"][3].action = __GRAMMAR__.default_action
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
__GRAMMAR__.grammar["namelist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["dot_name_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["dot_name_list"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["tableconstructor"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["tableconstructor"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_var_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_var_list"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["var"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep_field_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep_field_list"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep_field_list_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_var_list'"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["prefixexp"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["elseif_list_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["args"][4].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["eq_explist_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functiondef"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["varlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["varlist"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_name_list'"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcname"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["root"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["dot_name_list'"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_varargs_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep_field_list'"][1].action = __GRAMMAR__.default_action
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
__GRAMMAR__.grammar["stat"][16].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][17].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat"][18].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat_list"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_name_list_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["elseif_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldlist"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["elseif_list'"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["explist_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcbody"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["funcbody"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functioncall"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["functioncall"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["stat_list'"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["colon_name_opt"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["parlist"][3].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["retstat"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["fieldsep"][2].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["dot_name_list_opt"][1].action = __GRAMMAR__.default_action
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
__GRAMMAR__.grammar["binop"][16].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][17].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][18].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][19].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][20].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["binop"][21].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_name_list"][1].action = __GRAMMAR__.default_action
__GRAMMAR__.grammar["comma_name_list"][2].action = __GRAMMAR__.default_action
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