local tui_terminfo = require "tui.terminfo"

local default_terminfo = tui_terminfo.find()

local function init(fd, terminfo)
	if fd == nil then
		fd = io.stdout
	end
	if terminfo == nil then
		terminfo = default_terminfo
	end
	return fd:write(
		terminfo.init_prog or "",
		terminfo.init_1string or "",
		terminfo.init_2string or "",
		terminfo.clear_margins or "",
		terminfo.set_left_margin or "",
		terminfo.set_right_margin or "",
		terminfo.clear_all_tabs or "",
		terminfo.set_tab or "",
		terminfo.init_file or "",
		terminfo.init_3string or "")
end

local function reset(fd, terminfo)
	if fd == nil then
		fd = io.stdout
	end
	if terminfo == nil then
		terminfo = default_terminfo
	end
	return fd:write(
		terminfo.init_prog or "",
		terminfo.reset_1string or terminfo.init_1string or "",
		terminfo.reset_2string or terminfo.init_2string or "",
		terminfo.clear_margins or "",
		terminfo.set_left_margin or "",
		terminfo.set_right_margin or "",
		terminfo.clear_all_tabs or "",
		terminfo.set_tab or "",
		terminfo.reset_file or terminfo.init_file or "",
		terminfo.reset_3string or terminfo.init_3string or "")
end

return {
	init = init;
	reset = reset;
}
