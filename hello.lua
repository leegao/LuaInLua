local ll1 = require 'll1'
local parser = require 'testing.experimental_parser'
local utils = require 'utils'

local function dump_tree(tree)
  if not tree.kind then return tree end
  local subtrees = {}
  for subtree in utils.loop(tree) do
    table.insert(subtrees, dump_tree(subtree))
  end
  return ('%s(%s)'):format(tree.kind, table.concat(subtrees, ', '))
end

print(ll1.configure(parser.grammar):pretty())

local tree = parser("(fun x -> 1 + x) 3")
print(tree)