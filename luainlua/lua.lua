local luac = require 'luainlua.luac'
local argparse = require 'argparse'

function main(arg)
    local parser = argparse("script", "An example.")
    parser:argument("input", "Input file.", "--")
    parser:option("-d --dump"):args "?"
    local args = parser:parse()
    local code
    if (args.input == '--') then
        code = io.read("*all")
    else
        code = io.open(args.input, 'r'):read('*all')
    end
    local args = parser:parse()
    local func, bytecode, prototype, dumper = luac.compile(code)
    if args.dump then
        dumper(prototype)
        print("--- END OF DUMP ---")
    end
    return func()
end

main(arg)