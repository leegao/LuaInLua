local ir = {}

function ir:label(name)
  return setmetatable({op="LABEL", name = name, ir=true},{
    __tostring = function(self) 
      return "."..tostring(self.name) 
    end, 
    __eq = function (self, other) 
      return type(other) == "table" and other.name == self.name 
    end})
end

function ir:cjmp(op, A, B, C, to)
  return setmetatable({op="CJMP", cond = op, A = A, B = B, C = C, to = to, ir=true},{
    __tostring = function(self) 
      return string.format(
        "CJMP(op=%s, %s, %s, %s, to = %s)",
        self.cond,
        tostring(self.A),
        tostring(self.B) or '',
        tostring(self.C),
        self.to)
    end})
end

function ir:R(r, pos)
  if self.Registers[r] then return self.Registers[r] end
  local register = setmetatable({r = r, pos = pos, ctx = self}, {__tostring = function()
    if self.Function then
      local name = (self.Function.debug.locals[r+1] or {}).name
      if name and tostring(name):byte(1) ~= 40 then
        return 'r('..tostring(name)..')'
      end
    end 
    return "r("..r..")" 
  end})
  self.Registers[r] = register
  return register
end

function ir:Kst(r, pos)
  if self.Constants[r] then return self.Constants[r] end
  local register = setmetatable({k = r, pos = pos, ctx = self}, {__tostring = function(self)
    if not self.Function then
      return "Kst("..r..")" 
    else 
      return ''..tostring(self.Function.constants[r+1])..''
    end 
  end})
  self.Constants[r] = register
  return register
end

function ir:RK(r, pos)
  if r < 0x100 then
    local result = self:R(r)
    return result
  else
    local result = self:Kst(r-0x100)
    return result
  end
end

function ir:V(r, pos)
  if self.Values[r] then return self.Values[r] end
  local value = setmetatable({v = r, pos = pos, ctx = self}, {__tostring = function() return "v("..r..")" end})
  self.Values[r] = value
  return value 
end

function ir:configure(func)
  self.Function = func
end

return setmetatable(
  ir, 
  {
    __call = function()
      local self = {}
      self.Values = {}
      self.Constants = {}
      self.Registers = {}
      return setmetatable(self, {__index = ir})
    end
  }
)