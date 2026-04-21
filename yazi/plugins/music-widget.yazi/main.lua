-- ====================================================================
-- MUSIC WIDGET PLUGIN (ZERO-CACHE INSTANT RENDER)
-- ====================================================================

local music_info = ""
local last_fetch_s = 0
local FETCH_INTERVAL_S = 2
local FORCE_REFRESH_S = 6
local TICK_FILE = "/tmp/radiant-music-update.tick"
local last_tick = ""

local read_tick = function()
	local handle = io.open(TICK_FILE, "r")
	if not handle then return "" end
	local content = handle:read("*a") or ""
	handle:close()
	return content:gsub("%s+$", "")
end

-- DATA FETCH (Always fetch fresh on render for absolute accuracy)
local get_music_info = function()
	local now_s = os.time()
	local tick = read_tick()
	local tick_changed = tick ~= "" and tick ~= last_tick
	if not tick_changed and (now_s - last_fetch_s) < FETCH_INTERVAL_S then
		return music_info
	end
	if not tick_changed and (now_s - last_fetch_s) < FORCE_REFRESH_S and music_info ~= "" then
		return music_info
	end

	last_tick = tick
	last_fetch_s = now_s

	local cmd = "/opt/homebrew/bin/python3 " .. os.getenv("HOME") .. "/.config/yazi/scripts/music_queue.py short_status_fast 2>/dev/null"
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

	-- info format: [STATE] LOOP_ICON SOURCE_ICON TITLE
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

	local source_color = "#FFD700"
	if title:match("^") then
		source_color = "#9ece6a"
	elseif title:match("^󰎈") then
		source_color = "#7aa2f7"
	end

	return ui.Line({
		ui.Span(" " .. state_icon .. " "):fg(state_color),
		ui.Span("["):fg("#939ab7"),
		ui.Span(state):fg(state_color),
		ui.Span("] "):fg("#939ab7"),
		ui.Span(loop .. " "):fg(loop_color),
		ui.Span(title .. " "):fg(source_color),
	})
end, 1000, Header.RIGHT or 1)

return {}
