-- =============================================================================
-- UI Plugins
-- =============================================================================
-- This file bundles all the visual/UI enhancement plugins together.
-- In lazy.nvim, returning a list of tables means each entry is a separate plugin.
-- =============================================================================

return {

	-- ---------------------------------------------------------------------------
	-- Lualine: Statusline at the bottom of the screen
	-- ---------------------------------------------------------------------------
	-- Think of it like the status bar in other editors — shows file name, git
	-- branch, errors, your position in the file, etc.
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy", -- Load after startup for speed

		config = function()
			require("lualine").setup({
				options = {
					theme = "auto", -- Match our colorscheme
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
				},
				-- Sections control what appears in each part of the statusline:
				--   a | b | c              x | y | z
				--  (left side)           (right side)
				sections = {
					lualine_a = { "mode" }, -- Current mode (NORMAL, INSERT, etc.)
					lualine_b = { "branch", "diff", "diagnostics" }, -- Git info + errors
					lualine_c = { "filename" }, -- Current file name
					lualine_x = { "filetype" }, -- File type (lua, python, etc.)
					lualine_y = { "progress" }, -- How far through the file (%)
					lualine_z = { "location" }, -- Line:Column number
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Bufferline: Tabs at the top of the screen
	-- ---------------------------------------------------------------------------
	-- Each open file gets a "tab" at the top, like browser tabs.
	-- Makes it easy to switch between open files.
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",

		config = function()
			require("bufferline").setup({
				options = {
					diagnostics = "nvim_lsp", -- Show error/warning counts on tabs
					-- (Using default bufferline highlights which pick up our colorscheme)
					separator_style = "slant", -- Angled tab separators
					show_buffer_close_icons = true,
					show_close_icon = false,
					always_show_bufferline = true, -- Show even with one file open
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Indent Blankline: Subtle vertical indent guides
	-- ---------------------------------------------------------------------------
	-- Draws thin vertical lines at each indentation level so you can see
	-- which code belongs to which block (like matching braces visually).
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl", -- The module name is "ibl", not "indent_blankline"
		event = { "BufReadPost", "BufNewFile" }, -- Load when opening a file

		config = function()
			require("ibl").setup({
				indent = {
					char = "│", -- The character used for indent lines
				},
				scope = {
					enabled = true, -- Highlight the current scope's indent line
					show_start = false, -- Don't underline the scope start
					show_end = false, -- Don't underline the scope end
				},
				exclude = {
					filetypes = { "help", "alpha", "dashboard", "lazy", "mason" },
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Web Devicons: File type icons
	-- ---------------------------------------------------------------------------
	-- Adds little icons next to file names (e.g., a JS icon for .js files).
	-- Many other plugins depend on this for their icons.
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true, -- Loaded when other plugins need it
	},

	-- ---------------------------------------------------------------------------
	-- Alpha: Dashboard / Start screen
	-- ---------------------------------------------------------------------------
	-- The screen you see when you open Neovim without a file.
	-- Shows a cool ASCII art header and quick-access buttons.
	{
		"goolord/alpha-nvim",
		enabled = false, -- Disabled in favor of snacks.nvim dashboard for ANSI color support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter", -- Show on startup

		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- ASCII art header
			dashboard.section.header.val = {
				[[                                                                     ]],
				[[       ████ ██████           █████      ██                     ]],
				[[      ███████████             █████                             ]],
				[[      █████████ ███████████████████ ███   ███████████   ]],
				[[     █████████  ███    █████████████ █████ ██████████████   ]],
				[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
				[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
				[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
				[[                                                                       ]],
			}

			-- Cosmere Stormlight Gradient (Deep Sapphire to Light Radiant Blue)
			local gradient = {
				"#001f3f", -- Deep dark sea
				"#003366",
				"#004080",
				"#0059b3", -- Windrunner blue
				"#0073e6",
				"#008cff",
				"#33a6ff",
				"#66c0ff",
				"#99d9ff", -- Radiant light
			}

			-- Create highlight groups and assign them to each line of the header
			local hl_table = {}
			for i, color in ipairs(gradient) do
				local hl_group = "AlphaHeaderGradient" .. i
				vim.api.nvim_set_hl(0, hl_group, { fg = color, bold = true })
				table.insert(hl_table, { { hl_group, 0, 200 } })
			end
			dashboard.section.header.opts.hl = hl_table

			vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#FFD700" }) -- Gold for buttons
			vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#50fa7b", bold = true })
			vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#C3AEE8", italic = true }) -- Elsecaller Purple

			-- Quick-access buttons
			dashboard.section.buttons.val = {
				dashboard.button("n", "  New File", ":ene <BAR> startinsert <CR>"),
				dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
				dashboard.button("r", "  Recent Files", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "  Find Word", ":Telescope live_grep <CR>"),
				dashboard.button("e", "  Open Yazi", ":Yazi <CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}

			-- Footer
			dashboard.section.footer.val =
				"Life before death. Strength before weakness. Journey before destination. ⚔️"
			dashboard.section.footer.opts.hl = "AlphaFooter"

			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end

			-- Apply padding between sections
			dashboard.config.layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = 1 },
				dashboard.section.footer,
			}

			alpha.setup(dashboard.config)

			-- Don't show the statusline on the dashboard
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "alpha",
				callback = function()
					vim.opt_local.laststatus = 0
				end,
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Which-key: Keymap popup menu
	-- ---------------------------------------------------------------------------
	-- Displays a popup with possible keybindings of the command you started typing
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			window = {
				border = "single", -- Cosmere themed sharp borders
			},
			spec = {
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
				{ "<leader>g", group = "Git" },
				{ "<leader>s", group = "Search/Sort" },
				{ "<leader>f", group = "Find/File" },
				{ "<leader>t", group = "Toggle/Terminal" },
			},
		},
		keys = {
			{
				"<leader>wk",
				function()
					require("which-key").show()
				end,
				desc = "Show All Keymaps (Which-Key)",
			},
		},
	},

	-- ---------------------------------------------------------------------------
	-- mini.animate: Smooth scrolling and window transitions
	-- ---------------------------------------------------------------------------
	{
		"echasnovski/mini.animate",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.animate").setup({
				cursor = { enable = false }, -- disable cursor animation as it can feel laggy
				scroll = { enable = true },  -- smooth scrolling
				window = { enable = true },  -- window opening/closing animations
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- todo-comments.nvim: Highlight TODOs, FIXMEs, etc.
	-- ---------------------------------------------------------------------------
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#C3AEE8" }, -- Elsecaller Purple for default
				test = { "Identifier", "#FF00FF" }
			},
		},
	},

	-- ---------------------------------------------------------------------------
	-- Noice: Better UI for messages, cmdline, and popups
	-- ---------------------------------------------------------------------------
	-- Replaces the default command line at the bottom with a centered popup,
	-- shows search results count, and makes notifications prettier.
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim", -- UI components library
			"rcarriga/nvim-notify", -- Pretty notification popups
		},

		config = function()
			require("noice").setup({
				lsp = {
					-- Use Noice for LSP hover/signature instead of defaults
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = true, -- Classic search at bottom
					command_palette = true, -- Centered command popup
					long_message_to_split = true, -- Long messages go to a split
					inc_rename = false, -- Don't use for rename
					lsp_doc_border = true, -- Add border to LSP hover docs
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Dressing: Better vim.ui.select and vim.ui.input
	-- ---------------------------------------------------------------------------
	-- When Neovim asks you to pick something from a list or type input,
	-- this makes those popups look much nicer.
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {}, -- Use defaults — they're already great
	},

	-- ---------------------------------------------------------------------------
	-- Snacks.nvim: Quality of life and Dashboard (replaces Alpha)
	-- ---------------------------------------------------------------------------
	-- Using Snacks dashboard because it natively supports running terminal
	-- commands (like ascii-image-converter) to render 24-bit ANSI colors!
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = {
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
				preset = {
					header = [[
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
					keys = {
						{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
						{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
						{ icon = " ", key = "c", desc = "Config", action = ":lua require('yazi').yazi({}, vim.fn.stdpath('config'))" },
						{ icon = " ", key = "e", desc = "Open Yazi", action = ":Yazi" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},
			-- You can enable other snacks features here if you'd like
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			terminal = { enabled = true },
			lazygit = { enabled = true },
			gitbrowse = { enabled = true },
			words = { enabled = true },
			zen = { enabled = true },
			dim = { enabled = true },
			scratch = { enabled = true },
			rename = { enabled = true },
			bufdelete = { enabled = true },
		},
		keys = {
			-- Snacks specific keymaps
			{ "<leader>t", function() Snacks.terminal() end, desc = "[T]oggle Terminal" },
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "[G]it [G]ui (Lazygit)" },
			{ "<leader>gb", function() Snacks.gitbrowse() end, desc = "[G]it [B]rowse" },
			{ "<leader>z", function() Snacks.zen() end, desc = "[Z]en Mode" },
			{ "<leader>d", function() Snacks.dim() end, desc = "[D]im Mode" },
			{ "<leader>.", function() Snacks.scratch() end, desc = "[.] Scratch Buffer" },
			{ "<leader>bd", function() Snacks.bufdelete() end, desc = "[B]uffer [D]elete" },
			{ "<leader>rn", function() Snacks.rename.rename_file() end, desc = "[R]e[N]ame File" },
		},
	},
}
