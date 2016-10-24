local tui = require "tui"

local atexit
if _VERSION == "Lua 5.1" then
	-- luacheck: std lua51
	function atexit(func)
		local proxy = newproxy(true)
		debug.setmetatable(proxy, {__gc = function() return func() end})
		table.insert(debug.getregistry(), proxy)
	end
else
	function atexit(func)
		table.insert(debug.getregistry(), setmetatable({}, {__gc = function() return func() end}))
	end
end

atexit(function()
	-- Turn all mouse reporting off
	io.stdout:write("\27[?1003l")
	os.execute("stty sane")
end)

os.execute("stty -icanon -echo")
-- Turn on mouse movement reporting
assert(io.stdout:write("\27[?1003h"))
assert(io.stdout:flush())


while true do
	local c = tui.getnext()
	print("INPUT", string.format("%q", c), c:byte(1,-1))
end
