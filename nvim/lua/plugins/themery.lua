return {
	"zaldih/themery.nvim",
	lazy = false,
	config = function()
		require("themery").setup({
			themes = {
				{
					name = "Cosmere",
					colorscheme = "catppuccin-mocha",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Catppuccin Latte",
					colorscheme = "catppuccin-latte",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Tokyo Night",
					colorscheme = "tokyonight-night",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Tokyo Day",
					colorscheme = "tokyonight-day",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Gruvbox Dark",
					colorscheme = "gruvbox",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Gruvbox Light",
					colorscheme = "gruvbox",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Kanagawa Dragon",
					colorscheme = "kanagawa-dragon",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Kanagawa Lotus",
					colorscheme = "kanagawa-lotus",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Rose Pine Moon",
					colorscheme = "rose-pine-moon",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Rose Pine Dawn",
					colorscheme = "rose-pine-dawn",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Roshar Highstorm",
					colorscheme = "duskfox",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Scadrial Ashfall",
					colorscheme = "carbonfox",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Taldain Dayside",
					colorscheme = "dayfox",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Shadesmar",
					colorscheme = "terafox",
					before = [[
						vim.opt.background = "dark"
					]],
				},
				{
					name = "Elantris Glow",
					colorscheme = "dawnfox",
					before = [[
						vim.opt.background = "light"
					]],
				},
				{
					name = "Nalthis BioChromatic",
					colorscheme = "material",
					before = [[
						vim.opt.background = "dark"
						vim.g.material_style = "deep ocean"
					]],
				},
				{
					name = "Selish Dor",
					colorscheme = "everforest",
					before = [[
						vim.opt.background = "dark"
						vim.g.everforest_background = "hard"
					]],
				},
				{
					name = "Silverlight",
					colorscheme = "onelight",
					before = [[
						vim.opt.background = "light"
					]],
				},
			},
			livePreview = true,
		})
	end,
}
