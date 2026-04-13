return {
	entry = function(_, job)
		-- Absolute path to the notification bridge file
		local bridge_file = os.getenv("HOME") .. "/.config/yazi/scripts/music_notify.json"
		
		local f = io.open(bridge_file, "r")
		if not f then return end
		local raw_data = f:read("*all")
		f:close()

		-- Safe JSON decode
		local ok, data = pcall(ya.json_decode, raw_data)
		if not ok then
			ya.notify { title = "Syl-Notify Error", content = "Mangled bridge file", level = "error" }
			return
		end
		if not ok then
			ya.notify { title = "Syl-Notify Error", content = "Invalid JSON payload", level = "error" }
			return
		end
		
		local title = data.title or "Sylphrena"
		local content = data.content or "Journey before destination."
		
		-- Expand literal \n just in case JQ didn't handle it for the terminal display
		content = content:gsub("\\n", "\n")
		
		ya.notify {
			title = title,
			content = content,
			level = data.level or "info",
			timeout = tonumber(data.timeout) or 5,
		}
	end,
}
