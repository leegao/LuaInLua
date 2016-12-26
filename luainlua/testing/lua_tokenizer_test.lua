local tokenizer = require 'lua.tokenizer'
local utils = require 'common.utils'

for token in tokenizer('forward') do
  print(unpack(token))
end


for token in tokenizer('= a --[==[]==] b [[ab "c"]] "abc\'\\"" \'123\' 3.1415926e32') do
  print(unpack(token))
end

local tokens = {}
for token in tokenizer(io.open('common/graph.lua'):read('*all')) do
  table.insert(tokens, token)
end
print(utils.to_string(utils.map(function(x) return x[2] end, tokens)))