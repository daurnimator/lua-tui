local tui_filters = require "tui.filters"

local function fd_to_getter(fd, filter)
	local readahead = ""
	local function peek(char)
		local need_more = char - #readahead
		if need_more > 0 then
			local data, err, errno = fd:read(need_more)
			if not data then
				return nil, err, errno
			end
			readahead = readahead .. data
		end
		return readahead:sub(char, char)
	end
	return function()
		local n = filter(peek) or 1
		local need_more = n - #readahead
		if need_more > 0 then
			local data, err, errno = io.stdin:read(need_more)
			if not data then
				return nil, err, errno
			end
			readahead = readahead .. data
		end
		local r = readahead:sub(1, n)
		readahead = readahead:sub(n+1)
		return r
	end
end

local default_getnext = fd_to_getter(io.stdin, tui_filters.default_chain)

return {
	getnext = default_getnext;
}
