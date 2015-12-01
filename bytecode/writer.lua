local bit = require "bit"
local utils = require "common.utils"

local function byte(ctx, byte)
  table.insert(ctx.buffer, string.char(byte))
end

local function int(ctx, number, n)
  byte(ctx, bit.band(number, 0xff))
  if n == 1 then
    return
  end
  int(ctx, bit.rshift(number, 8), n-1)
end

local function short(ctx, number, n)
  int(ctx, number, 2)
end

local function string(ctx, str, size)
  int(ctx, #str + 1, size)
  for i = 1, #str do
    byte(ctx, str:byte(i))
  end
  byte(ctx, 0)
end

local function mantissa_to_bytes(m)
  -- 54 bits
  -- floor(2^k * m) = 2^k m_53 + ... + m_{53 - k}
  -- 0 - 31 (32 bits), 32 - 54 (23 bits)
  local hi = math.floor(0x100000 * m)
  local lo = 0x100000 * m - hi
  lo = math.floor(lo * 0x100000000)
  hi = bit.band(0xfffff, hi)
  return lo, hi
end

local function double(ctx, number)
  local m, e = math.frexp(number)
  m = 2*m
  e = e - 1
  local lo, hi_m = mantissa_to_bytes(m)
  -- 1 11 52
  -- hi:63    - sign
  -- hi:62-52 - exp
  -- hilo - 0 - man
  -- HI                               LO
  -- 00000000000000000000000000000000 00000000000000000000000000000000
  -- Seeeeeeeeeeemmmmmmmmmmmmmmmmmmmm mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
  local hi_e = bit.lshift(bit.band(0x7ff, e + 1023), 20)
  local sign = bit.lshift(number < 0 and 1 or 0, 31)
  local hi = bit.bor(sign, bit.bor(hi_m, hi_e))
  int(ctx, lo, 4)
  int(ctx, hi, 4)
end

local reader = require "bytecode.reader"

local function new_writer()
  return setmetatable(
    {buffer = {}},
    {__tostring = function(self)
      return table.concat(self.buffer)
    end})
end
local ctx = new_writer()
local n = 10234.23423425
double(ctx, n)

local x = reader.new_reader(tostring(ctx)):double()
print(x, n , x == n)