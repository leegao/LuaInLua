local bit = require "bit32"
local ir =  require "luainlua.bytecode.ir"
local utils = require "luainlua.common.utils"
--[[
/*----------------------------------------------------------------------
name      args  description
------------------------------------------------------------------------*/
OP_MOVE,/*      A B    R(A) := R(B)          */
OP_LOADK,/*      A Bx  R(A) := Kst(Bx)          */
OP_LOADBOOL,/*  A B C  R(A) := (Bool)B; if (C) pc++      */
OP_LOADNIL,/*  A B    R(A) := ... := R(B) := nil      */
OP_GETUPVAL,/*  A B    R(A) := UpValue[B]        */

OP_GETGLOBAL,/*  A Bx  R(A) := Gbl[Kst(Bx)]        */
OP_GETTABLE,/*  A B C  R(A) := R(B)[RK(C)]        */

OP_SETGLOBAL,/*  A Bx  Gbl[Kst(Bx)] := R(A)        */
OP_SETUPVAL,/*  A B    UpValue[B] := R(A)        */
OP_SETTABLE,/*  A B C  R(A)[RK(B)] := RK(C)        */

OP_NEWTABLE,/*  A B C  R(A) := {} (size = B,C)        */

OP_SELF,/*      A B C  R(A+1) := R(B); R(A) := R(B)[RK(C)]    */

OP_ADD,/*      A B C  R(A) := RK(B) + RK(C)        */
OP_SUB,/*      A B C  R(A) := RK(B) - RK(C)        */
OP_MUL,/*      A B C  R(A) := RK(B) * RK(C)        */
OP_DIV,/*      A B C  R(A) := RK(B) / RK(C)        */
OP_MOD,/*      A B C  R(A) := RK(B) % RK(C)        */
OP_POW,/*      A B C  R(A) := RK(B) ^ RK(C)        */
OP_UNM,/*      A B    R(A) := -R(B)          */
OP_NOT,/*      A B    R(A) := not R(B)        */
OP_LEN,/*      A B    R(A) := length of R(B)        */

OP_CONCAT,/*  A B C  R(A) := R(B).. ... ..R(C)      */

OP_JMP,/*      sBx    pc+=sBx          */

OP_EQ,/*      A B C  if ((RK(B) == RK(C)) ~= A) then pc++    */
OP_LT,/*      A B C  if ((RK(B) <  RK(C)) ~= A) then pc++      */
OP_LE,/*      A B C  if ((RK(B) <= RK(C)) ~= A) then pc++      */

OP_TEST,/*      A C    if not (R(A) <=> C) then pc++      */
OP_TESTSET,/*  A B C  if (R(B) <=> C) then R(A) := R(B) else pc++  */

OP_CALL,/*      A B C  R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1)) */
OP_TAILCALL,/*  A B C  return R(A)(R(A+1), ... ,R(A+B-1))    */
OP_RETURN,/*  A B    return R(A), ... ,R(A+B-2)  (see note)  */

OP_FORLOOP,/*  A sBx  R(A)+=R(A+2);
            if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }*/
OP_FORPREP,/*  A sBx  R(A)-=R(A+2); pc+=sBx        */

OP_TFORLOOP,/*  A C    R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
                        if R(A+3) ~= nil then R(A+2)=R(A+3) else pc++  */
OP_SETLIST,/*  A B C  R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B  */

OP_CLOSURE,/*  A Bx  R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))  */

OP_VARARG/*      A B    R(A), R(A+1), ..., R(A+B-1) = vararg    */
]]--

local OPCODES = {
  "MOVE",         --R(A) := R(B)
  "LOADK",        --R(A) := Kst(Bx)
  "LOADKX",       --R(A) := Kst(extra arg)
  "LOADBOOL",     --R(A) := (Bool)B; if (C) pc++
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
  "JMP",          --pc+=sBx
  "EQ",           --if ((RK(B) == RK(C)) ~= A) then pc++
  "LT",           --if ((RK(B) <  RK(C)) ~= A) then pc++
  "LE",           --if ((RK(B) <= RK(C)) ~= A) then pc++
  "TEST",         --if not (R(A) <=> C) then pc++
  "TESTSET",      --if (R(B) <=> C) then R(A) := R(B) else pc++
  "CALL",         --R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
  "TAILCALL",     --return R(A)(R(A+1), ... ,R(A+B-1))
  "RETURN",       --return R(A), ... ,R(A+B-2)(see note)
  "FORLOOP",      --R(A)+=R(A+2);
  "FORPREP",      --R(A)-=R(A+2); pc+=sBx
  "TFORCALL",     --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
  "TFORLOOP",     --if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
  "SETLIST",      --R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
  "CLOSURE",      --R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))
  "VARARG",       --R(A), R(A+1), ..., R(A+B-1) = vararg
  "EXTRAARG",     --extra (larger) argument for previous opcode
}

for v,k in ipairs(OPCODES) do
  OPCODES[k] = v
end

local A, B, C, Ax, Bx, sBx = 'A', 'B', 'C', 'Ax', 'Bx', 'sBx'
local R, RK, Kst, V = ir.R, ir.RK, ir.Kst, ir.V
local ARGS = {
  {{A, R}, {B, R}}, --R(A) := R(B)
  {{A, R}, {Bx, Kst}},     --R(A) := Kst(Bx)
  {{A, R}},  --R(A) := Kst(extra arg) (next instruction is extra args)
  {{A, R}, {B, V}, {C, V}}, --R(A) := (Bool)B; if (C) pc++
  {{A, R}, {B, R}}, --R(A) := ... := R(B) := nil
  {{A, R}, {B, V}}, --R(A) := UpValue[B]
  {{A, R}, {B, V}, {C, RK}}, --R(A) := UpValue[B][RK(C)]
  {{A, R}, {B, R}, {C, RK}}, --R(A) := R(B)[RK(C)]
  {{A, V}, {B, RK}, {C, RK}}, --UpValue[A][RK(B)] := RK(C)
  {{A, R}, {B, V}}, --UpValue[B] := R(A)
  {{A, R}, {B, RK}, {C, RK}}, --R(A)[RK(B)] := RK(C)
  {{A, R}, {B, V}, {C, V}}, --R(A) := {} (size = B,C)
  {{A, R}, {B, RK}, {C, RK}}, --R(A) := RK(B) + RK(C)
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, RK}, {C, RK}},
  {{A, R}, {B, R}}, --R(A) := -R(B)
  {{A, R}, {B, R}},
  {{A, R}, {B, R}}, --R(A) := length of R(B)
  {{A, R}, {B, R}, {C, R}}, --R(A) := R(B).. ... ..R(C)
  {{A, V}, {sBx, V}}, --pc+=sBx; if (A) close all upvalues >= R(A - 1)
  {{A, V}, {B, RK}, {C, RK}}, --if ((RK(B) == RK(C)) ~= A) then pc++
  {{A, V}, {B, RK}, {C, RK}},
  {{A, V}, {B, RK}, {C, RK}},
  {{A, R}, {C, V}}, --if not (R(A) <=> C) then pc++
  {{A, R}, {B, R}, {C, V}}, --if (R(B) <=> C) then R(A) := R(B) else pc++
  {{A, R}, {B, V}, {C, V}}, --R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
  {{A, R}, {B, R}, {C, function() return V(0) end}}, --return R(A)(R(A+1), ... ,R(A+B-1))
  {{A, R}, {B, V}}, --return R(A), ... ,R(A+B-2)(see note)
  {{A, R}, {sBx, V}}, --R(A)+=R(A+2)
  {{A, R}, {sBx, V}},
  {{A, R}, {C, V}}, --R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
  {{A, R}, {sBx, V}}, --if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
  {{A, R}, {B, V}, {C, V}},
  {{A, R}, {Bx, V}},
  {{A, R}, {B, V}},
  {{Ax, V}}
}

local OPMT = {__tostring = function(self)
    local r = {"A", "B", "C", "Ax", "Bx", "sBx"}
    local r2 = {}
    for _,v in ipairs(r) do
      if v == "sBx" and self.to then
        table.insert(r2,string.format("to=%s",self.to))
      elseif self[v] then
        table.insert(r2,string.format("%s=%s",v,tostring(self[v])))
      end
    end
    return string.format("%s(%s)",self.op, table.concat(r2, ', '))
  end}

local function instruction(ctx, int, position)
  -- 6 8 9 9
  local op = bit.band(int, 0x3f)+1
  local A  = bit.rshift(bit.band(int, 0x3fc0), 6)
  local C  = bit.rshift(bit.band(int, 0x7fc000), 6+8)
  local B  = bit.rshift(bit.band(int, 0xff800000), 6+8+9)
  local Ax = bit.rshift(int, 6)
  local Bx = bit.lshift(B, 9)+C
  local sBx = Bx - 131071
  local this = {A = A, B = B, C = C, Ax = Ax, Bx = Bx, sBx = sBx }
  if not OPCODES[op] then
    error("Opcode " .. op .. " not found!")
  end

  local inst = setmetatable({op = OPCODES[op]}, OPMT)
  for _,v in ipairs(ARGS[op]) do
    inst[v[1]] = v[2](ctx, this[v[1]], position)
  end
  
  return inst
end

local function serialize(instruction)
  -- data, pos, ctx
  local op = OPCODES[instruction.op]
  local A  = function(int) return bit.lshift(bit.band(int, 0xff), 6) end
  local C  = function(int) return bit.lshift(bit.band(int, 0x1ff), 6+8) end
  local B  = function(int) return bit.lshift(bit.band(int, 0x1ff), 6+8+9) end
  local Ax = function(int) return bit.lshift(int, 6) end
  local Bx = function(int) return bit.lshift(int, 14) end
  local sBx = function(int) return Bx(int + 131071) end
  local this = {A = A, B = B, C = C, Ax = Ax, Bx = Bx, sBx = sBx }
  local serialized_instruction = op - 1

  for i, parameter in ipairs(ARGS[op]) do
    local type = unpack(parameter)
    local arg = instruction[type]
    serialized_instruction = bit.bor(serialized_instruction, this[type](arg.raw))
  end
  return serialized_instruction
end

local function make(ctx, pc, name, ...)
  local op = OPCODES[name]
  assert(ARGS[op], tostring(name))
  local inst = setmetatable({op = OPCODES[op]}, OPMT)
  local arguments = {...}
  assert(
    #ARGS[op] == #arguments,
    "Wrong number of arguments for " .. name .. ", expecting " .. #ARGS[op] .. " but got " .. #arguments .. " instead.")
  for i, parameter in ipairs(ARGS[op]) do
    local type, func = unpack(parameter)
    inst[type] = func(ctx, arguments[i], pc)
  end
  return inst
end

return {instruction = instruction, serialize = serialize, make = make, OPCODES = OPCODES, ARGS = ARGS, OPMT = OPMT}