local tokenizer = require 'lua.tokenizer'

for token in tokenizer('for i = a --[==[]==] b [[ab "c"]] "') do
  print(unpack(token))
end