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

		-- 2. Build candidates
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

		-- 3. Show Help in iTerm2 via Command API
		local help_cmd = script_path .. ' -h; echo ""; echo "Press Enter to return to Yazi..."; read'
		local osa_script = string.format([[
			tell application "iTerm"
				if (count windows) = 0 then
					create window with default profile
				end
				tell current window
					create tab with default profile
					tell current session
						write text "%s"
					end
				end
			end
		]], help_cmd:gsub('"', '\\"'))

		Command("osascript"):arg("-e"):arg(osa_script):spawn()

		-- 4. Ask for confirmation
		local confirmed = ya.confirm({
			pos = { "center", w = 50, h = 5 },
			title = "Run Script",
			body = "Execute " .. script_path:match("([^/]+)$") .. " on selection?",
		})

		-- 5. Execute, Echo, and Hold Screen
		if confirmed then
			-- We construct a shell pipeline to clear the screen, print the command in cyan, run it, and wait.
			-- Note: %%s is used so Lua formats it as %s for the shell's printf command.
			-- "$*" expands to all selected files separated by spaces.
			local shell_cmd = string.format(
				'clear; printf "\\033[1;36m==> Executing:\\033[0m %s %%s\\n\\n" "$*"; "%s" "$@"; printf "\\n\\033[1;90mPress Enter to return to Yazi...\\033[0m"; read',
				script_path, script_path
			)

			ya.emit("shell", {
				shell_cmd,
				block = true,
			})
		end
	end
}
