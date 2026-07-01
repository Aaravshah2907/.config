-- =============================================================================
-- Diffview: Side-by-Side Git Diffs & File History
-- =============================================================================
-- A full git diff viewer and file history browser, all inside Neovim.
--
--   Space+gd  → Open diff view (all changed files)
--   Space+gh  → File history (current file)
--   Space+gH  → Full repo history
--   Space+gc  → Close diff view
-- =============================================================================

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },

  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    })

    local map = vim.keymap.set
    map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git: Diff view" })
    map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git: File history" })
    map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git: Repo history" })
    map("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Git: Close diff view" })
  end,
}
