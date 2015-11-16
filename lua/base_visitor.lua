local ast = require 'lua.ast'
local utils = require 'common.utils'

local base_visitor = ast {
  on_block = function(self, node)
    -- ret
    return node, true
  end,
  on_localassign = function(self, node)
    -- left, right
    return node, true
  end,
  on_names = function(self, node)
    -- list of leaves of Names
    return node, true
  end,
  on_leaf = function(self, node)
    -- tokens
    return node, true
  end,
  on_explist = function(self, node)
    -- list of node 'exp's
    return node, true
  end,
  on_table = function(self, node)
    -- list of table node 'elements'
    return node, true
  end,
  on_call = function(self, node)
    -- target, args
    return node, true
  end,
  on_args = function(self, node)
    -- list of node 'exp's
    return node, true
  end,
  on_unop = function(self, node)
    -- operator, operand
    return node, true
  end,
  on_element = function(self, node)
    -- index, value
    return node, true
  end,
  on_function = function(self, node)
    -- parameters, body
    return node, true
  end,
  on_parameters = function(self, node)
    -- list of names, vararg
    return node, true
  end,
  on_return = function(self, node)
    -- explist
    return node, true
  end,
  on_selfcall = function(self, node)
    -- target, args
    return node, true
  end,
  on_index = function(self, node)
    -- left, right
    return node, true
  end,
  on_if = function(self, node)
    -- cond, block, elseifs, else
    return node, true
  end,
  on_foreach = function(self, node)
    -- names, iterator, block
    return node, true
  end,
  on_binop = function(self, node)
    -- left, right
    return node, true
  end,
  on_assignments = function(self, node)
    -- left, right
    return node, true
  end,
  on_lvalue = function(self, node)
    -- list of lvals (primaryexp suffix*)
    return node, true
  end,
  on_else = function(self, node)
    -- block
    return node, true
  end,
  on_localfunctiondef = function(self, node)
    -- name, function
    return node, true
  end,
  on_functiondef = function(self, node)
    -- funcname, function
    return node, true
  end,
  on_funcnames = function(self, node)
    -- list of funcname*, colon
    return node, true
  end,
  on_empty = function(self, node)
    -- nothing
    return node, true
  end,
  on_elseif = function(self, node)
    -- block cond
    return node, true
  end,
}
base_visitor.super = base_visitor

local mt = utils.copy(getmetatable(base_visitor))
function mt.__call(self, visitor) 
  return setmetatable(visitor, {__index = base_visitor}) 
end

return setmetatable(base_visitor, mt)