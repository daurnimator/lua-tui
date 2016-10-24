local tui_filters = require "tui.filters"

local default_getnext = tui_filters.default_chain(function()
	return io.stdin:read(1)
end)

return {
	getnext = default_getnext;
}
