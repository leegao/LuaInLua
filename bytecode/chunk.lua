local opcode = require "bytecode.opcode"
local reader  = require "bytecode.reader"

local function header(ctx)
	assert(ctx:int()  == 0x61754c1b) -- ESC. Lua
	assert(ctx:byte() == 0x51) -- version
	assert(ctx:byte() == 0) -- format version
	assert(ctx:byte() == 1) -- little endian
	assert(ctx:byte() == 4) -- sizeof(int)
	assert(ctx:byte() == 4) -- sizeof(size_t)
	assert(ctx:byte() == 4) -- sizeof(Instruction)
	assert(ctx:byte() == 8) -- sizeof(number)
	assert(ctx:byte() == 0) -- is integer
end

local function generic_list(ctx, f)
	local n = ctx:int()
	local ret = {}
	for i=1,n do
		table.insert(ret, f(ctx))
	end
	return ret
end

local function constant(ctx)
	local type = ctx:byte()
	if type == 0 then
		return nil
	elseif type == 1 then
		return ctx:byte() ~= 0
	elseif type == 3 then
		return ctx:double()
	elseif type == 4 then
		return ctx:string()
	end
end

local function func(ctx)
	local source_name  = ctx:string()
	
	local first_line   = ctx:int()
	
	local last_line    = ctx:int()
	local nups         = ctx:byte()
	local nparams      = ctx:byte()
	local is_vararg    = ctx:byte()
	local stack_size   = ctx:byte()
	
	local instructions = generic_list(ctx, function(ctx) return opcode.instruction(reader.int(ctx)) end)
	local constants    = generic_list(ctx, constant)
	
	local protos       = generic_list(ctx, func)
	
	local line_num     = generic_list(ctx, reader.int)
	local locals       = generic_list(ctx, function(ctx) return setmetatable({ctx:string(), ctx:int(), ctx:int()}, 
							{__tostring = function(self) return self[1] end, 
							__eq = function(self, other) return tostring(self) == tostring(other) end}) end)
	local upvalues     = generic_list(ctx, reader.string)
	
	return {
		source_name  = source_name,
		first_line   = first_line,
		last_line    = last_line,
		nups         = nups,
		nparams      = nparams,
		is_vararg    = is_vararg,
		stack_size   = stack_size,
		instructions = instructions,
		constants    = constants,
		funcs        = protos,
		line_num     = line_num,
		locals       = locals,
		upvalues     = upvalues
	}
end


--local ctx = reader.new_ctx(string.dump(loadfile 'test.lua'))
--
--header(ctx)
--
--for i,v in ipairs(func(ctx).instructions) do
--	print(i, v)
--end

return {header=header, func=func}