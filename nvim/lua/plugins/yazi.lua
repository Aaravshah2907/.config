-- =============================================================================
-- Yazi: Terminal File Manager Inside Neovim
-- =============================================================================
-- Yazi is a blazing-fast terminal file manager. This plugin lets you
-- open it directly inside Neovim to browse, preview, and open files.
--
-- Keymaps:
--   Space+e → Open Yazi at the current file's location
--   Space+E → Open Yazi at the project root (cwd)
--
-- When you select a file in Yazi, it opens in Neovim automatically.
-- =============================================================================

return {
  "mikavilpas/yazi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",

  keys = {
    -- Open Yazi, focused on the file you're currently editing
    {
      "<leader>e",
      "<cmd>Yazi<cr>",
      desc = "Open Yazi (current file)",
    },
    -- Open Yazi at the project root directory
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open Yazi (project root)",
    },
  },

  opts = {
    -- When you open a directory with `nvim .`, open Yazi instead of netrw
    open_for_directories = true,
  },
}
