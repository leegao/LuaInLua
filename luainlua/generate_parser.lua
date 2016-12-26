local generator = require 'luainlua.parsing.ll1_grammar'
local argparse = require 'argparse'

local function main(arg)
    local parser = argparse("script", "An example.")
    parser:argument("input", "Input file.", "luainlua/lua/grammar.ylua")
    parser:option("-d --dump"):args "?"
    local args = parser:parse()

    return generator(args.input)
end

main(arg)