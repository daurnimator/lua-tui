local function make_filter(func)
	return function(rawgetnext, wrap, emit)
		if wrap == nil then
			wrap = coroutine.wrap
		end
		if emit == nil then
			emit = coroutine.yield
		end
		local function getnext()
			local c, err, errno = rawgetnext()
			if c == nil then
				while true do
					emit(nil, err, errno)
				end
			end
			return c
		end
		return wrap(function()
			return func(getnext, emit)
		end)
	end
end

local filter_esc = make_filter(function(getnext, emit)
	while true do
		local c = getnext()
		if c == "\27" then
			-- If multiple ESC in a row just emit them
			while true do
				c = getnext()
				if c ~= "\27" then
					break
				end
				emit(c)
			end
			emit("\27" .. c)
		else
			emit(c)
		end
	end
end)

local filter_csi = make_filter(function(getnext, emit)
	while true do
		local c = getnext()
		if c == "\27[" then
			-- Read whole CSI sequence
			--[[ from ECMA-048:
			The format of a control sequence is 'CSI P ... P I ... I F' where
			  - P ... P are parameter bytes, which, if present, consist of bit combinations from 03/00 to 03/15
			  - I ... I are intermediate bytes, which, if present, consist of bit combinations from 02/00 to 02/15
				Together with the Final Byte F they identify the control function
			  - F is the final byte; it consists of a bit combination from 04/00 to 07/14
			]]
			local parameters = {}
			local intermediate = {}
			local final
			c = getnext()
			while true do
				if c:match("[^\48-\63]") then
					break
				end
				table.insert(parameters, c)
				c = getnext()
			end
			while true do
				if c:match("[^\32-\47]") then
					break
				end
				table.insert(intermediate, c)
				c = getnext()
			end
			if c:match("[\64-\126]") then
				final = c
				emit("\27["..table.concat(parameters) .. table.concat(intermediate) .. final)
			else -- not valid CSI code... emit the whole thing character by character
				emit("\27")
				emit("[")
				for _, v in ipairs(parameters) do
					emit(v)
				end
				for _, v in ipairs(intermediate) do
					emit(v)
				end
				emit(c)
			end
		else
			emit(c)
		end
	end
end)

local function make_terminated_filter(prefix, terminator_pattern)
	return make_filter(function(getnext, emit)
		while true do
			local c = getnext()
			if c == prefix then
				local chars = {}
				while true do
					c = getnext()
					if c:match(terminator_pattern) then
						break
					end
					table.insert(chars, c)
				end
				emit(prefix..table.concat(chars)..c)
			else
				emit(c)
			end
		end
	end)
end

local filter_osc = make_terminated_filter("\27]", "[\7\156]") -- OSC can be terminated by ST or BEL
local filter_dcs = make_terminated_filter("\27P", "\156")
local filter_sos = make_terminated_filter("\27X", "\156")
local filter_pm = make_terminated_filter("\27^", "\156")
local filter_apc = make_terminated_filter("\27_", "\156")

local filter_mouse = make_filter(function(getnext, emit)
	while true do
		local c = getnext()
		if c == "\27[M" then
			-- The low two bits of C b encode button information: 0=MB1 pressed, 1=MB2 pressed, 2=MB3 pressed, 3=release.
			-- The next three bits encode the modifiers which were down when the button was pressed and are added together: 4=Shift, 8=Meta, 16=Control.
			-- On button-motion events, xterm adds 32 to the event code (the third character, C b )
			-- Wheel mice may return buttons 4 and 5. Those buttons are represented by the same event codes as buttons 1 and 2 respectively, except that 64 is added to the event code.
			local cb = getnext()
			-- C x and C y are the x and y coordinates of the mouse event, encoded as in X10 mode.
			local cx = getnext()
			local cy = getnext()
			emit("\27[M" .. cb .. cx .. cy)
		else
			emit(c)
		end
	end
end)

-- Filter that fixes linux virtual console bugs
local filter_linux = make_filter(function(getnext, emit)
	while true do
		local c = getnext()
		if c == "\27[" then -- bug in F1-F5 keys
			c = getnext()
			if c == "[" then
				c = getnext()
				if c == "A" or c == "B" or c == "C" or c == "D" or c == "E" then
					emit("\27[[" .. c)
				else
					emit("\27[")
					emit("[")
					emit(c)
				end
			else
				emit("\27[")
				emit(c)
			end
		elseif c == "\27]" then -- bug is an unterminated OSC: P n rr gg bb
			c = getnext()
			if c == "P" then
				local r1 = getnext()
				local r2 = getnext()
				local g1 = getnext()
				local g2 = getnext()
				local b1 = getnext()
				local b2 = getnext()
				emit("\27]P" .. r1 .. r2 .. g1 .. g2 .. b1 .. b2)
			else
				emit("\27]")
				emit(c)
			end
		else
			emit(c)
		end
	end
end)

local function default_chain(getnext, ...)
	-- Always filter ESC first
	getnext = filter_esc(getnext, ...)
	-- Should be after ESC but before CSI and OSC
	getnext = filter_linux(getnext, ...)
	-- These can be in any order
	getnext = filter_csi(getnext, ...)
	getnext = filter_osc(getnext, ...)
	getnext = filter_dcs(getnext, ...)
	getnext = filter_sos(getnext, ...)
	getnext = filter_pm(getnext, ...)
	getnext = filter_apc(getnext, ...)
	-- Always after CSI
	getnext = filter_mouse(getnext, ...)
	return getnext
end

return {
	make_filter = make_filter;

	ESC = filter_esc;
	linux = filter_linux;
	CSI = filter_csi;
	OSC = filter_osc;
	DCS = filter_dcs;
	SOS = filter_sos;
	PM = filter_pm;
	APC = filter_apc;
	MOUSE = filter_mouse;

	default_chain = default_chain;
}
