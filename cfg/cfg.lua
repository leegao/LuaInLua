-- Builds a control flow graph from bytecode

local utils = require 'common.utils'
local undump = require 'bytecode.undump'
local graph = require 'common.graph'

local cfg = {}

local simple_ops = {
  "MOVE",         --R(A) := R(B)
  "LOADK",        --R(A) := Kst(Bx)
  "LOADKX",       --R(A) := Kst(extra arg)
  "LOADNIL",      --R(A) := ... := R(B) := nil
  "GETUPVAL",     --R(A) := UpValue[B]
  "GETTABUP",     --R(A) := UpValue[B][RK(C)]
  "GETTABLE",     --R(A) := R(B)[RK(C)]
  "SETTABUP",     --UpValue[A][RK(B)] := RK(C)
  "SETUPVAL",     --UpValue[B] := R(A)
  "SETTABLE",     --R(A)[RK(B)] := RK(C)
  "NEWTABLE",     --R(A) := {} (size = B,C)
  "SELF",         --R(A+1) := R(B); R(A) := R(B)[RK(C)]
  "ADD",          --R(A) := RK(B) + RK(C)
  "SUB",          --R(A) := RK(B) - RK(C)
  "MUL",          --R(A) := RK(B) * RK(C)
  "DIV",          --R(A) := RK(B) / RK(C)
  "MOD",          --R(A) := RK(B) % RK(C)
  "POW",          --R(A) := RK(B) ^ RK(C)
  "UNM",          --R(A) := -R(B)
  "NOT",          --R(A) := not R(B)
  "LEN",          --R(A) := length of R(B)
  "CONCAT",       --R(A) := R(B).. ... ..R(C)
  "CALL",         --R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
  "TAILCALL",     --return R(A)(R(A+1), ... ,R(A+B-1))
  "FORLOOP",      --R(A)+=R(A+2);
  "TFORCALL",     --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
  "SETLIST",      --R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
  "CLOSURE",      --R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))
  "VARARG",       --R(A), R(A+1), ..., R(A+B-1) = vararg
  "EXTRAARG",     --extra (larger) argument for previous opcode
}

local jump_ops = {
  "LOADBOOL",     --R(A) := (Bool)B; if (C) pc++
  "EQ",           --if ((RK(B) == RK(C)) ~= A) then pc++
  "LT",           --if ((RK(B) <  RK(C)) ~= A) then pc++
  "LE",           --if ((RK(B) <= RK(C)) ~= A) then pc++
  "TEST",         --if not (R(A) <=> C) then pc++
  "TESTSET",      --if (R(B) <=> C) then R(A) := R(B) else pc++
}

local long_jump_ops = {
  "FORPREP",      --R(A)-=R(A+2); pc+=sBx
  "TFORLOOP",     --if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
}

local function build(closure)
  local g = graph()
  g:vertex(0, "START")
  g:set_root(0)
  local v = {}
  local predeccessors_map = {[1] = {{0}}}

  local function get_predecessors(to)
    return predeccessors_map[to] or {}
  end

  local function set_successors(from, to, tag)
    if not predeccessors_map[to] then predeccessors_map[to] = {} end
    table.insert(predeccessors_map[to], {from, tag})
  end

  function v.RETURN(pc, instr)
    g:vertex(pc, instr)
  end

  function v.JMP(pc, instr)
    g:vertex(pc, instr)
    set_successors(pc, pc + instr.sBx.raw + 1, true)
  end

  for op in utils.loop(simple_ops) do
    v[op] = function(pc, instr)
      g:vertex(pc, instr)
      set_successors(pc, pc + 1)
    end
  end

  for op in utils.loop(jump_ops) do
    v[op] = function(pc, instr)
      g:vertex(pc, instr)
      set_successors(pc, pc + 1)
      set_successors(pc, pc + 2, true)
    end
  end

  for op in utils.loop(long_jump_ops) do
    v[op] = function(pc, instr)
      g:vertex(pc, instr)
      set_successors(pc, pc + 1)
      set_successors(pc, pc + instr.sBx.raw + 1, true)
    end
  end

  for pc, instr in ipairs(closure.code) do
    v[instr.op](pc, instr)
  end

  for to, froms in pairs(predeccessors_map) do
    for from_pair in utils.loop(froms) do
      local from, tag = unpack(from_pair)
      g:edge(from, to, tag)
    end
  end

  local function get_reachable_nodes()
    local reachable = {}
    for node in g:dfs(0) do
      reachable[node] = true
    end
    return reachable
  end

  -- eliminate dead nodes
  local reachable_nodes = get_reachable_nodes()
  local dead_nodes = {}
  for node in g:vertices() do
    if not reachable_nodes[node] then
      g:remove_vertex(node)
    end
  end

  return g
end

local closure = undump.undump(function(a) return a and b end)

local g = build(closure)

print(g:dot(function(node, self) return " [label=\"" .. tostring(self.nodes[node]) .. "\"]" end))

return cfg