local tui_terminfo = require "tui.terminfo"

local caps, names
if arg[1] then
	caps, names = assert(tui_terminfo.open(arg[1]))
else
	caps, names = assert(tui_terminfo.find())
end

print(names[#names])
for k, v in pairs(caps) do
	if type(v) == "string" then
		v = string.format("%q", v)
	else
		v = tostring(v)
	end
	print(string.format("\t%s: %s", k, v))
end
