local tui = require "tui"
local tui_util = require "tui.util"

tui_util.atexit(function()
	io.stdout:write("\27[?1002;1003l") -- Turn all mouse reporting off
	os.execute("stty sane")
end)

os.execute("stty -icanon -echo -isig")
assert(io.stdout:write(
	"\27[?1002h", -- Turn on click + drag mouse movement reporting
	"\27[?1003h" -- Turn on *all* mouse movement reporting (some terms don't support, e.g. tmux)
))
assert(io.stdout:flush())

print('Quit with "q"')
repeat
	local c = tui.getnext()
	local mouse_offset = c:match("\27%[M()") or c:match("\155M()")
	if mouse_offset then
		-- The low two bits of C b encode button information: 0=MB1 pressed, 1=MB2 pressed, 2=MB3 pressed, 3=release.
		-- The next three bits encode the modifiers which were down when the button was pressed and are added together:
		-- 4=Shift, 8=Meta, 16=Control.
		-- On button-motion events, xterm adds 32 to the event code (the third character, C b )
		-- Wheel mice may return buttons 4 and 5. Those buttons are represented by the same event codes as buttons 1 and 2 respectively,
		-- except that 64 is added to the event code.
		local cb = c:byte(mouse_offset)
		local button = cb % 4
		local shift = math.floor(cb / 4) % 2 ~= 0
		local meta = math.floor(cb / 8) % 2 ~= 0
		local ctrl = math.floor(cb / 16) % 2 ~= 0
		local button_change = math.floor(cb / 32) % 2 ~= 0
		local wheel = math.floor(cb / 64) % 2 ~= 0
		local extra = math.floor(cb / 128) % 2 ~= 0
		local b
		if wheel and button_change then
			if button == 0 then
				b = "scrollup"
			elseif button == 1 then
				b = "scrolldown"
			else
				error("UNKNOWN")
			end
		elseif button == 3 then
			if button_change then
				-- yes it's ambiguous *which* button was released
				b = "release"
			else
				b = "move"
			end
		else
			if button == 0 then
				b = "left"
			elseif button == 1 then
				b = "middle"
			elseif button == 2 then
				b = "right"
			end
			if not button_change then
				b = b .. "+drag"
			end
		end
		if shift then
			b = "shift-" .. b
		end
		if meta then
			b = "meta-" .. b
		end
		if ctrl then
			b = "ctrl-" .. b
		end
		if extra then
			b = b .. "+extra"
		end

		-- C x and C y are the x and y coordinates of the mouse event, encoded as in X10 mode.
		-- local cx, cy = utf8.codepoint(c, mouse_offset+1, -1)
		local cx, cy = string.byte(c, mouse_offset+1, -1)
		cx = cx - 32
		cy = cy - 32
		print("MOUSE", b, cx, cy, "BYTES:", c:byte(1,-1))
	else
		print("INPUT", string.format("%q", c):gsub("\\\n", "\\n"), "BYTES:", c:byte(1,-1))
	end
until c == "q"
