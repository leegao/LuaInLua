-- Computes the local origin of a variable definition

local utils = require 'luainlua.common.utils'
local cfg = require 'luainlua.cfg.cfg'
local undump = require 'luainlua.bytecode.undump'
local worklist = require 'luainlua.common.worklist'

local TOP = 'TOP'

local origin = {}

local woot = function(n) n = unpack(n) return n > 255 and {} or {n} end

local A = function(instr) return woot {instr.A.raw} end
local B = function(instr) return woot {instr.B.raw} end
local C = function(instr) return woot {instr.C.raw} end
local function top(number)
  return function(instr)
    local x = unpack(number(instr))
    if x == 0 then
      return {TOP}
    end
    return {x}
  end
end
local function range(from, number)
  return function(instr)
    local left = unpack(from(instr))
    local num = unpack(number(instr))
    local registers = {}
    if num == TOP then return {left} end
    for i = 0, num do
      table.insert(registers, left + i)
    end
    return registers
  end
end
local function offset(start, amount, invert)
  return function(instr)
    local left = unpack(start(instr))
    local off = unpack(amount(instr))
    if left == TOP then return {TOP} end
    return {invert and (left - off) or (left + off)}
  end
end
local function constant(n)
  return function() return {n} end
end

local function kill(...)
  local actions = {...}
  return function(self, pc, instr, current, graph, node)
    local new = utils.copy(current)
    for action in utils.loop(actions) do
      for register in utils.loop(action(instr)) do
        new[register] = {[pc] = true}
      end
    end
    return new
  end
end

local actions = {
  {"MOVE", kill(A)},                                          --R(A) := R(B)
  {"LOADK", kill(A)},                                          --R(A) := Kst(Bx)
  {"LOADKX", kill(A)},                                         --R(A) := Kst(extra arg)
  {"LOADBOOL", kill(A)},                                       --R(A) := (Bool)B; if (C) pc++
  {"LOADNIL", kill(range(A, offset(B, A, true)))},             --R(A) := ... := R(B) := nil
  {"GETUPVAL", kill(A)},                                       --R(A) := UpValue[B]
  {"GETTABUP", kill(A)},                                      --R(A) := UpValue[B][RK(C)]
  {"GETTABLE", kill(A)},                                   --R(A) := R(B)[RK(C)]
  {"SETTABUP", kill()},                                    --UpValue[A][RK(B)] := RK(C)
  {"SETUPVAL", kill()},                                       --UpValue[B] := R(A)
  {"SETTABLE", kill()},                                 --R(A)[RK(B)] := RK(C)
  {"NEWTABLE", kill(A)},                                       --R(A) := {} (size = B,C)
  {"SELF", kill(A, offset(A, constant(1)))},               --R(A+1) := R(B); R(A) := R(B)[RK(C)]
  {"ADD", kill(A)},                                        --R(A) := RK(B) + RK(C)
  {"SUB", kill(A)},                                        --R(A) := RK(B) - RK(C)
  {"MUL", kill(A)},                                        --R(A) := RK(B) * RK(C)
  {"DIV", kill(A)},                                        --R(A) := RK(B) / RK(C)
  {"MOD", kill(A)},                                        --R(A) := RK(B) % RK(C)
  {"POW", kill(A)},                                        --R(A) := RK(B) ^ RK(C)
  {"UNM", kill(A)},                                           --R(A) := -R(B)
  {"NOT", kill(A)},                                           --R(A) := not R(B)
  {"LEN", kill(A)},                                           --R(A) := length of R(B)
  {"CONCAT", kill(A)},             --R(A) := R(B).. ... ..R(C)
  {"JMP", kill()},                                             --pc+=sBx
  {"EQ", kill()},                                          --if ((RK(B) == RK(C)) ~= A) then pc++
  {"LT", kill()},                                          --if ((RK(B) <  RK(C)) ~= A) then pc++
  {"LE", kill()},                                          --if ((RK(B) <= RK(C)) ~= A) then pc++
  {"TEST", kill()},                                           --if not (R(A) <=> C) then pc++
  {"TESTSET", kill(A)},                                       --if (R(B) <=> C) then R(A) := R(B) else pc++
  {"CALL",
    kill(range(A, offset(top(C), constant(-2))))},                          --R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
  {"TAILCALL", kill()},       --return R(A)(R(A+1), ... ,R(A+B-1))
  {"RETURN", kill()},         --return R(A), ... ,R(A+B-2)(see note)
  {"FORLOOP",
    kill(A, offset(A, constant(1)), offset(A, constant(2)), offset(A, constant(3)))},                                                           --R(A)+=R(A+2);
  --if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }
  {"FORPREP",
    kill(A, offset(A, constant(3)))},          --R(A)-=R(A+2); pc+=sBx
  {"TFORCALL",
    kill(range(offset(A, constant(3)), offset(C, constant(-1))))},          --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
  {"TFORLOOP", kill(A)},                 --if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
  {"SETLIST", kill()},                              --R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
  {"CLOSURE", kill(A)},                                        --R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))
  {"VARARG", kill(range(A, offset(B, constant(-1))))},                           --R(A), R(A+1), ..., R(A+B-1) = vararg
  {"EXTRAARG", kill()},                                        --extra (larger) argument for previous opcode
}

local function solve(g, closure)
  local solutions = {
    pc_to_before = {},
    pc_to_after = {},
    first = {},
  }

  local interpreter = {}
  for bundle in utils.loop(actions) do
    interpreter[bundle[1]] = function(self, pc, instr, current, graph, node)
      return bundle[2](self, pc, instr, current, graph, node)
    end
  end

  local dataflow = worklist {
    -- what is the domain? Sets of registers that are still live
    initialize = function(self, node, _)
      return {}
    end,
    transfer = function(self, node, live_in, graph)
      -- if the incoming is epsilon, then add, otherwise pass
      local block = graph.nodes[node]
      local current = utils.copy(live_in)
      local pc = node
      local start = true
      for instr in utils.loop(block) do
        if not start then
          solutions.pc_to_before[pc] = current
        else
          solutions.pc_to_before[pc] = self:merge(solutions.pc_to_before[pc] or self:initialize(node), current)
        end
        start = false
        if instr.op then
          current = utils.copy(interpreter[instr.op](self, pc, instr, current, graph, node))
        end
        solutions.pc_to_after[pc] = current

        pc = pc + 1
      end
      return current
    end,
    changed = function(self, old, new)
      -- assuming monotone in the new direction
      for key in pairs(new) do
        if not old[key] then
          return true
        end
        for k in pairs(old) do
          if not new[k] then
            return true
          end
        end
      end
      return false
    end,
    merge = function(self, left, right)
      local keys = {}
      for key in pairs(left) do
        keys[key] = true
      end
      for key in pairs(right) do
        keys[key] = true
      end
      local merged = {}
      for key in pairs(keys) do
        merged[key] = {}
        for k in pairs(left[key] or {}) do
          merged[key][k] = true
        end
        for k in pairs(right[key] or {}) do
          merged[key][k] = true
        end
      end
      return merged
    end,
    tostring = function(self, _, node, state)
      local keys = {}
      for key, value in pairs(state) do
        table.insert(keys, ('%s:%s'):format(key, utils.to_list(value)))
      end
      return tostring(node) .. ' {' .. table.concat(keys, ', ') .. '}'
    end,

    solution = {
      before = function(self, pc)
        return solutions.pc_to_before[pc]
      end,
      after = function(self, pc)
        return solutions.pc_to_after[pc]
      end
    }
  }
  return dataflow:forward(g)
end

--local closure = undump.undump(function(x, y) for i = 1,2,4 do x = function() print(i) end end end)
--
--local g = cfg.make(closure)
--
--print(cfg.tostring(g))
--
--local solution = solve(g, closure)
--
--for pc, instr in ipairs(closure.code) do
--  local function origin_print(sol)
--    local x = {}
--    for key, val in pairs(sol) do
--      local str = ('%s:{%s}'):format(key, utils.to_list(val))
--      table.insert(x, str)
--    end
--    return utils.to_string(x)
--  end
--  print(pc, instr, origin_print(solution:before(pc)), '->', origin_print(solution:after(pc)))
--end

origin.solve = solve

return origin