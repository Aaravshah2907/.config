return {
	entry = function(self, job)
		local folder = os.getenv("HOME") .. "/.local/bin"
		
		-- 1. Fetch .sh files
		local handle = io.popen('find "' .. folder .. '" -maxdepth 1 -type f -name "*.sh" 2>/dev/null')
		if not handle then 
			ya.notify({ title = "Run With", content = "Could not read " .. folder, level = "error", timeout = 5 })
			return 
		end
		
		local scripts = {}
		for line in handle:lines() do table.insert(scripts, line) end
		handle:close()

		if #scripts == 0 then
			return ya.notify({ title = "Run With", content = "No scripts found", level = "warn", timeout = 5 })
		end
		table.sort(scripts)

		-- 2. Build candidates for script selection
		local keys = "123456789abcdefghijklmnopqrstuvwxyz"
		local cands = {}
		for i, path in ipairs(scripts) do
			local filename = path:match("([^/]+)$")
			local key = keys:sub(i, i)
			if key ~= "" then table.insert(cands, { on = key, desc = filename }) end
		end

		local idx = ya.which({ cands = cands })
		if not idx then return end 
		local script_path = scripts[idx]
		local script_name = script_path:match("([^/]+)$")

		-- 3. Fetch Help flag output internally
		local h_handle = io.popen(script_path .. " -h 2>&1")
		local help_text = h_handle:read("*a")
		h_handle:close()
		
		if help_text == "" then help_text = "No help documentation found for this script." end

		-- 4. Display Help and confirm proceeding
		local confirmed = ya.confirm({
			pos = { "center", w = 60, h = 15 },
			title = "Help: " .. script_name,
			body = help_text .. "\n\nProceed to execution?",
		})
		if not confirmed then return end

		-- 5. Select Execution Mode
		local mode_idx = ya.which({
			cands = {
				{ on = "b", desc = "Batch (Execute once with all files)" },
				{ on = "i", desc = "Individual (Execute once per file)" },
				{ on = "c", desc = "Cancel" },
			}
		})

		-- 6. Execute based on selection
		if mode_idx == 1 then -- Batch
			local shell_cmd = string.format(
				'clear; printf "\\033[1;36m==> Executing Batch:\\033[0m %s\\n\\n"; "%s" "$@"; printf "\\n\\033[1;90mPress Enter to return to Yazi...\\033[0m"; read',
				script_name, script_path
			)
			ya.emit("shell", { shell_cmd, block = true })

		elseif mode_idx == 2 then -- Individual
			local shell_cmd = string.format(
				'clear; for f in "$@"; do printf "\\033[1;36m==> Individual Run:\\033[0m %s on \\033[1;33m$f\\033[0m\\n"; "%s" "$f"; printf "\\n"; done; printf "\\033[1;90mAll tasks complete. Press Enter to return to Yazi...\\033[0m"; read',
				script_name, script_path
			)
			ya.emit("shell", { shell_cmd, block = true })
		end
	end
}
