require("mactag"):setup {
	-- Keys mapped to the 7 standard Finder color names
	keys = {
		i = "Important Documents", -- Red
		x = "Executables",         -- Orange
		b = "Books",               -- Yellow
		s = "Scripts",             -- Green
		t = "Travel",              -- Blue
		c = "Cosmere",             -- Purple
		m = "Temporary",           -- Gray
		r = "Receipts",            -- Mapping to Green (Money)
	},
	
	-- Official macOS Finder Tag Hex Colors
	colors = {
		["Important Documents"] = "#ee7b70", -- Red
		["Executables"]         = "#f5bd5c", -- Orange
		["Books"]               = "#fbe764", -- Yellow
		["Scripts"]             = "#91fc87", -- Green
		["Travel"]              = "#5fa3f8", -- Blue
		["Cosmere"]             = "#cb88f8", -- Purple
		["Temporary"]           = "#9ca3af", -- Gray
		["Receipts"]            = "#91fc87", -- Green (Same as Scripts)
	},
	
	order = 500,
}
