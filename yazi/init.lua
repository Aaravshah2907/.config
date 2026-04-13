require("music-widget")

require("simple-tag"):setup({
  -- UI display mode (icon, text, hidden)
  ui_mode = "icon", -- (Optional)

  -- Disable tag key hints (popup in bottom right corner)
  hints_disabled = false, -- (Optional)

  -- linemode order: adjusts icon/text position. For example, if you want icon to be on the most left of linemode then set linemode_order larger than 1000.
  -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-plugin/preset/components/linemode.lua#L4-L5
  linemode_order = 500, -- (Optional)

  -- You can backup/restore this folder within the same OS (Linux, windows, or MacOS).
  -- But you can't restore backed up folder in the different OS because they use difference absolute path.
  -- save_path =  -- full path to save tags folder (Optional)
  --       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/tags"
  --       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\tags"

  -- Set tag colors
  colors = { -- (Optional)
	  -- Set this same value with `theme.toml` > [mgr] > hovered > reversed
	  -- Default theme use "reversed = true".
	  -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-config/preset/theme-dark.toml#L25
	  -- Only need to set this if you use shipped/stable yazi <= v25.5.31 or nightly yazi installed before 11/12/2025
	  reversed = true, -- (Optional)

	  -- More colors: https://yazi-rs.github.io/docs/configuration/theme#types.color
    -- format: [tag key] = "color"
	  ["x"] = "#595f61", -- Scripts
	  ["c"] = "#000000", -- Config
	  ["!"] = "#cc9057", -- Pin
	  -- ["1"] = "cyan",
	  ["p"] = "red", -- Protected
	  ["i"] = "#595f61", -- Images
	  ["I"] = "red", -- Important
	  ["B"] = "yellow", -- Books
	  ["T"] = "blue", -- Travel
	  ["C"] = "lightblue", -- Cosmere?
	  ["₹"] = "green", -- Financial
	  ["?"] = "#2a8030", -- Doubtful
	  ["m"] = "#4981d0", --Music
	  ["v"] = "#7da4dd", -- Video
  },

  -- Set tag icons. Only show when ui_mode = "icon".
  -- Any text or nerdfont icons should work as long as you use nerdfont to render yazi.
  -- Default icon from mactag.yazi: ●; Some generic icons: , , 󱈤
  -- More icon from nerd fonts: https://www.nerdfonts.com/cheat-sheet
  icons = { -- (Optional)
    -- default icon
    default = "󰚋",

    -- format: [tag key] = "tag icon"
		["x"] = "",
		["i"] = "",
		["c"] = "",
		["!"] = "",
		["p"] = "",
		["I"] = "󰇈", 
		["B"] = "",
		["T"] = "",
		["C"] = "",
		["₹"] = "󰆯",
		["?"] = "󱍋",
		["m"] = "󰽴",
		["v"] = "󰎁",
  },
})

require('spot'):setup {
  metadata_section = {
    enable = true,
    hash_cmd = 'xxhsum', -- other hashing commands may be slower
    hash_filesize_limit = 150, -- in MB, set 0 to disable
    relative_time = true, -- 2026-01-01 or n days ago
    time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
    show_compression = 'size', ---@type false|"size"|"percentage"
  },
  plugins_section = {
    enable = true,
  },
  style = {
    section = 'green',
    key = 'reset',
    value = 'blue',
    selected = 'blue',
    colorize_metadata = true,
    height = 20,
    width = 60,
    key_length = 15,
  },
}
