-- =============================================================================
-- LaTeX Configuration: VimTeX & LaTeX Completion Sources
-- =============================================================================

return {
	-- VimTeX: The premier Neovim plugin for LaTeX editing, compilation, and live preview.
	{
		"lervag/vimtex",
		lazy = false, -- Load immediately so filetype detection and keymaps work reliably
		init = function()
			-- Set default LaTeX viewer for macOS.
			-- Skim is recommended for sync (synctex); fallback to general viewer if not installed.
			vim.g.vimtex_view_method = "skim"

			-- Configure compiler method (latexmk is default)
			vim.g.vimtex_compiler_method = "latexmk"

			-- Quickfix window behavior
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_quickfix_open_on_warning = 0
		end,
	},

	-- LaTeX completion sources for nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"kdheepak/cmp-latex-symbols",
			"micangl/cmp-vimtex",
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			-- Add vimtex and latex_symbols sources
			table.insert(opts.sources, { name = "vimtex" })
			table.insert(opts.sources, {
				name = "latex_symbols",
				option = {
					strategy = 0, -- mixed mode
				},
			})
		end,
	},

	-- Inline math rendering for equations in LaTeX and Markdown
	{
		"jbyuki/nabla.nvim",
		ft = { "tex", "latex", "markdown" },
		keys = {
			{ "<leader>lp", function() require("nabla").popup() end, desc = "LaTeX: Preview equation popup" },
			{ "<leader>lv", function() require("nabla").toggle_virt() end, desc = "LaTeX: Toggle virtual math text" },
		},
	},
}
