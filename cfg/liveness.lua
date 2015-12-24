-- Live variable analysis: computing whether a register is live at a program point

local utils = require 'common.utils'
local cfg = require 'cfg.cfg'
local undump = require 'bytecode.undump'
local worklist = require 'common.worklist'

local liveness = {}

local A = function(instr) return {instr.A} end
local B = function(instr) return {instr.B} end
local C = function(instr) return {instr.C} end
local function range(from, number)
  return function(instr)
    local left = unpack(from(instr))
    local num = unpack(number(instr))
    local registers = {}
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
    return {invert and (left - off) or (left + off)}
  end
end
local function constant(n)
  return function() return n end
end


local function dataflow()
  local solutions = {
    pc_to_before = {},
    pc_to_after = {},
  }

  local actions = {
    {"MOVE", kill(A), use(B)},                                          --R(A) := R(B)
    {"LOADK", kill(A), use()},                                          --R(A) := Kst(Bx)
    {"LOADKX", kill(A), use()},                                         --R(A) := Kst(extra arg)
    {"LOADBOOL", kill(A), use()},                                       --R(A) := (Bool)B; if (C) pc++
    {"LOADNIL", kill(range(A, offset(B, A, true))), use()},             --R(A) := ... := R(B) := nil
    {"GETUPVAL", kill(A), use()},                                       --R(A) := UpValue[B]
    {"GETTABUP", kill(A), use(C)},                                      --R(A) := UpValue[B][RK(C)]
    {"GETTABLE", kill(A), use(B, C)},                                   --R(A) := R(B)[RK(C)]
    {"SETTABUP", kill(), use(B, C)},                                    --UpValue[A][RK(B)] := RK(C)
    {"SETUPVAL", kill(), use(A)},                                       --UpValue[B] := R(A)
    {"SETTABLE", kill(), use(A, B, C)},                                 --R(A)[RK(B)] := RK(C)
    {"NEWTABLE", kill(A), use()},                                       --R(A) := {} (size = B,C)
    {"SELF", kill(A, offset(A, constant(1))), use(B, C)},               --R(A+1) := R(B); R(A) := R(B)[RK(C)]
    {"ADD", kill(A), use(B, C)},                                        --R(A) := RK(B) + RK(C)
    {"SUB", kill(A), use(B, C)},                                        --R(A) := RK(B) - RK(C)
    {"MUL", kill(A), use(B, C)},                                        --R(A) := RK(B) * RK(C)
    {"DIV", kill(A), use(B, C)},                                        --R(A) := RK(B) / RK(C)
    {"MOD", kill(A), use(B, C)},                                        --R(A) := RK(B) % RK(C)
    {"POW", kill(A), use(B, C)},                                        --R(A) := RK(B) ^ RK(C)
    {"UNM", kill(A), use(B)},                                           --R(A) := -R(B)
    {"NOT", kill(A), use(B)},                                           --R(A) := not R(B)
    {"LEN", kill(A), use(B)},                                           --R(A) := length of R(B)
    {"CONCAT", kill(A), use(range(B, offset(C, B, true)))},             --R(A) := R(B).. ... ..R(C)
    {"JMP", kill(), use()},                                             --pc+=sBx
    {"EQ", kill(), use(B, C)},                                          --if ((RK(B) == RK(C)) ~= A) then pc++
    {"LT", kill(), use(B, C)},                                          --if ((RK(B) <  RK(C)) ~= A) then pc++
    {"LE", kill(), use(B, C)},                                          --if ((RK(B) <= RK(C)) ~= A) then pc++
    {"TEST", kill(), use(A)},                                           --if not (R(A) <=> C) then pc++
    {"TESTSET", kill(A), use(B)},                                       --if (R(B) <=> C) then R(A) := R(B) else pc++
    {"CALL",
      kill(range(A, offset(C, constant(-2)))),
      use(range(A, offset(B, constant(-1))))},                          --R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
    {"TAILCALL", kill(), use(range(A, offset(B, constant(-1))))},       --return R(A)(R(A+1), ... ,R(A+B-1))
    {"RETURN", kill(), use(range(A, offset(B, constant(-2))))},         --return R(A), ... ,R(A+B-2)(see note)
    {"FORLOOP",
      kill(A, offset(A, constant(3))),
      use(A, offset(A, constant(1)), offset(A, constant(2)))},          --R(A)+=R(A+2);
    {"FORPREP", kill(A), use(A, offset(A, constant(2)))},               --R(A)-=R(A+2); pc+=sBx
    {"TFORCALL",
      kill(range(offset(A, constant(3)), offset(C, constant(-1)))),
      use(A, offset(A, constant(1)), offset(A, constant(2)))},          --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
    {"TFORLOOP", kill(A), use(offset(A, constant(1)))},                 --if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
    {"SETLIST", kill(), use(range(A, B))},                              --R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
    {"CLOSURE", kill(A), use()},                                        --R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))
    {"VARARG", kill(range(A, offset(B, constant(-1)))), use()},                           --R(A), R(A+1), ..., R(A+B-1) = vararg
    {"EXTRAARG", kill(), use()},                                        --extra (larger) argument for previous opcode
  }

  local dataflow = worklist {
    -- what is the domain? Sets of registers that are still live
    initialize = function(self, node, _)
      return {}
    end,
    transfer = function(self, node, live_in, graph)
      -- if the incoming is epsilon, then add, otherwise pass
      local block = graph.nodes[node]
      local current = utils.copy(live_in)
      for i, instr in ipairs(block) do
        local pc = node + i - 1
        solutions.pc_to_after[pc] = current
        current = utils.copy(
          interpreter[instr.op](self, pc, instr, current, graph, node, solutions))
        solutions.pc_to_before[pc] = current
      end
      return live_in
    end,
    changed = function(self, old, new)
      -- assuming monotone in the new direction
      for key in pairs(new) do
        if not old[key] then
          return true
        end
      end
      return false
    end,
    merge = function(self, left, right)
      local merged = utils.copy(left)
      for key in pairs(right) do
        merged[key] = true
      end
      return merged
    end,
    tostring = function(self, _, node, state)
      local keys = {}
      for key in pairs(state) do
        table.insert(keys, key)
      end
      return tostring(node) .. ' {' .. table.concat(keys, ', ') .. '}'
    end,

    solution = {
      pc_to_before = {},
      pc_to_after = {},
    }
  }
  return dataflow
end

local closure = undump.undump(function(x, y) for i = 1,2,4 do foo() end end)

local g = cfg.make(closure)

print(cfg.tostring(g))

dataflow():reverse(g)

return liveness