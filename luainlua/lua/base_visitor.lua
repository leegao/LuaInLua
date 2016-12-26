local ast = require 'luainlua.lua.ast'
local utils = require 'luainlua.common.utils'

local base_visitor = ast {
  on_block = function(self, node)
    -- ret
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_localassign = function(self, node)
    -- left, right
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_names = function(self, node)
    -- list of leaves of Names
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_name = function(self, node)
    -- name
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_nil = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_true = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_false = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_bop = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_unop = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_number = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_string = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_break = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_leaf = function(self, node)
    -- tokens
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_explist = function(self, node)
    -- list of node 'exp's
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_table = function(self, node)
    -- list of table node 'elements'
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_call = function(self, node)
    -- target, args
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_args = function(self, node)
    -- list of node 'exp's
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_unop = function(self, node)
    -- operator, operand
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_element = function(self, node)
    -- index, value
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_function = function(self, node)
    -- parameters, body
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_parameters = function(self, node)
    -- list of names, vararg
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_return = function(self, node)
    -- explist
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_selfcall = function(self, node)
    -- target, args
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_index = function(self, node)
    -- left, right
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_if = function(self, node)
    -- cond, block, elseifs, else
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_foreach = function(self, node)
    -- names, iterator, block
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_binop = function(self, node)
    -- left, right
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_assignments = function(self, node)
    -- left, right
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_lvalue = function(self, node)
    -- list of lvals (primaryexp suffix*)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_else = function(self, node)
    -- block
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_localfunctiondef = function(self, node)
    -- name, function
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_functiondef = function(self, node)
    -- funcname, function
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_funcnames = function(self, node)
    -- list of funcname*, colon
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_empty = function(self, node)
    -- nothing
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_elseif = function(self, node)
    -- block cond
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_while = function(self, node)
    -- while cond block
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_repeat = function(self, node)
    -- repeat cond block
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_fori = function(self, node)
    -- node('fori'):set('id', from(_1)):set('start', _3):set('finish', _5):set('step', _6[1]):set('block', _8)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end,
  on_localfunctiondef = function(self, node)
    print("on_" .. node.kind .. " is not implemented!")
    return node, false
  end
}
base_visitor.super = base_visitor
function base_visitor:children()
  return utils.loop(self)
end

local mt = utils.copy(getmetatable(base_visitor))
function mt.__call(self, visitor) 
  return setmetatable(visitor, {__index = base_visitor}) 
end

return setmetatable(base_visitor, mt)