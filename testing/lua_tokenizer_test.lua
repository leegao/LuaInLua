local tokenizer = require 'lua.tokenizer'

for token in tokenizer('for i = a --[==[]==] b') do
  print(unpack(token))
end