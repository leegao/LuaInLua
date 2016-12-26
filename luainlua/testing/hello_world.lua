--local j = 0
--print(j);
--for i in function() if j == 100 then return end j = j + 1; return j end do print(i, j) end
--
--print(1 + 2 * -3 / 4)
--
--error("Hello")

local function emit(...)
  print(...)
end

emit(1, 2, 3)