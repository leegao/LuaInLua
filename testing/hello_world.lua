local j = 1
print(j);
local new = (function() j = j + 1; return j end)(1,2)

print(new, j)
