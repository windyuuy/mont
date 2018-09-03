
parser = require "lua-parser.parser"
t,m = parser.parse("d=3*4",'demnc.lua')
print(dump t)
print dump t
