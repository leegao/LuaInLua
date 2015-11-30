Let's build a Lua compiler from the ground up in Lua. Here, we will be developing our own tools from scratch along the way, which is great because Lua doesn't come with much in terms of its standard library so we get to do a lot platforming work as well :)

I will be focusing heavier on the parsing aspect of this compiler as that is the low-hanging fruit aspect of compiler construction that I haven't had a chance to explore deeply yet.

See https://github.com/leegao/Lua-In-Lua/blob/master/lua/grammar.ylua for the grammar, the parser language is written in the same language that the parser parses (yo dawg). Note that Lua's language specification is not LL(n) for any finite n, which means that any oracular lookahead machine will still not be able to parse this without angelicism. To get around this, we use an extremely clever idea: we relax the language to be parsable by LL(3) and we use the semantic action during parse time to restrict valid trees. This mix of "dynamic" and "static" parsing analysis will allow us to get a full Lua parser.

Status Report:

1. Regular expressions recognizer generator: completed!
2. Lexer generator: backend completed, pending Parser to self-host the frontend as well.
3. LL(1) Parser generator: completed, which will use the graph reduction to efficiently compute the fixed point.
4. Add nullable elimination transformation - (grammar cannot have inherent nullables anymore)
2. Eliminate production cycles (A ⩲> A)
3. Eliminte immediate left recursion
4. Create left-recursion folding mechanism
5. Create left-factor elimination
5. Self-hosting the Lexer.
6. Self-hosting the Parser.
6. Added support for extende BNF grammars
7. Added support for oracular lookaheads
1. Create a lua parser in LL(1)
1. Add semantic actions to the lua parser
1. Add a tokenizer for Lua
1. Lua 5.2 bytecode deserializer
1. AST -> Bytecode translation

In progress:

1. Lua 5.2 bytecode interpreter
2. AST -> Bytecode compiler.

TODO:

11. Standard library
12. Self-host the toolchain (5.2 compatibility)

Stretch:

4. LR(0-1) Parser, which will also use a similar mechanism
7. Type-induction.
8. Type inferencing.
