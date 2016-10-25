local tui = require "tui"
local tui_util = require "tui.util"

tui_util.atexit(function()
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
