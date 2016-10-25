local tui_terminfo = require "tui.terminfo"

local caps, names
if arg[1] and arg[1]:match("/") then
	caps, names = assert(tui_terminfo.open(arg[1]))
else
	caps, names = assert(tui_terminfo.find(arg[1]))
end

print(names[#names])
local lines = {}
for k, v in pairs(caps) do
	if type(v) == "string" then
		v = string.format("%q", v):gsub("\n", "\\n")
	else
		v = tostring(v)
	end
	lines[#lines+1] = string.format("\t%s: %s\n", k, v)
end
table.sort(lines)
print(table.concat(lines))
