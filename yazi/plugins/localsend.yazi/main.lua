--- @since 25.5.28

local get_paths = ya.sync(function(_)
	local paths = {}
	for _, url in pairs(cx.active.selected) do
		paths[#paths + 1] = tostring(url)
	end
	if #paths == 0 then
		local hovered = cx.active.current.hovered
		if hovered then paths[1] = tostring(hovered.url) end
	end
	return paths
end)

local function fail(s, ...)
	ya.notify { title = "LocalSend", content = string.format(s, ...), level = "error", timeout = 5 }
end

return {
	entry = function(_, _)
		local paths = get_paths()
		if #paths == 0 then
			return fail("No files selected")
		end

		local send_path, tmpdir
		if #paths == 1 then
			send_path = paths[1]
		else
			local tmp, err = Command("mktemp"):arg({ "-d", "/tmp/localsend.XXXXXX" }):output()
			if not tmp then return fail("Failed to create temp directory: %s", err) end
			tmpdir = tmp.stdout:gsub("%s+$", "")

			local cp_args = { "-r" }
			for _, p in ipairs(paths) do cp_args[#cp_args + 1] = p end
			cp_args[#cp_args + 1] = tmpdir .. "/"
			local st = Command("cp"):arg(cp_args):status()
			if not st or not st.success then
				Command("rm"):arg({ "-rf", tmpdir }):status()
				return fail("Failed to copy files to temp directory")
			end
			send_path = tmpdir
		end

		local permit = ui.hide()
		local child, err = Command("localsend-go"):arg({ "send", send_path })
			:stdin(Command.INHERIT)
			:stdout(Command.INHERIT)
			:stderr(Command.INHERIT)
			:spawn()
		if child then
			child:wait()
		end
		permit:drop()

		if tmpdir then
			Command("rm"):arg({ "-rf", tmpdir }):status()
		end

		if not child then
			fail("Failed to start localsend-go: %s", err)
		end
	end,
}
