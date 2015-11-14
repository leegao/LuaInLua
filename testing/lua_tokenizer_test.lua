local tokenizer = require 'lua.tokenizer'

for token in tokenizer('for i = a --[==[]==] b [[ab "c"]] "abc\'\\"" \'123\' 3') do
  print(unpack(token))
end