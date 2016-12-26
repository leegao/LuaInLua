package = "luainlua"
version = "0.1-0"
source = {
   url = "git://github.com/leegao/LuaInLua",
}
description = {
   summary = "An example for the LuaRocks tutorial.",
   detailed = [[
      This is an example for the LuaRocks tutorial.
      Here we would put a detailed, typically
      paragraph-long description.
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua < 5.3",
   "bit32",
   "argparse",
}
build = {
   type = "builtin",
   modules = {
     ['luainlua.bytecode.dump'] = 'luainlua/bytecode/dump.lua',
     ['luainlua.bytecode.ir'] = 'luainlua/bytecode/ir.lua',
     ['luainlua.bytecode.opcode'] = 'luainlua/bytecode/opcode.lua',
     ['luainlua.bytecode.reader'] = 'luainlua/bytecode/reader.lua',
     ['luainlua.bytecode.undump'] = 'luainlua/bytecode/undump.lua',
     ['luainlua.bytecode.writer'] = 'luainlua/bytecode/writer.lua',
     ['luainlua.cfg.cfg'] = 'luainlua/cfg/cfg.lua',
     ['luainlua.cfg.liveness'] = 'luainlua/cfg/liveness.lua',
     ['luainlua.cfg.local_origin'] = 'luainlua/cfg/local_origin.lua',
     ['luainlua.common.graph'] = 'luainlua/common/graph.lua',
     ['luainlua.common.utils'] = 'luainlua/common/utils.lua',
     ['luainlua.common.worklist'] = 'luainlua/common/worklist.lua',
     ['luainlua.hll.hll'] = 'luainlua/hll/hll.lua',
     ['luainlua.hll.inlineable'] = 'luainlua/hll/inlineable.lua',
     ['luainlua.ll1.elimination'] = 'luainlua/ll1/elimination.lua',
     ['luainlua.ll1.ll1'] = 'luainlua/ll1/ll1.lua',
     ['luainlua.lua.ast'] = 'luainlua/lua/ast.lua',
     ['luainlua.lua.base_visitor'] = 'luainlua/lua/base_visitor.lua',
     ['luainlua.lua.compiler'] = 'luainlua/lua/compiler.lua',
     ['luainlua.lua.decompiler'] = 'luainlua/lua/decompiler.lua',
     ['luainlua.lua.parser'] = 'luainlua/lua/parser.lua',
     ['luainlua.lua.parser_table'] = 'luainlua/lua/parser_table.lua',
     ['luainlua.lua.tokenizer'] = 'luainlua/lua/tokenizer.lua',
     ['luainlua.luac'] = 'luainlua/luac.lua',
     ['luainlua.lua'] = 'luainlua/lua.lua',
     ['luainlua.generate_parser'] = 'luainlua/generate_parser.lua',
     ['luainlua.parsing.lex'] = 'luainlua/parsing/lex.lua',
     ['luainlua.parsing.ll1_grammar'] = 'luainlua/parsing/ll1_grammar.lua',
     ['luainlua.parsing.ll1_parsing_table'] = 'luainlua/parsing/ll1_parsing_table.lua',
     ['luainlua.parsing.ll1_tokenizer'] = 'luainlua/parsing/ll1_tokenizer.lua',
     ['luainlua.parsing.re'] = 'luainlua/parsing/re.lua',
   },
}