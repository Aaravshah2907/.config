-- =============================================================================
-- Trouble: A Beautiful Diagnostics Panel
-- =============================================================================
-- Like VS Code's "Problems" panel — shows all errors, warnings, TODOs
-- in one organized, filterable list.
--
--   Space+xx  → Toggle the Trouble panel
--   Space+xd  → Show diagnostics for current file only
--   Space+xw  → Show diagnostics across all open files
--   Space+xt  → Show all TODOs across the project
-- =============================================================================

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",

  config = function()
    require("trouble").setup({
      position = "bottom",
      height = 12,
      icons = true,
      use_diagnostic_signs = true,
    })

    local map = vim.keymap.set
    map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Toggle" })
    map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble: Buffer diagnostics" })
    map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Workspace diagnostics" })
    map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Trouble: TODOs" })
    map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble: Quickfix list" })
  end,
}
