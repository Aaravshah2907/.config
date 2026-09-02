-- =============================================================================
-- Smart Splits & Navigation (Seamless Vim & Terminal Navigation)
-- =============================================================================

return {
	{
		"mrjones2014/smart-splits.nvim",
		event = "VeryLazy",
		config = function()
			local ss = require("smart-splits")
			ss.setup({
				at_edge = "wrap",
			})

			-- Keymaps for navigating splits seamlessly
			local map = vim.keymap.set
			map("n", "<C-h>", ss.move_cursor_left, { desc = "Move to left split/pane" })
			map("n", "<C-j>", ss.move_cursor_down, { desc = "Move to lower split/pane" })
			map("n", "<C-k>", ss.move_cursor_up, { desc = "Move to upper split/pane" })
			map("n", "<C-l>", ss.move_cursor_right, { desc = "Move to right split/pane" })
		end,
	},
}
