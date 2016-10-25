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

return {
	read_file = read_file;
}
