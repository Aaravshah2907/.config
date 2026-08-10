--- @since 25.5.28

local get_selected = ya.sync(function()
	local paths = {}
	for _, url in pairs(cx.active.selected) do
		paths[#paths + 1] = tostring(url)
	end
	return paths
end)

local function fail(s, ...)
	ya.notify { title = "LocalSend", content = string.format(s, ...), level = "error", timeout = 5 }
end

return {
	entry = function()
		local paths = get_selected()

		if #paths == 0 then
			-- No selection → Receive mode
			local permit = ui.hide()
			local child, err = Command("bash")
				:arg({ os.getenv("HOME") .. "/.local/bin/localsend-dashboard.sh", "receive" })
				:stdin(Command.INHERIT)
				:stdout(Command.INHERIT)
				:stderr(Command.INHERIT)
				:spawn()
			if child then
				child:wait()
			end
			permit:drop()
			if not child then
				fail("Failed to start receive mode: %s", err)
			end
		else
			-- Has selection → Send mode
			-- Write paths to temp file to avoid quoting issues
			local tmp = "/tmp/yazi-localsend-files.txt"
			local f = io.open(tmp, "w")
			for _, p in ipairs(paths) do
				f:write(p .. "\n")
			end
			f:close()

			local permit = ui.hide()
			local child, err = Command("bash")
				:arg({ os.getenv("HOME") .. "/.local/bin/localsend-dashboard.sh", "send" })
				:stdin(Command.INHERIT)
				:stdout(Command.INHERIT)
				:stderr(Command.INHERIT)
				:spawn()
			if child then
				child:wait()
			end
			permit:drop()

			if not child then
				fail("Failed to start send mode: %s", err)
			end
		end
	end,
}
