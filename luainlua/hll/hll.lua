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

local liveness = require 'luainlua.cfg.liveness'
local inlineable = require 'luainlua.hll.inlineable'
local undump = require 'luainlua.bytecode.undump'
local cfg = require 'luainlua.cfg.cfg'
local utils = require 'luainlua.common.utils'

local hll = {}

local function used_variables(closure, pc)
  local instr = closure.code[pc]
  return liveness.uses[instr.op](nil, pc, instr, {})
end

-- target language: hll
function hll.assign(left, right) end

function hll.jcond() end

function hll.jmp() end

function hll.ret() end

function hll.foreach() end

function hll.fori() end

-- target language: expr

local function translate(g, closure)
  -- simple syntax directed translation into hll
end

local closure = undump.undump(function(x, y) return {x, y} end)

local g = cfg.make(closure)

print(cfg.tostring(g))

local liveness_fixedpoint = liveness.solve(g, closure)
local solution = inlineable.solve(g, closure, liveness_fixedpoint)

for pc, instr in ipairs(closure.code) do
  local uses = used_variables(closure, pc)
  local inlineables = {}
  for variable in pairs(uses) do
    if solution:is_inlineable_at(pc, variable) then
      inlineables[variable] = true
    end
  end
  print(pc, instr, utils.to_list(inlineables))
end

return hll