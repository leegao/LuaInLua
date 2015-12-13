Welcome to Lua, in Lua!
===================


Hey! I'm glad you've found me. I am a somewhat correct compiler for the [Lua 5.2.4](http://lua.org/) language into the Lua Bytecode format, but more than that, I hope that I can become a useful guide for those who are interested in language implementation.

I grew out of a [month-long sprint](https://github.com/leegao/Lua-SideProjectMonth) from an initiative to complete a side-project within the span of the November of 2015, but I wanted to keep tredding on.

Why Lua? If you're interested in language implementation, you typically see two types of tutorials out there depending on your background.

1. If you're in college, chances are you'll find your local Programming Language department to be filled with OCaml/Haskell enthusiasts pushing for compilers for mini-OCaml/Haskell/Imp. You'll be shown the purple Dragon Book and the way out.
2. If you're on your own, chances are you'll stumble across various tutorials on how to use Lex/Yacc masquerading as "How to write your own compiler!" guides. You'll learn about words, and then you get shown this weird parser language called BNF, and finally you get a grammar for some subset of C. "Parsing is the hardest part of a compiler" they'll tell you, "the rest is trivial and is subsequently left as an exercise for the reader." Finally, they'll tell you to go out and buy the purple Dragon Book.

I've tried both of these approaches, and neither worked. Obviously, the Dragon Book is to be blamed.

My philosophy: don't read, just do. This is one of the core tenets of people who love to program. No matter how hard you try, you will rarely be able to have a full end-to-end perspective on a large and complex system. Stop falling into never-ending rabbit holes and start iterating. There's no better way to learn about a domain than to get your hands dirty.

So this is my sell for my grand ambition of getting free labor. Lua turns out to be a rather curious language, both from the language design perspective as well as the choice of tooling that it uses. No matter if you're a fresh developer or a seasoned Clang hacker (that's me!), you're sure to find something fresh and interesting because the design choices made by Lua are somewhat unconventional. So come hack along and squash some bugs. Hopefully you'll gain some valuable insights that'll finally bridge you across the deep chasm between the "How to even Compilers for Dummies" and actually fleshing out your own language.

----------

![Lua](http://i.imgur.com/Mo5lv.jpg)