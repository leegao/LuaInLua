local bit = require "bit32"
local utils = require "luainlua.common.utils"

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
  if number == 0 then int(ctx, 0, 8) return end
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

local function contexualize(f)
  return function(ctx, object, ...)
    f(ctx, object, ... or ctx.sizeof_int)
    return ctx
  end
end

local writer = {
  int = contexualize(int),
  short = contexualize(short),
  byte = contexualize(byte),
  string = contexualize(string),
  double = contexualize(double),
}

function writer:configure(size)
  self.sizeof_int = size
end

function writer.new_writer()
  return setmetatable(
    {buffer = {}},
    {
      __tostring = function(self)
        return table.concat(self.buffer)
      end,
      __index = utils.copy(writer),
    }
  )
end

return writer