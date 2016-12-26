local utils = require 'luainlua.common.utils'

local ast = {}

function ast:before(node)
  
end

function ast:after(node, result)
  return result
end

function ast:accept(node, ...)
  if not node.kind then
    return
  end
  self:before(node)
  local action = self['on_' .. node.kind]
  local result, continue
  if action then
    result, continue = action(self, node, ...)
  end
  if continue then
    for child in utils.loop(node) do
      self:accept(child)
    end
  end
  return self:after(node, result)
end

return setmetatable(
  ast, 
  {
    __call = function(self, visitor) 
      return setmetatable(visitor, {__index = ast}) 
    end
  })