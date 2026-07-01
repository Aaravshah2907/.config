-- =============================================================================
-- Zen Mode: Distraction-Free Coding
-- =============================================================================
-- Centers your code and dims everything else — perfect for deep focus.
--
--   Space+z  → Toggle Zen Mode
-- =============================================================================

return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup({
        window = {
          backdrop = 0.93,
          width = 100,
          height = 1,
          options = {
            signcolumn = "no",
            number = false,
            relativenumber = false,
            cursorline = false,
            foldcolumn = "0",
          },
        },
        plugins = {
          twilight = { enabled = true },
          gitsigns = { enabled = false },
        },
      })

      vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })
    end,
  },
  -- Twilight: dims inactive code blocks (companion to Zen Mode)
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    config = function()
      require("twilight").setup({
        dimming = { alpha = 0.25 },
        context = 10,
        treesitter = true,
      })
    end,
  },
}
