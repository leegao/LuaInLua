-- interprets a subset of Lua directly

local visitor = require 'lua.base_visitor'
local parser = require 'lua.parser'
local utils = require 'common.utils'

local tree = parser(io.open('ll1/ll1.lua', 'r'):read('*all'))

local scope = {_G = {}}
function scope:new_local()
  local latest = peek(scope)
  local id = latest.id
  latest.id = latest.id + 1
  return id
end

local function peek(stack) return stack[#stack] end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end

local function enter(block)
  print("Entering block with " .. #block .. " instructions")
  local previous_id = (peek(scope) or {id = 1}).id
  push(
    {block = block, id = previous_id, locals = {}},
    scope)
end

local function exit(block)
  assert(pop(scope).block == block)
end

-- emit ASTs of bytecodes
local interpreter = visitor {
  before = function(self, node)
    if node.kind == 'block' then
      enter(node)
    end
  end,
  after = function(self, node, result)
    if node.kind == 'block' then
      exit(node)
    end
    return result
  end,
  on_block = function(self, block)
    for child in utils.loop(block) do
      print('--', child.kind)
    end
    return self.super:on_block(block)
  end,
  on_localassign = function(self, assignment)
    -- left (namelist), right (explist)
    assert(assignment.left.kind == 'names')
    local names = utils.map(function(name) return name.name end, assignment.left)
    -- create locals
    if assignment.right then
      assert(assignment.right.kind == 'explist')
    else
      -- assign them nil
    end
    return false
  end,

}

interpreter:accept(tree)