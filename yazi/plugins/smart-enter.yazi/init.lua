return {
	entry = function()
		local h = cx.active.current.hovered
		if h and h.cha.is_dir then
			ya.manager_emit("enter", { hovered = true })
		else
			-- When running inside yazi.nvim (detected via YAZI_NVIM_ID env var),
			-- use `quit` so yazi writes the file to --chooser-file and yazi.nvim
			-- opens it in the parent nvim. Using `open` here would spawn a nested
			-- nvim process via the edit opener instead.
			local inside_nvim = os.getenv("YAZI_NVIM_ID") ~= nil

			if inside_nvim then
				ya.manager_emit("quit", {})
			else
				-- Standalone yazi: show Sylphrena notification and open normally
				if h then
					local ext = h.name:match("^.+%.(.+)$")
					local msg = "Opening " .. h.name
					if ext then
						ext = ext:lower()
						if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or ext == "webp" then
							msg = "A frozen memory... viewing " .. h.name
						elseif ext == "mp4" or ext == "mkv" or ext == "avi" or ext == "mov" then
							msg = "Lightweavers' illusions! Playing " .. h.name
						elseif ext == "mp3" or ext == "flac" or ext == "wav" or ext == "m4a" or ext == "m4b" then
							msg = "I can hear the pure tones of Roshar in " .. h.name
						elseif ext == "rs" or ext == "py" or ext == "sh" or ext == "js" or ext == "lua" then
							msg = "Spells and logic! You're weaving patterns in " .. h.name
						end
					end
					ya.manager_emit("plugin", { "syl-notify", args = ya.quote("custom") .. " " .. ya.quote("󰌵 Sylphrena") .. " " .. ya.quote(msg) })
				end
				ya.manager_emit("open", { hovered = true })
			end
		end
	end,
}