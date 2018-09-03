local parser = require("lua-parser.parser")
local t, m = parser.parse("d=3*4", 'demnc.lua')
print(dump(t))
return print(dump(t))
