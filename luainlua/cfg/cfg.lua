-- Builds a control flow graph from bytecode

local utils = require 'luainlua.common.utils'
local undump = require 'luainlua.bytecode.undump'
local graph = require 'luainlua.common.graph'

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
  "FORLOOP",      --R(A)+=R(A+2);
  "TFORCALL",     --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
}

function cfg.build(closure)
  local g = graph()
  g:vertex(0, "START")
  g:set_root(0)
  local v = {}
  local predeccessors_map = {[1] = {{0}}}

  local function get_predecessors(to)
    return predeccessors_map[to] or {}
  end

  local function set_successors(from, to, tag)
    if not tag then tag = "fallthrough" end
    if not predeccessors_map[to] then predeccessors_map[to] = {} end
    table.insert(predeccessors_map[to], {from, tag})
  end

  function v.RETURN(pc, instr)
    g:vertex(pc, instr)
  end

  function v.JMP(pc, instr)
    g:vertex(pc, instr)
    set_successors(pc, pc + instr.sBx.raw + 1, 'jump')
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
      set_successors(pc, pc + 2, 'jump')
    end
  end

  for op in utils.loop(long_jump_ops) do
    v[op] = function(pc, instr)
      g:vertex(pc, instr)
      set_successors(pc, pc + 1)
      set_successors(pc, pc + instr.sBx.raw + 1, 'jump')
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

function cfg.coalesce(g)
  -- reduce a graph into an equivalent graph of basic blocks
  -- If N has multiple entries, it has to be an entry node
  -- If M has multiple exits, it has to be an exit node
  -- If N-M, and N is an exit node, then M is an entry node
  -- If N-M, and M is an entry node, then N is an exit node
  -- If N-M, and N is not an exit, and M is not an entry, then merge into N-M
  local entries, exits = {}, {}
  local function change(a, b)
    if a[b] then return false else a[b] = true; return true end
  end
  local changed
  repeat
    changed = false
    for node, tag, forward, reverse in g:dfs(0) do
      if #utils.to_list(reverse) > 1 then
        changed = change(entries, node) or changed
      end
      if #utils.to_list(forward) > 1 then
        changed = change(exits, node) or changed
      end
    end
    for from, to in g:edges() do
      if exits[from] then
        changed = change(entries, to) or changed
      end
      if entries[to] then
        changed = change(exits, from) or changed
      end
    end
  until not changed

  local pointers_forward, pointers_reverse = {}, {}
  local edges = {}

  for from, to, jump in g:edges() do
    if not exits[from] and not entries[to] then
      assert(not pointers_reverse[to] and not pointers_forward[from])
      pointers_forward[from] = to
      pointers_reverse[to] = from
    else
      table.insert(edges, {from, to, jump})
    end
  end

  local heads, tails = {}, {}
  local blocks = {}

  -- compute the correct chains of pointers
  local function follow(pointer, pointers, cache)
    -- return the "end" of the chain
    if cache[pointer] then return cache[pointer] end
    if pointers[pointer] then
      cache[pointer] = follow(pointers[pointer], pointers, cache)
      return cache[pointer]
    else
      cache[pointer] = pointer
      return cache[pointer]
    end
  end

  for key in g:vertices() do follow(key, pointers_forward, tails) end
  for key in g:vertices() do
    local head = follow(key, pointers_reverse, heads)
    blocks[head] = setmetatable({}, {__tostring = function(self) return tostring(table.concat(utils.map(tostring, self), '\n')) end})
  end

  local g_ = graph()
  for head, start in pairs(blocks) do
    local id = head
    while head do
      table.insert(start, g.nodes[head])
      head = pointers_forward[head]
    end
    g_:vertex(id, start)
  end

  for edge in utils.loop(edges) do
    local from, to, jump = unpack(edge)
    local from_, to_ = heads[from], heads[to]
    assert(from_, from)
    assert(to_, to)
    assert(from_ ~= to_)
    g_:edge(from_, to_, jump)
  end
  return g_
end

function cfg.tostring(g)
  return g:dot(
    function(node, self) return " [label=\"" .. tostring(node) .. "\n" .. tostring(self.nodes[node]) .. "\"]" end,
    function(c) return c == true and '' or tostring(c) end)
end

function cfg.make(closure)
  return cfg.coalesce(cfg.build(closure))
end

return cfg