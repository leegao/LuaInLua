local utils = require 'common.utils'

local ast = {}

function ast:accept(node)
  local action = self['on_' .. node.kind]
  local continue = true
  if action then
    continue = action(self, node)
  end
  if continue then
    for child in utils.loop(self) do
      self:accept(child)
    end
  end
end

return ast