return {
	entry = function(_, args)
		local arg1 = args and args[1] or nil

		if arg1 == "quote" then
			local quotes = {
				"Journey before destination.",
				"Life before death.",
				"Strength before weakness.",
				"I will protect those who cannot protect themselves.",
				"I will protect even those I hate, so long as it is right.",
				"I will take responsibility for what I have done.",
				"I will seek freedom for those who are in bondage.",
				"I will remember those who have been forgotten.",
				"I will listen to those who have been ignored.",
				"The sky is ours!",
				"You are not alone."
			}
			
			math.randomseed(os.time())
			local quote = quotes[math.random(#quotes)]
			
			ya.notify {
				title = "󰌵 Sylphrena",
				content = quote,
				timeout = 3,
				level = "info",
			}
			return
		elseif arg1 == "custom" then
			local title = args[2] or "󰌵 Sylphrena"
			local content = args[3] or ""
			ya.notify {
				title = title,
				content = content,
				timeout = 2,
				level = "info",
			}
			return
		end

		-- Default behavior: read from JSON bridge
		local bridge_file = os.getenv("HOME") .. "/.config/radiant-player/notify.json"
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
		
		local title = data.title or "󰌵 Sylphrena"
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
