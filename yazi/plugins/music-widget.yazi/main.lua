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

	-- info format: [STATE] LOOP_ICON TITLE
	local state, loop, title = info:match("^%[(.-)%]%s+(.-)%s+(.*)$")
	if not state then 
		-- Try simplified match if first failed
		state, title = info:match("^%[(.-)%]%s+(.*)$")
		if not state then return ui.Span("   " .. info .. " "):fg("#7da4dd") end
		loop = "󰑗"
	end

	local loop_color = "#939ab7"
	if loop:match("󰑘") then loop_color = "#f5a97f" -- Single (Orange)
	elseif loop:match("󰑖") then loop_color = "#c6a0f6" -- All (Purple)
	end

	return ui.Line({
		ui.Span("   "):fg("#a6da95"),
		ui.Span("["):fg("#939ab7"),
		ui.Span(state):fg("#7da4dd"),
		ui.Span("] "):fg("#939ab7"),
		ui.Span(loop .. " "):fg(loop_color),
		ui.Span(title .. " "):fg("#cad3f5"),
	})
end, 1000, Header.RIGHT or 1)

return {}
