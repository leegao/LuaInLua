-- A control flow graph with "lifted" expressions

-- HLL Nodes:
-- node := assign({r, e[e]}, e)
--       | jcond({== | e}, l_fallthrough, l_jump)
--       | jmp(l)
--       | return(e)
--       | foreach(r*, e, l_fallthrough, l_jump)
--       | fori (r, e, e, e, l_fallthrough, l_jump)

-- expr := r
--       | const
--       | up
--       | e[e]
--       | {e*}
--       | e(e*)
--       | e:string(e*)
--       | e (+ | - | * | / | % | ^ | ..) e
--       | (- | not | #) e
--       | e (==, <=, <, ...) e
--       | ...

-- concretization:
-- {kind = "assign", type = "node", args...}

-- Translation is syntax directed, and then we can start merging based on liveness analysis

local liveness = require 'cfg.liveness'
local undump = require 'bytecode.undump'
local cfg = require 'cfg.cfg'
local utils = require 'common.utils'

local hll = {}


local closure = undump.undump(function(x, y) for i = 1,2,4 do foo() end end)

local g = cfg.make(closure)

local solution = liveness.solve(g, closure)

for pc, instr in ipairs(closure.code) do
  print(pc, instr, utils.to_list(solution:before(pc)), '->', utils.to_list(solution:after(pc)))
end

return hll