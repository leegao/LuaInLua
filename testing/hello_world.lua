local j = 1
print(j)
print(j)
(function() print(111) return j end)(1,2)

local k = j
