-- ====================================================================
-- MUSIC WIDGET PLUGIN (REVERTING TO STABLE WORKING VERSION)
-- ====================================================================

local music_info = ""
local last_music_update = 0

local get_music_info = function()
	local now = os.time()
	if now - last_music_update >= 1 then
		local cmd = "/opt/homebrew/bin/python3 " .. os.getenv("HOME") .. "/.config/yazi/scripts/music_queue.py short_status 2>/dev/null"
		local handle = io.popen(cmd)
		if handle then
			music_info = handle:read("*a"):gsub("\n$", "")
			handle:close()
		else
			music_info = ""
		end
		last_music_update = now
	end
	return music_info
end

Header:children_add(function()
	local info = get_music_info()
	if info == "" then return ui.Span("") end
	return ui.Span("   " .. info .. " "):fg("#7da4dd")
end, 1000, Header.RIGHT or 1) -- Use RIGHT or fallback to 1

return {}
