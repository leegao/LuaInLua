-- interprets a subset of Lua directly

local visitor = require 'lua.base_visitor'
local parser = require 'lua.parser'
local utils = require 'common.utils'

local tree = parser(io.open('ll1/ll1.lua', 'r'):read('*all'))

local scope = {_G = {}}
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end

local function enter(block)
  print("Entering block with " .. #block .. " instructions")
  push({block = block}, scope)
end

local function exit(block)
  assert(pop(scope).block == block)
end

local interpreter = visitor {
  before = function(self, node)
    if node.kind == 'block' then
      enter(node)
    end
  end,
  after = function(self, node)
    if node.kind == 'block' then
      exit(node)
    end
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
    print(assignment.left.kind)
    return false
  end,

}

interpreter:accept(tree)