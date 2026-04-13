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
		return ui.Span(" 󱇊 " .. info .. " "):fg("#00BFFF")
	end

	local state_icon = "󱇊" -- Resting (Diamond)
	local state_color = "#939ab7" -- Slate
	if state == "LASHING" then
		state_icon = "󱐌" -- Lashing (Lightning)
		state_color = "#00BFFF" -- Sapphire
	end

	local loop_color = "#939ab7"
	if loop:match("󰑘") then loop_color = "#f5a97f" -- Single (Orange)
	elseif loop:match("󰑖") then loop_color = "#c6a0f6" -- All (Purple)
	end

	return ui.Line({
		ui.Span(" " .. state_icon .. " "):fg(state_color),
		ui.Span("["):fg("#939ab7"),
		ui.Span(state):fg(state_color),
		ui.Span("] "):fg("#939ab7"),
		ui.Span(loop .. " "):fg(loop_color),
		ui.Span(title .. " "):fg("#FFD700"), -- Honor's Gold
	})
end, 1000, Header.RIGHT or 1)

return {}
