local tui_terminfo = require "tui.terminfo"

local default_terminfo = tui_terminfo.find()

local function read_file(path)
	local fd, err, errno = io.open(fd, "rb")
	if not fd then
		return nil, err, errno
	end
	local contents, err2, errno2 = fd:read("*a")
	fd:close()
	if not contents then
		return nil, err2, errno2
	end
	return contents
end

local function init(fd, terminfo)
	if fd == nil then
		fd = io.stdout
	end
	if terminfo == nil then
		terminfo = default_terminfo
	end
	local str = {
		terminfo.init_prog or "";
		terminfo.init_1string or "";
		terminfo.init_2string or "";
		terminfo.clear_margins or "";
		terminfo.set_left_margin or "";
		terminfo.set_right_margin or "";
		terminfo.clear_all_tabs or "";
		terminfo.set_tab or "";
		"";
		terminfo.init_3string or "";
	}
	local file = terminfo.init_file
	if file then
		str[9] = read_file(file) or ""
	end
	return fd:write(table.concat(str))
end

local function reset(fd, terminfo)
	if fd == nil then
		fd = io.stdout
	end
	if terminfo == nil then
		terminfo = default_terminfo
	end
	local str = {
		terminfo.init_prog or "";
		terminfo.reset_1string or terminfo.init_1string or "";
		terminfo.reset_2string or terminfo.init_2string or "";
		terminfo.clear_margins or "";
		terminfo.set_left_margin or "";
		terminfo.set_right_margin or "";
		terminfo.clear_all_tabs or "";
		terminfo.set_tab or "";
		"";
		terminfo.reset_3string or terminfo.init_3string or "";
	}
	local file = terminfo.reset_file or terminfo.init_file
	if file then
		str[9] = read_file(file) or ""
	end
	return fd:write(table.concat(str))
end

return {
	init = init;
	reset = reset;
}
