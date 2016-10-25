local tui_terminfo = require "tui.terminfo"

local caps, names
if arg[1] and arg[1]:match("/") then
	caps, names = assert(tui_terminfo.open(arg[1]))
else
	caps, names = assert(tui_terminfo.find(arg[1]))
end

print(names[#names])
for k, v in pairs(caps) do
	if type(v) == "string" then
		v = string.format("%q", v):gsub("\n", "\\n")
	else
		v = tostring(v)
	end
	print(string.format("\t%s: %s", k, v))
end
