-- ====================================================================
-- MUSIC WIDGET PLUGIN (ZERO-CACHE INSTANT RENDER)
-- ====================================================================

local music_info = ""

-- DATA FETCH (Always fetch fresh on render for absolute accuracy)
local get_music_info = function()
	local cmd = "/opt/homebrew/bin/python3 " .. os.getenv("HOME") .. "/.config/yazi/scripts/music_queue.py short_status 2>/dev/null"
	local handle = io.popen(cmd)
	if handle then
		music_info = handle:read("*a"):gsub("\n$", "")
		handle:close()
	else
		music_info = ""
	end
	return music_info
end

Header:children_add(function()
	local info = get_music_info()
	if info == "" then return ui.Span("") end
	return ui.Span("   " .. info .. " "):fg("#7da4dd")
end, 1000, Header.RIGHT or 1)

return {}
