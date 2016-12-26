local utils = require 'luainlua.common.utils'
local tokenizer = require 'luainlua.lua.tokenizer'
local ll1 = require 'luainlua.ll1.ll1'
local __GRAMMAR__ = {}
__GRAMMAR__.grammar = {['funcbody'] = {[1] = {[1] = 'LPAREN', [2] = '$funcbody\'maybe#1', [3] = 'RPAREN', [4] = '$block', [5] = 'END'}, ['variable'] = '$funcbody'}, ['exp_stop'] = {[1] = {[1] = '$tableconstructor'}, [2] = {[1] = '$primaryexp', [2] = '$exp_stop\'star#1'}, [3] = {[1] = '$functiondef'}, [4] = {[1] = 'DOTS'}, [5] = {[1] = 'String'}, [6] = {[1] = 'Number'}, [7] = {[1] = 'TRUE'}, [8] = {[1] = 'FALSE'}, [9] = {[1] = 'NIL'}, ['variable'] = '$exp_stop'}, ['exp8\'maybe#1'] = {[1] = {[1] = '$exp8\'group#1', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$exp8\'maybe#1'}, ['exp5'] = {[1] = {[1] = '$exp6', [2] = '$exp5\''}, ['variable'] = '$exp5'}, ['block\'star#1'] = {[1] = {[1] = '$stat', [2] = '$block\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$block\'star#1'}, ['assignment'] = {[1] = {[1] = 'EQ', [2] = '$explist'}, [2] = {[1] = 'COMMA', [2] = '$primaryexp', [3] = '$assignment\'star#1', [4] = '$assignment'}, ['variable'] = '$assignment'}, ['assignment_or_call'] = {[1] = {[1] = '$primaryexp', [2] = '$assignment_or_call\'star#1', [3] = '$assignment_or_call\'maybe#1'}, ['variable'] = '$assignment_or_call'}, ['parlist'] = {[1] = {[1] = '$parlist\'star#1', [2] = '$parlist\'group#2'}, ['variable'] = '$parlist'}, ['tableconstructor'] = {[1] = {[1] = 'LBRACE', [2] = '$tableconstructor\'star#1', [3] = 'RBRACE'}, ['variable'] = '$tableconstructor'}, ['exp3'] = {[1] = {[1] = '$exp4', [2] = '$exp3\''}, ['variable'] = '$exp3'}, ['funcname\'group#1'] = {[1] = {[1] = 'PERIOD', [2] = 'Name'}, ['variable'] = '$funcname\'group#1'}, ['exp7'] = {[1] = {[1] = '$exp8'}, [2] = {[1] = '$level7', [2] = '$exp7'}, ['variable'] = '$exp7'}, ['funcname\'group#2'] = {[1] = {[1] = 'COLON', [2] = 'Name'}, ['variable'] = '$funcname\'group#2'}, ['level7'] = {[1] = {[1] = 'MIN'}, [2] = {[1] = 'HASH'}, [3] = {[1] = 'NOT'}, ['variable'] = '$level7'}, ['unop'] = {[1] = {[1] = 'HASH'}, [2] = {[1] = 'NOT'}, [3] = {[1] = 'MIN'}, ['variable'] = '$unop'}, ['funcbody\'maybe#1'] = {[1] = {[1] = '$parlist', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$funcbody\'maybe#1'}, ['assignment\'star#1'] = {[1] = {[1] = '$suffix', [2] = '$assignment\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$assignment\'star#1'}, ['retstat\'maybe#1'] = {[1] = {[1] = '$explist', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#1'}, ['level3'] = {[1] = {[1] = 'EQEQ'}, [2] = {[1] = 'NOTEQ'}, [3] = {[1] = 'GE'}, [4] = {[1] = 'LE'}, [5] = {[1] = 'GT'}, [6] = {[1] = 'LT'}, ['variable'] = '$level3'}, ['binop'] = {[1] = {[1] = 'OR'}, [2] = {[1] = 'AND'}, [3] = {[1] = 'NOTEQ'}, [4] = {[1] = 'EQEQ'}, [5] = {[1] = 'GE'}, [6] = {[1] = 'GT'}, [7] = {[1] = 'LE'}, [8] = {[1] = 'LT'}, [9] = {[1] = 'CONCAT'}, [10] = {[1] = 'MOD'}, [11] = {[1] = 'POW'}, [12] = {[1] = 'DIV'}, [13] = {[1] = 'MUL'}, [14] = {[1] = 'MIN'}, [15] = {[1] = 'PLUS'}, ['variable'] = '$binop'}, ['block'] = {[1] = {[1] = '$block\'star#1', [2] = '$block\'maybe#1'}, ['variable'] = '$block'}, ['stat\'group#1\'maybe#1'] = {[1] = {[1] = '$stat\'group#1\'group#1', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$stat\'group#1\'maybe#1'}, ['tableconstructor\'star#1'] = {[1] = {[1] = '$field', [2] = '$tableconstructor\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$tableconstructor\'star#1'}, ['field'] = {[1] = {[1] = '$exp', [2] = '$field\'maybe#1', ['tag'] = 'exp'}, [2] = {[1] = 'Name', [2] = 'EQ', [3] = '$exp', [4] = '$field\'maybe#2', ['tag'] = 'assign'}, [3] = {[1] = 'LBRACK', [2] = '$exp', [3] = 'RBRACK', [4] = 'EQ', [5] = '$exp', [6] = '$field\'maybe#3'}, ['variable'] = '$field'}, ['functiondef'] = {[1] = {[1] = 'FUNCTION', [2] = '$funcbody'}, ['variable'] = '$functiondef'}, ['exp4\'maybe#1'] = {[1] = {[1] = '$exp4\'group#1', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$exp4\'maybe#1'}, ['funcname'] = {[1] = {[1] = 'Name', [2] = '$funcname\'star#1', [3] = '$funcname\'maybe#1'}, ['variable'] = '$funcname'}, ['exp2\''] = {[1] = {[1] = ''}, [2] = {[1] = '$level2', [2] = '$exp3', [3] = '$exp2\''}, ['variable'] = '$exp2\''}, ['funcname\'star#1'] = {[1] = {[1] = '$funcname\'group#1', [2] = '$funcname\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'star#1'}, ['stat\'group#4'] = {[1] = {[1] = 'ELSE', [2] = '$block'}, ['variable'] = '$stat\'group#4'}, ['exp4\'group#1'] = {[1] = {[1] = '$level4', [2] = '$exp4'}, ['variable'] = '$exp4\'group#1'}, ['retstat'] = {[1] = {[1] = 'RETURN', [2] = '$retstat\'maybe#1', [3] = '$retstat\'maybe#2'}, ['variable'] = '$retstat'}, ['exp6\''] = {[1] = {[1] = ''}, [2] = {[1] = '$level6', [2] = '$exp7', [3] = '$exp6\''}, ['variable'] = '$exp6\''}, ['root'] = {[1] = {[1] = '$block'}, ['variable'] = '$root'}, ['block\'maybe#1'] = {[1] = {[1] = '$retstat', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$block\'maybe#1'}, ['level1'] = {[1] = {[1] = 'OR'}, ['variable'] = '$level1'}, ['exp'] = {[1] = {[1] = '$exp2', [2] = '$exp\''}, ['variable'] = '$exp'}, ['exp3\''] = {[1] = {[1] = ''}, [2] = {[1] = '$level3', [2] = '$exp4', [3] = '$exp3\''}, ['variable'] = '$exp3\''}, ['explist\'star#1'] = {[1] = {[1] = '$explist\'group#1', [2] = '$explist\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$explist\'star#1'}, ['label'] = {[1] = {[1] = 'QUAD', [2] = 'Name', [3] = 'QUAD'}, ['variable'] = '$label'}, ['funcname\'maybe#1'] = {[1] = {[1] = '$funcname\'group#2', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$funcname\'maybe#1'}, ['level8'] = {[1] = {[1] = 'POW'}, ['variable'] = '$level8'}, ['assignment_or_call\'maybe#1'] = {[1] = {[1] = '$assignment', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$assignment_or_call\'maybe#1'}, ['level6'] = {[1] = {[1] = 'MOD'}, [2] = {[1] = 'DIV'}, [3] = {[1] = 'MUL'}, ['variable'] = '$level6'}, ['level5'] = {[1] = {[1] = 'MIN'}, [2] = {[1] = 'PLUS'}, ['variable'] = '$level5'}, ['exp\''] = {[1] = {[1] = ''}, [2] = {[1] = '$level1', [2] = '$exp2', [3] = '$exp\''}, ['variable'] = '$exp\''}, ['stat\'group#2\'maybe#1'] = {[1] = {[1] = '$stat\'group#2\'group#1', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$stat\'group#2\'maybe#1'}, ['stat\'group#1'] = {[1] = {[1] = '$namelist', [2] = '$stat\'group#1\'maybe#1'}, [2] = {[1] = 'FUNCTION', [2] = 'Name', [3] = '$funcbody'}, ['variable'] = '$stat\'group#1'}, ['fieldsep'] = {[1] = {[1] = 'SEMICOLON'}, [2] = {[1] = 'COMMA'}, ['variable'] = '$fieldsep'}, ['stat\'maybe#1'] = {[1] = {[1] = '$stat\'group#4', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$stat\'maybe#1'}, ['namelist\'group#1'] = {[1] = {[1] = 'COMMA', [2] = 'Name'}, ['variable'] = '$namelist\'group#1'}, ['stat\'star#1'] = {[1] = {[1] = '$stat\'group#3', [2] = '$stat\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$stat\'star#1'}, ['exp5\''] = {[1] = {[1] = ''}, [2] = {[1] = '$level5', [2] = '$exp6', [3] = '$exp5\'', ['tag'] = 'minus'}, ['variable'] = '$exp5\''}, ['args\'maybe#1'] = {[1] = {[1] = '$explist', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$args\'maybe#1'}, ['stat\'group#3'] = {[1] = {[1] = 'ELSEIF', [2] = '$exp', [3] = 'THEN', [4] = '$block'}, ['variable'] = '$stat\'group#3'}, ['stat\'group#2\'group#1'] = {[1] = {[1] = 'COMMA', [2] = '$exp'}, ['variable'] = '$stat\'group#2\'group#1'}, ['parlist\'group#2'] = {[1] = {[1] = 'DOTS'}, [2] = {[1] = 'Name'}, ['variable'] = '$parlist\'group#2'}, ['stat\'group#2'] = {[1] = {[1] = '$namelist', [2] = 'IN', [3] = '$explist', [4] = 'DO', [5] = '$block', [6] = 'END', ['tag'] = 'foreach'}, [2] = {[1] = 'Name', [2] = 'EQ', [3] = '$exp', [4] = 'COMMA', [5] = '$exp', [6] = '$stat\'group#2\'maybe#1', [7] = 'DO', [8] = '$block', [9] = 'END', ['tag'] = 'forcounter'}, ['variable'] = '$stat\'group#2'}, ['stat\'group#1\'group#1'] = {[1] = {[1] = 'EQ', [2] = '$explist'}, ['variable'] = '$stat\'group#1\'group#1'}, ['retstat\'maybe#2'] = {[1] = {[1] = 'SEMICOLON', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$retstat\'maybe#2'}, ['exp4'] = {[1] = {[1] = '$exp5', [2] = '$exp4\'maybe#1'}, ['variable'] = '$exp4'}, ['field\'maybe#1'] = {[1] = {[1] = '$fieldsep', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$field\'maybe#1'}, ['exp6'] = {[1] = {[1] = '$exp7', [2] = '$exp6\''}, ['variable'] = '$exp6'}, ['exp_stop\'star#1'] = {[1] = {[1] = '$suffix', [2] = '$exp_stop\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$exp_stop\'star#1'}, ['parlist\'group#1'] = {[1] = {[1] = 'Name', [2] = 'COMMA', ['tag'] = 'namelist'}, ['variable'] = '$parlist\'group#1'}, ['field\'maybe#2'] = {[1] = {[1] = '$fieldsep', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$field\'maybe#2'}, ['field\'maybe#3'] = {[1] = {[1] = '$fieldsep', ['tag'] = '#present'}, [2] = {[1] = ''}, ['variable'] = '$field\'maybe#3'}, ['assignment_or_call\'star#1'] = {[1] = {[1] = '$assignment_or_call\'group#1', [2] = '$assignment_or_call\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$assignment_or_call\'star#1'}, ['explist'] = {[1] = {[1] = '$exp', [2] = '$explist\'star#1'}, ['variable'] = '$explist'}, ['namelist'] = {[1] = {[1] = 'Name', [2] = '$namelist\'star#1'}, ['variable'] = '$namelist'}, ['exp8\'group#1'] = {[1] = {[1] = '$level8', [2] = '$exp8'}, ['variable'] = '$exp8\'group#1'}, ['level4'] = {[1] = {[1] = 'CONCAT'}, ['variable'] = '$level4'}, ['primaryexp'] = {[1] = {[1] = 'LPAREN', [2] = '$exp', [3] = 'RPAREN'}, [2] = {[1] = 'Name'}, ['variable'] = '$primaryexp'}, ['level2'] = {[1] = {[1] = 'AND'}, ['variable'] = '$level2'}, ['stat'] = {[1] = {[1] = 'LOCAL', [2] = '$stat\'group#1'}, [2] = {[1] = 'FUNCTION', [2] = '$funcname', [3] = '$funcbody'}, [3] = {[1] = 'FOR', [2] = '$stat\'group#2'}, [4] = {[1] = 'IF', [2] = '$exp', [3] = 'THEN', [4] = '$block', [5] = '$stat\'star#1', [6] = '$stat\'maybe#1', [7] = 'END'}, [5] = {[1] = 'REPEAT', [2] = '$block', [3] = 'UNTIL', [4] = '$exp'}, [6] = {[1] = 'WHILE', [2] = '$exp', [3] = 'DO', [4] = '$block', [5] = 'END'}, [7] = {[1] = 'DO', [2] = '$block', [3] = 'END'}, [8] = {[1] = 'GOTO', [2] = 'Name'}, [9] = {[1] = 'BREAK'}, [10] = {[1] = '$label'}, [11] = {[1] = '$assignment_or_call'}, [12] = {[1] = 'SEMICOLON'}, ['variable'] = '$stat'}, ['assignment_or_call\'group#1'] = {[1] = {[1] = '$args', ['tag'] = 'call'}, [2] = {[1] = 'COLON', [2] = 'Name', [3] = '$args'}, [3] = {[1] = 'LBRACK', [2] = '$exp', [3] = 'RBRACK'}, [4] = {[1] = 'PERIOD', [2] = 'Name'}, ['variable'] = '$assignment_or_call\'group#1'}, ['namelist\'star#1'] = {[1] = {[1] = '$namelist\'group#1', [2] = '$namelist\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$namelist\'star#1'}, ['suffix'] = {[1] = {[1] = '$args'}, [2] = {[1] = 'COLON', [2] = 'Name', [3] = '$args'}, [3] = {[1] = 'LBRACK', [2] = '$exp', [3] = 'RBRACK'}, [4] = {[1] = 'PERIOD', [2] = 'Name'}, ['variable'] = '$suffix'}, ['exp8'] = {[1] = {[1] = '$exp_stop', [2] = '$exp8\'maybe#1'}, ['variable'] = '$exp8'}, ['explist\'group#1'] = {[1] = {[1] = 'COMMA', [2] = '$exp'}, ['variable'] = '$explist\'group#1'}, ['args'] = {[1] = {[1] = 'String'}, [2] = {[1] = '$tableconstructor'}, [3] = {[1] = 'LPAREN', [2] = '$args\'maybe#1', [3] = 'RPAREN'}, ['variable'] = '$args'}, ['parlist\'star#1'] = {[1] = {[1] = '$parlist\'group#1', [2] = '$parlist\'star#1', ['tag'] = '#list'}, [2] = {[1] = ''}, ['variable'] = '$parlist\'star#1'}, ['exp2'] = {[1] = {[1] = '$exp3', [2] = '$exp2\''}, ['variable'] = '$exp2'}}
__GRAMMAR__.grammar[1] = 'luainlua/lua/parser_table.lua'
local ast = {}
function ast:__newindex(key, val)
  if type(key) ~= 'string' then
    return rawset(self, key, val)
  end
  assert(not self[key], 'Fields passed to a node should be initialized only once.')
  rawset(self, key, val)
  -- other stuff
  if val.kind then
    table.insert(self, val)
    assert(not val.parent, 'Fields passed to a node should be unowned.')
    rawset(val, 'parent', self)
  end
end

function ast:set(key, val)
  if not key or not val then return self end
  if not val.kind then
    print(debug.traceback())
  end
  assert(val.kind, 'Set should only be called on child trees.')
  self[key] = val
  return self
end

function ast:list(...)
  local list = {...}
  for child in utils.loop(list) do
    if not child.kind then
      print(debug.traceback())
    end
    assert(child.kind, 'List should only be called on child trees.')
    table.insert(self, child)
    assert(not child.parent or child.parent.kind == 'explist', 'Children passed to list(...) should be unowned.')
    rawset(child, 'parent', self)
  end
  return self
end

function ast:children()
  return utils.loop(self)
end

local function node(location, kind)
  return setmetatable({kind = kind, location = location}, {__index = ast, __newindex = ast.__newindex})
end

local function from(token, kind)
  if not kind then
    if tostring(token) == 'Name' then
      kind = 'name'
    else
      kind = 'leaf'
    end
  end
  local leaf = node(token.location, kind)
  leaf.token = token
  leaf.value = token[2]
  return leaf
end

-- this will either reduce to an index, a call, a name, or a grouped expression
-- // Shape of a suffix: {index = shape(from(name)), args = shape(args)}
-- suffix := '.' Name {\: suffix_dot :\} // field
--         | '[' $exp ']' {\: suffix_bracket :\} // field
--         | ':' Name $args {\: suffix_colon :\} // arg
--         | $args {\: suffix_args :\} // arg
-- primaryexp := Name [: from(_1) :] 
--         | '(' $exp ')' [: _2 :]
-- primary_suffix := $primaryexp $suffix*
-- Plan: recurse on the structural inductive properties of a list
local function handle_primary_suffix(left, suffixlist)
  if #suffixlist == 0 then
    return left
  end
  -- pop the first element out of suffixlist
  local suffix = suffixlist[1]
  local rest = utils.sublist(suffixlist, 2)
  if suffix.index and not suffix.args then
    return handle_primary_suffix(
        node(left.location, 'index'):set('left', left):set('right', suffix.index),
        rest)
  elseif suffix.args and not suffix.index then
    return handle_primary_suffix(
        node(left.location, 'call'):set('target', left):set('args', suffix.args),
        rest)
  elseif suffix.args and suffix.index then
    local index = node(left.location, 'index'):set('left', left):set('right', suffix.index)
    return handle_primary_suffix(
        node(index.location, 'selfcall'):set('target', index):set('args', suffix.args),
        rest)
  end
  error 'unimplemented'
end
local function suffix_dot(_, name)
    return {
      index = from(name, "string"),
      args = nil,
    }
  end
  local function suffix_bracket(_, exp)
    return {
      index = exp,
      args = nil,
    }
  end
  local function suffix_colon(_, name, args)
    return {
      index = from(name, "string"),
      args = args,
    }
  end
  local function suffix_args(args)
    return {
      index = nil,
      args = args,
    }
  end
local function parlist_namelist(namelist, trail)
    local parameters = node(namelist[1] and namelist[1].location or trail.location, 'parameters')
    for name in utils.loop(namelist) do
      parameters:list(from(name))
    end
    if trail[1] == 'DOTS' then
      rawset(parameters, 'vararg', from(trail))
    else
      parameters:list(from(trail))
    end
    return parameters
  end
local function goto_list(self) return self:go '#list' end
local make_binop = function(left, rest)
    if #rest == 0 then
      return left
    end
    assert(#rest == 2 and rest[1].kind == 'binop' and not rest[1].left)
    local hole, binop = unpack(rest)
    hole.left = left
    return binop
  end

  local start_binop = function(bop, right, rest)
    -- In ocaml style pseduocode
    -- let start (+) e_r rest =
    --   let o = hole() in
    --   match rest with
    --   | None -> o, (o (+) e_r)
    --   | Some(., e_l' (*) e_r' as e') ->
    --     let e'' = fill(e', ., (o (+) e_r) in
    --     o, e''
    -- Invariant: expn' is always "holed" and expn is always whole
    -- Invariant: immediately holed expn' is always holey on the left
    local hole = node(bop.location, 'binop')
    hole.operator = bop
    hole.right = right
    -- implicit: hole.left is the hole
    if #rest == 0 then
      return {hole, hole}
    end
    assert(#rest == 2 and rest[1].kind == 'binop' and not rest[1].left)
    rest[1].left = hole
    return {hole, rest[2]}
  end

  local function start_right_binop(bop, right)
    -- invariant: right is whole, return is immediately holed
    local hole = node(bop.location, 'binop')
    hole.operator = bop
    hole.right = right
    return hole
  end

  local function make_right_binop(left, binop_opt)
    local binop = binop_opt[1]
    if not binop then return left end
    assert(binop.kind == 'binop' and not binop.left)
    binop.left = left
    return binop
  end
__GRAMMAR__.convert = function(token) return token[1] end
__GRAMMAR__.prologue = function(stream)
    local tokens = {}
    for token in tokenizer(stream) do
      table.insert(tokens, token)
    end
    return tokens
  end
__GRAMMAR__.epilogue = function(...) return ... end
__GRAMMAR__.default_action = function(...) return {...} end
__GRAMMAR__.grammar["funcbody"][1].action = function(_1, parameters_opt, _, block)
      local parameters = parameters_opt[1] or node(_1.location, 'parameters')
      return {parameters, block}
    end
__GRAMMAR__.grammar["exp_stop"][1].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["exp_stop"][2].action = handle_primary_suffix
__GRAMMAR__.grammar["exp_stop"][3].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["exp_stop"][4].action = function(_1)
  return  node(_1.location, 'vararg') 
end
__GRAMMAR__.grammar["exp_stop"][5].action = function(_1)
  return  from(_1, 'string') 
end
__GRAMMAR__.grammar["exp_stop"][6].action = function(_1)
  return  from(_1, 'number') 
end
__GRAMMAR__.grammar["exp_stop"][7].action = function(_1)
  return  node(_1.location, 'true') 
end
__GRAMMAR__.grammar["exp_stop"][8].action = function(_1)
  return  node(_1.location, 'false') 
end
__GRAMMAR__.grammar["exp_stop"][9].action = function(_1)
  return  node(_1.location, 'nil') 
end
__GRAMMAR__.grammar["exp8'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["exp8'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp5"][1].action = make_binop
__GRAMMAR__.grammar["block'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["block'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["assignment"][1].action = function(_1, _2)
  return  {{}, _2} 
end
__GRAMMAR__.grammar["assignment"][2].action = function(_, _1, _2, _3)
          local left, right = unpack(_3)
          table.insert(left, 1, handle_primary_suffix(_1, _2));
          return {left, right}
        end
__GRAMMAR__.grammar["assignment_or_call"][1].action = function(left, suffixes, assignment_opt)
      local assignment = #assignment_opt == 0 and {} or assignment_opt[1]
      -- let's reduce to call or assignment
      if (#suffixes == 0 or not suffixes[#suffixes].args) and #assignment == 0 then
        error('Parser error: you can only specify a call or an assignment here')
      end
      if #suffixes ~= 0 and #assignment ~= 0 and suffixes[#suffixes].args then
        error 'Parser error: you cannot assign to a call'
      end

      if #assignment ~= 0 then
        -- assignment case
        -- assignment is a list of subsequent assignments
        local ps = handle_primary_suffix(left, suffixes)
        assert(ps.kind == 'index' or ps.kind == 'name')
        local lvals, rvals = unpack(assignment)
        table.insert(lvals, 1, ps)
        lvals = node(ps.location, 'lvalues'):list(unpack(lvals))
        local tree = node(ps.location, 'assignments')
        tree.left = lvals
        tree.right = rvals
        return tree
      else
        -- call case
        local ps = handle_primary_suffix(left, suffixes)
        assert(ps.kind == 'call' or ps.kind == 'selfcall')
        return node(ps.location, 'callstmt'):list(ps)
      end
    end
__GRAMMAR__.grammar["parlist"][1].action = parlist_namelist
__GRAMMAR__.grammar["tableconstructor"][1].action = function(_1, _2, _3)
  return  node(_1.location, 'table'):list(unpack(_2)) 
end
__GRAMMAR__.grammar["exp3"][1].action = make_binop
__GRAMMAR__.grammar["funcname'group#1"][1].action = function(_1, _2)
  return  from(_2) 
end
__GRAMMAR__.grammar["exp7"][1].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["exp7"][2].action = function(_1, _2)
  return  node(_1.location, 'unop'):set('operator', _1):set('operand', _2) 
end
__GRAMMAR__.grammar["funcname'group#2"][1].action = function(_1, _2)
  return  from(_2) 
end
__GRAMMAR__.grammar["level7"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level7"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level7"][3].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["unop"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["unop"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["unop"][3].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["funcbody'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcbody'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["assignment'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["assignment'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["retstat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["level3"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level3"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level3"][3].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level3"][4].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level3"][5].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level3"][6].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][3].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][4].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][5].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][6].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][7].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][8].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][9].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][10].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][11].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][12].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][13].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][14].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["binop"][15].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["block"][1].action = function(stats, ret)
  local tree = node((stats[1] and stats[1].location) or (ret[1] and ret[1].location), 'block')
  tree:list(unpack(stats))
  return tree:set('ret', (#ret ~= 0 and ret[1]) or nil) 
end
__GRAMMAR__.grammar["stat'group#1'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'group#1'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["tableconstructor'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["tableconstructor'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["field"][1].action = function(_1, _2)
  return  node(_1.location, 'element'):set('value', _1) 
end
__GRAMMAR__.grammar["field"][2].action = function(_1, _2, _3, _4)
  return  node(_1.location, 'element'):set('index', from(_1, 'string')):set('value', _3) 
end
__GRAMMAR__.grammar["field"][3].action = function(_1, _2, _3, _4, _5, _6)
  return  node(_1.location, 'element'):set('index', _2):set('value', _5) 
end
__GRAMMAR__.grammar["functiondef"][1].action = function(_1, _2)
  return  node(_1.location, 'function'):set('parameters', _2[1]):set('body', _2[2]) 
end
__GRAMMAR__.grammar["exp4'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["exp4'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["funcname"][1].action = function(name, names, colon)
    local tree = node(name.location, 'funcnames')
    colon = colon[1]
    tree:list(from(name))
    tree:list(unpack(names))
    if colon then
      tree.colon = colon
    end
    return tree
  end
__GRAMMAR__.grammar["exp2'"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["exp2'"][2].action = start_binop
__GRAMMAR__.grammar["funcname'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["funcname'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'group#4"][1].action = function(_1, _2)
  return  node(_1.location, 'else'):set('block', _2) 
end
__GRAMMAR__.grammar["exp4'group#1"][1].action = start_right_binop
__GRAMMAR__.grammar["retstat"][1].action = function(_1, _2, _3)
  return  #_2 == 0 and node(_1.location, 'return') or node(_1.location, 'return'):set('explist', _2[1]) 
end
__GRAMMAR__.grammar["exp6'"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["exp6'"][2].action = start_binop
__GRAMMAR__.grammar["root"][1].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["block'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["block'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["level1"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["exp"][1].action = make_binop
__GRAMMAR__.grammar["exp3'"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["exp3'"][2].action = start_binop
__GRAMMAR__.grammar["explist'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["explist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["label"][1].action = function(_1, _2, _3)
  return  node(_1.location, 'label'):set('name', from(_2)) 
end
__GRAMMAR__.grammar["funcname'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["funcname'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["level8"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["assignment_or_call'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["assignment_or_call'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["level6"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level6"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level6"][3].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level5"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["level5"][2].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["exp'"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["exp'"][2].action = start_binop
__GRAMMAR__.grammar["stat'group#2'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'group#2'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'group#1"][1].action = function(_1, _2)
  return  node(_1.location, 'localassign'):set('left', _1):set('right', _2[1]) 
end
__GRAMMAR__.grammar["stat'group#1"][2].action = function(_1, _2, _3)
  return  node(_1.location, 'localfunctiondef'):set('name', from(_2)):set('function', node(_3[1].location, 'function'):set('parameters', _3[1]):set('body', _3[2])) 
end
__GRAMMAR__.grammar["fieldsep"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["fieldsep"][2].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["stat'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["stat'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["namelist'group#1"][1].action = function(_1, _2)
  return  from(_2) 
end
__GRAMMAR__.grammar["stat'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["stat'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp5'"][1].action = function(_1)
  return  {} 
end
__GRAMMAR__.grammar["exp5'"][2].action = start_binop
__GRAMMAR__.grammar["args'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["args'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["stat'group#3"][1].action = function(_1, _2, _3, _4)
  return  node(_1.location, 'elseif'):set('cond', _2):set('block', _4) 
end
__GRAMMAR__.grammar["stat'group#2'group#1"][1].action = function(_1, _2)
  return  _2 
end
__GRAMMAR__.grammar["parlist'group#2"][1].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["parlist'group#2"][2].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["stat'group#2"][1].action = function(_1, _2, _3, _4, _5, _6)
  return  node(_1.location, 'foreach'):set('names', _1):set('iterator', _3):set('block', _5) 
end
__GRAMMAR__.grammar["stat'group#2"][2].action = function(_1, _2, _3, _4, _5, _6, _7, _8, _9)
  return  node(_1.location, 'fori'):set('id', from(_1)):set('start', _3):set('finish', _5):set('step', _6[1]):set('block', _8) 
end
__GRAMMAR__.grammar["stat'group#1'group#1"][1].action = function(_1, _2)
  return  _2 
end
__GRAMMAR__.grammar["retstat'maybe#2"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["retstat'maybe#2"][2].action = function() return {} end
__GRAMMAR__.grammar["exp4"][1].action = make_right_binop
__GRAMMAR__.grammar["field'maybe#1"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["field'maybe#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp6"][1].action = make_binop
__GRAMMAR__.grammar["exp_stop'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["exp_stop'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["parlist'group#1"][1].action = function(_1, _2)
  return  _1 
end
__GRAMMAR__.grammar["field'maybe#2"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["field'maybe#2"][2].action = function() return {} end
__GRAMMAR__.grammar["field'maybe#3"][1].action = function(item) return {item} end
__GRAMMAR__.grammar["field'maybe#3"][2].action = function() return {} end
__GRAMMAR__.grammar["assignment_or_call'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["assignment_or_call'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["explist"][1].action = function(exp, explist)
    local tree = node(exp.location, 'explist')
    tree:list(exp)
    tree:list(unpack(explist))
    return tree
  end
__GRAMMAR__.grammar["namelist"][1].action = function(name, names)
    local tree = node(name.location, 'names')
    tree:list(from(name))
    tree:list(unpack(names))
    return tree
  end
__GRAMMAR__.grammar["exp8'group#1"][1].action = start_right_binop
__GRAMMAR__.grammar["level4"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["primaryexp"][1].action = function(_1, _2, _3)
  return  _2 
end
__GRAMMAR__.grammar["primaryexp"][2].action = function(_1)
  return  from(_1) 
end
__GRAMMAR__.grammar["level2"][1].action = function(_1)
  return  from(_1, 'op') 
end
__GRAMMAR__.grammar["stat"][1].action = function(_1, _2)
  return  _2 
end
__GRAMMAR__.grammar["stat"][2].action = function(_1, _2, _3)
      if _2.colon then
        local name = node(_3[1].location, 'name')
        name.value = 'self'
        table.insert(_3[1], 1, name)
      end
      return node(_1.location, 'functiondef'):set('funcname', _2):set('function', node(_3[1].location, 'function'):set('parameters', _3[1]):set('body', _3[2]))
    end
__GRAMMAR__.grammar["stat"][3].action = function(_1, _2) return _2 end
__GRAMMAR__.grammar["stat"][4].action = function(_1, _2, _3, _4, _5, _6, _7)
  return  node(_1.location, 'if')
          :set('cond', _2)
          :set('block', _4)
          :set('elseifs', #_5 > 0 and node(_5[1].location, 'elseif'):list(unpack(_5)) or nil)
          :set('else_', _6[1]) 
end
__GRAMMAR__.grammar["stat"][5].action = function(_1, _2, _3, _4)
  return  node(_1.location, 'repeat'):set('cond', _4):set('block', _2) 
end
__GRAMMAR__.grammar["stat"][6].action = function(_1, _2, _3, _4, _5)
  return  node(_1.location, 'while'):set('cond', _2):set('block', _4) 
end
__GRAMMAR__.grammar["stat"][7].action = function(_1, _2, _3)
  return  _2 
end
__GRAMMAR__.grammar["stat"][8].action = function(_1, _2)
  return  node(_1.location, 'goto'):set('label', from(_2)) 
end
__GRAMMAR__.grammar["stat"][9].action = function(_1)
  return  node(_1.location, 'break') 
end
__GRAMMAR__.grammar["stat"][10].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["stat"][11].action = function(_1)
  return  _1 
end
__GRAMMAR__.grammar["stat"][12].action = function(_1)
  return  node(_1.location, 'empty') 
end
__GRAMMAR__.grammar["assignment_or_call'group#1"][1].action = suffix_args
__GRAMMAR__.grammar["assignment_or_call'group#1"][2].action = suffix_colon
__GRAMMAR__.grammar["assignment_or_call'group#1"][3].action = suffix_bracket
__GRAMMAR__.grammar["assignment_or_call'group#1"][4].action = suffix_dot
__GRAMMAR__.grammar["namelist'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["namelist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["suffix"][1].action = suffix_args
__GRAMMAR__.grammar["suffix"][2].action = suffix_colon
__GRAMMAR__.grammar["suffix"][3].action = suffix_bracket
__GRAMMAR__.grammar["suffix"][4].action = suffix_dot
__GRAMMAR__.grammar["exp8"][1].action = make_right_binop
__GRAMMAR__.grammar["explist'group#1"][1].action = function(_1, _2)
  return  _2 
end
__GRAMMAR__.grammar["args"][1].action = function(_1)
  return  node(_1.location, 'args'):list(from(_1, 'string')) 
end
__GRAMMAR__.grammar["args"][2].action = function(_1)
  return  node(_1.location, 'args'):list(_1) 
end
__GRAMMAR__.grammar["args"][3].action = function(_1, _2, _3)
  return  (#_2 == 0 and node(_1.location, 'args')) or node(_1.location, 'args'):list(unpack(_2[1])) 
end
__GRAMMAR__.grammar["parlist'star#1"][1].action = function(item, list) table.insert(list, 1, item); return list end
__GRAMMAR__.grammar["parlist'star#1"][2].action = function() return {} end
__GRAMMAR__.grammar["exp2"][1].action = make_binop
__GRAMMAR__.grammar["assignment_or_call'star#1"].conflict = {}
__GRAMMAR__.grammar["assignment_or_call'star#1"].conflict["LPAREN"] =  function(self, tokens)
  -- always reduce to call
  return self:go '#list'
end 
__GRAMMAR__.grammar["parlist'star#1"].conflict = {}
__GRAMMAR__.grammar["parlist'star#1"].conflict["Name"] =  function(self, tokens)
  if tostring(tokens[2]) == 'COMMA' then
    return self:go '#list'
  else
    return self:go ''
  end
end 
__GRAMMAR__.grammar["field"].conflict = {}
__GRAMMAR__.grammar["field"].conflict["Name"] =  function(self, tokens)
  if tostring(tokens[2]) == 'EQ' then
    return self:go 'assign'
  else
    return self:go 'exp'
  end
end 
__GRAMMAR__.grammar["exp5'"].conflict = {}
__GRAMMAR__.grammar["exp5'"].conflict["MIN"] =  function(self, tokens)
  return self:go 'minus'
end 
__GRAMMAR__.grammar["exp_stop'star#1"].conflict = {}
__GRAMMAR__.grammar["exp_stop'star#1"].conflict["LPAREN"] =  goto_list 
__GRAMMAR__.grammar["exp_stop'star#1"].conflict["LBRACK"] =  goto_list 
__GRAMMAR__.grammar["exp_stop'star#1"].conflict["String"] =  goto_list 
__GRAMMAR__.grammar["exp_stop'star#1"].conflict["LBRACE"] =  goto_list 
__GRAMMAR__.grammar["stat'group#2"].conflict = {}
__GRAMMAR__.grammar["stat'group#2"].conflict["Name"] =  function(self, tokens)
  if tostring(tokens[2]) == 'EQ' then
    return self:go 'forcounter'
  else
    return self:go 'foreach'
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