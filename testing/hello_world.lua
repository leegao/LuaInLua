local j = 1
print(j);
for i in function() if j == 100 then return end j = j + 1; return j end do print(i, j) end
