describe("tparm", function()
	local tparm = require "tui.tparm".tparm
	it("empty string", function()
		assert.same("", tparm(""))
	end)
	it("normal string with no specifiers", function()
		assert.same("\27foo\n", tparm("\27foo\n"))
	end)
	it("%%", function()
		assert.same("foo%bar", tparm("foo%%bar"))
	end)
	it("simple push + printf", function()
		assert.same("\27[1A", tparm("\27[%p1%dA", 1))
	end)
	it("if/then/elseif/else", function()
		local str = "%?%p1%{7}%>%t\27[48;5;%p1%dm%e\27[4%?%p1%{1}%=%t4%e%p1%{3}%=%t6%e%p1%{4}%=%t1%e%p1%{6}%=%t3%e%p1%d%;m%;"
		--[[
		%?%p1%{7}%>%t
			\27[48;5;%p1%dm
		%e
			\27[4
			%?%p1%{1}%=%t
				4
			%e%p1%{3}%=%t
				6
			%e%p1%{4}%=%t
				1
			%e%p1%{6}%=%t
				3
			%e
				%p1%d
			%;
			m
		%;
		]]
		assert.same("\27[40m", tparm(str, 0))
		assert.same("\27[44m", tparm(str, 1))
		assert.same("\27[42m", tparm(str, 2))
		assert.same("\27[46m", tparm(str, 3))
		assert.same("\27[41m", tparm(str, 4))
		assert.same("\27[45m", tparm(str, 5))
		assert.same("\27[43m", tparm(str, 6))
		assert.same("\27[47m", tparm(str, 7))
		assert.same("\27[48;5;8m", tparm(str, 8))
		assert.same("\27[48;5;9m", tparm(str, 9))
	end)
end)
