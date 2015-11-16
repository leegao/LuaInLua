local ir = {}

function ir.label(name)
	return setmetatable({op="LABEL", name = name, ir=true},{
		__tostring = function(self) 
			return "."..tostring(self.name) 
		end, 
		__eq = function (self, other) 
			return type(other) == "table" and other.name == self.name 
		end})
end

function ir.cjmp(op, A, B, C, to)
	return setmetatable({op="CJMP", cond = op, A = A, B = B, C = C, to = to, ir=true},{
		__tostring = function(self) 
			return string.format("CJMP(op=%s, %s, %s, %s, to = %s)", self.cond, tostring(self.A), tostring(self.B) or '', tostring(self.C), self.to)
		end})
end

ir.Registers = {}

function ir.R(r)
	if ir.Registers[r] then return ir.Registers[r] end
	local register = setmetatable({r=r}, {__tostring = function(self) 
		if ir.func then 
			local name = ir.func.locals[r+1]
			if name and tostring(name):byte(1) ~= 40 then
				return 'r('..tostring(name)..')'
			end
		end 
		return "r("..r..")" 
	end})
	ir.Registers[r] = register
	return register
end

ir.Constants = {}

function ir.Kst(r)
	if ir.Constants[r] then return ir.Constants[r] end
	local register = setmetatable({k=r}, {__tostring = function(self) 
		if not ir.func then 
			return "Kst("..r..")" 
		else 
			return ''..tostring(ir.func.constants[r+1])..''
		end 
	end})
	ir.Constants[r] = register
	return register
end

function ir.RK(r)
	if r < 0x100 then
		return ir.R(r)
	else
		return ir.Kst(r-0x100)
	end
end

ir.Values = {}

function ir.V(r)
	if ir.Values[r] then return ir.Values[r] end
	local register = setmetatable({v=r}, {__tostring = function(self) return "v("..r..")" end})
	ir.Values[r] = register
	return register 
end

return ir