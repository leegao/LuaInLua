Welcome to Lua, in Lua!
===================


Hey! I'm glad you've found me. I am a somewhat correct compiler for the [Lua 5.2](http://lua.org/) language into the Lua Bytecode format, but more than that, I hope that I can become a useful guide for those who are interested in language implementation.

I grew out of a [month-long sprint](https://github.com/leegao/Lua-SideProjectMonth) from an initiative to complete a side-project within the span of the November of 2015, but I wanted to keep tredding on.

## Installation

Make sure that you have Lua 5.2 with `luarocks` installed. Note that it's possible that you may have `luarocks`
configured with `luajit`. In this case, the LUA_PATH ought to stay the same, so you can still use the `luainlua`
package; you just won't be able to run `lua.lua`.

```bash
git clone https://github.com/leegao/LuaInLua.git
cd LuaInLua
luarocks make
```

And voila, the package `luainlua` and the script `lua.lua` will be installed.

## Usage

`luainlua` comes with a scripted "interpreter" (`lua.lua`) as well as the entire compilation API.

#### lua.lua

`lua.lua filename.lua` will compile and run `filename.lua` using the luainlua compiler. In addition, you may pass
in the `-d` flag (at the very end) in order to print a human-readable disassembly, like so

```bash
leegao@DESKTOP-3RST9I3:/mnt/c/Users/leegao/Documents/IdeaProjects/LuaInLua$ lua.lua testing/hello_world.lua -d
Level 0
Code
1       (line 10)       CLOSURE(A=r(0), Bx=v(0))
2       (line 13)       MOVE(A=r(1), B=r(0))
3       (line 13)       LOADK(A=r(2), Bx=Kst(0))
4       (line 13)       LOADK(A=r(3), Bx=Kst(1))
5       (line 13)       LOADK(A=r(4), Bx=Kst(2))
6       (line 13)       CALL(A=r(1), B=v(4), C=v(1))
7       (line 9)        RETURN(A=r(0), B=v(1))
Constants
1       1
2       2
3       3
Upvalues
0       _ENV    upval   0
   Level 1
   Code
   1    (line 10)       GETTABUP(A=r(0), B=v(0), C=Kst(0):rk(256))
   2    (line 10)       VARARG(A=r(1), B=v(0))
   3    (line 10)       CALL(A=r(0), B=v(0), C=v(1))
   4    (line 10)       RETURN(A=r(0), B=v(1))
   Constants
   1    print
   Upvalues
   0    _ENV    upval   0
--- END OF DUMP ---
1       2       3
```

Additionally, if you don't specify a file to run, `lua.lua` will read from `stdin`.

#### Compilation API

You can directly invoke the `luainlua` compiler using the `luainlua.luac` package. It exposes a single `compile`
method that compiles source code (not file) into a quadruple of a lua function, its raw bytecode (in 5.2 compliant format), its internal representation in `luainlua`, and a human-readable dumper.

```lua
local luac = require 'luainlua.luac'
local func, bytecode, proto, dumper = luac.compile('print("Hello World")')
-- Inspect the disassembly of bytecode
dumper(proto)
-- Run func
func()
```

There's a wealth of internal APIs revolved around the compilation process (`luainlua.lua.*`) as well as the bytecode
format (`luainlua.bytecode.*`) that can be useful for anyone who wishes to understand the Lua internals.

#### Bootstrapping Test

The ultimate test of a compiler written in its own language is the bootstrap test. That is, can we use the compiler
to compile itself, and then use the resulting compiler to compile an arbitrary program.

Here is `hello world` in `lua.lua` in lua.

```lua
-- lua.lua
luac = require 'luainlua.luac'
func, bytecode, prototype, dumper = luac.compile('print("Hello World")')
dumper(prototype) -- Human readable disassembly
func()
-- <ctrl + d>
--[[ Level 0
   Code
   1       (line 1)        GETTABUP(A=r(0), B=v(0), C=Kst(0):rk(256))
   2       (line 1)        LOADK(A=r(1), Bx=Kst(1))
   3       (line 1)        CALL(A=r(0), B=v(2), C=v(1))
   4       (line 1)        RETURN(A=r(0), B=v(1))
   Constants
   1       print
   2       Hello World
   Upvalues
   0       _ENV    upval   0
   Hello World
]]--
```

#### Parser

In addition to the vanilla compiler, `luainlua` also comes with its own recursive-descent powered parser generator
and its own implementation of "regular" regular expression. Both of these are within the `luainlua.parsing.*` and the
`luainlua.ll1.ll1` packages. In addition, you can augment the vanilla `lua` grammar (`luainlua/lua/grammar.ylua`)
and recompile it by just requiring `luainlua.generate_parser`.

A sample grammar for the handmade parser generator is given here:
```
%file "experimental_parser"
%require "luainlua.parsing.lex"
%require "luainlua.parsing.re"

/*
root   = expr
rexpr  = %eps | $expr | PLUS $expr
expr   = $consts $rexpr | ID $rexpr | FUN ID -> $expr | LPAREN $expr RPAREN $rexpr
consts = NUMBER | STRING | TRUE | FALSE
*/

%code {:
local string_stack = {}
local function id(token) return function(...) return {token, ...} end end
local function ignore(...) return end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end
local tokenizer = lex.lex {
  root = {
    {'+', id 'PLUS'},
    {'fun', id 'FUN'},
    {'->', id 'ARROW'},
    {'(', id 'LPAREN'},
    {')', id 'RPAREN'},
    {'true', id 'TRUE'},
    {'false', id 'FALSE'},
    {re '%s+', ignore},
    {re '%d+', id 'NUMBER'},
    {re '%d+%.%d+', id 'NUMBER'},
    {re '(%a|_)(%a|%d|_|\')*', id 'ID'},
    {'"', function(piece, lexer) lexer:go 'string'; push('', string_stack) end},
  },
  string = {
    {'"', function(piece, lexer) 
      lexer:go 'root'
      return {'STRING', pop(string_stack)}
    end},
    {re '.', function(piece, lexer) 
      push(pop(string_stack) .. piece, string_stack)
    end}
  },
}
:}

%default.action {:
  function(item)
    return item
  end
:}

%prologue {:
  function(stream)
    local tokens = {}
    for token in tokenizer(stream) do
      table.insert(tokens, token)
    end
    return tokens
  end
:}

%convert {:
  function(token)
    return token[1]
  end
:}

%epilogue {:
  function(result)
    return result
  end
:}

%quote '(' LPAREN
%quote ')' RPAREN
%quote 'fun' FUN
%quote '->' ARROW
%quote '+' PLUS
%quote 'true' TRUE
%quote 'false' FALSE

consts := NUMBER
        | STRING
        | 'true'
        | 'false'

expr		:=    ('(' $expr ')' | $consts | ID ;) ( '+' $expr | $expr;)? | 'fun' ID+ '->' $expr;
root		:=    $expr;
```

This presents a lambda-calculus-esque language.

# Philosophy

Why Lua? If you're interested in language implementation, you typically see two types of tutorials out there depending on your background.

1. If you're in college, chances are you'll find your local Programming Language department to be filled with OCaml/Haskell enthusiasts pushing for compilers for mini-OCaml/Haskell/Imp. You'll be shown the purple Dragon Book and the way out.
2. If you're on your own, chances are you'll stumble across various tutorials on how to use Lex/Yacc masquerading as "How to write your own compiler!" guides. You'll learn about words, and then you get shown this weird parser language called BNF, and finally you get a grammar for some subset of C. "Parsing is the hardest part of a compiler" they'll tell you, "the rest is trivial and is subsequently left as an exercise for the reader." Finally, they'll tell you to go out and buy the purple Dragon Book.

I've tried both of these approaches, and neither worked. Obviously, the Dragon Book is to be blamed.

My philosophy: don't read, just do. This is one of the core tenets of people who love to program. No matter how hard you try, you will rarely be able to have a full end-to-end perspective on a large and complex system. Stop falling into never-ending rabbit holes and start iterating. There's no better way to learn about a domain than to get your hands dirty.

So this is my sell for my grand ambition of getting free labor. Lua turns out to be a rather curious language, both from the language design perspective as well as the choice of tooling that it uses. No matter if you're a fresh developer or a seasoned Clang hacker (that's me!), you're sure to find something fresh and interesting because the design choices made by Lua are somewhat unconventional. So come hack along and squash some bugs. Hopefully you'll gain some valuable insights that'll finally bridge you across the deep chasm between the "How to even Compilers for Dummies" and actually fleshing out your own language.

----------

![Lua](http://www.lua.org/images/logo.gif)