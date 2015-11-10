Let's build a compiler from the ground up in Lua. Here, we will be developing our own tools from scratch along the way, which is great because Lua doesn't come with much in terms of its standard library so we get to do a lot platforming work as well :)

I will be focusing heavier on the parsing aspect of this compiler as that is the low-hanging fruit aspect of compiler construction that I haven't had a chance to explore deeply yet.

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

In progress:

1. Create a lua parser in LL(1)

TODO:

4. LR(0-1) Parser, which will also use a similar mechanism

7. Type-induction.
8. Type inferencing.
9. Interpreter.