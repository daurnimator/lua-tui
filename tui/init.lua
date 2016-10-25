local tui_filters = require "tui.filters"

local function fd_to_getter(fd, filter)
	local readahead = ""
	local function fill(chars)
		local need_more = chars - #readahead
		if need_more > 0 then
			local data, err, errno = fd:read(need_more)
			if not data then
				return nil, err, errno
			end
			readahead = readahead .. data
		end
		return true
	end
	local function peek(char)
		local ok, err, errno = fill(char)
		if not ok then
			return nil, err, errno
		end
		return readahead:sub(char, char)
	end
	local function take(chars)
		local ok, err, errno = fill(chars)
		if not ok then
			return nil, err, errno
		end
		local r = readahead:sub(1, chars)
		readahead = readahead:sub(chars+1)
		return r
	end
	return function()
		return take(filter(peek) or 1)
	end
end

local default_getnext = fd_to_getter(io.stdin, tui_filters.default_chain)

return {
	getnext = default_getnext;
}
