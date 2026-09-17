-- =============================================================================
-- ~/.config/nvim/lua/plugins/tuxedo.lua
-- Tuxedo (todo.txt) plugin integration and keymaps
-- =============================================================================

return {
  name = "tuxedo-nvim",
  dir = vim.fn.stdpath("config"),
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local tuxedo = require("custom.tuxedo")
    local map = vim.keymap.set

    -- ── User Commands ──────────────────────────────────────────────────────────
    vim.api.nvim_create_user_command("TuxedoAdd", function()
      tuxedo.extract_cursor_todo()
    end, { desc = "Extract TODO under cursor to Tuxedo" })

    vim.api.nvim_create_user_command("TuxedoProjectTodos", function()
      tuxedo.project_todos()
    end, { desc = "Browse Tuxedo tasks for current project" })

    vim.api.nvim_create_user_command("TuxedoAllTodos", function()
      tuxedo.all_todos()
    end, { desc = "Browse all Tuxedo tasks" })

    vim.api.nvim_create_user_command("TuxedoTUI", function()
      tuxedo.open_tui()
    end, { desc = "Open Tuxedo TUI inside Neovim" })

    -- ── Keymaps (<leader>t namespace) ──────────────────────────────────────────
    -- <leader>ta : Add TODO under cursor to Tuxedo
    map("n", "<leader>ta", tuxedo.extract_cursor_todo, { desc = "Tuxedo: Add TODO under cursor" })

    -- <leader>tt : Browse project-filtered tasks in Telescope
    map("n", "<leader>tt", tuxedo.project_todos, { desc = "Tuxedo: Project tasks picker" })

    -- <leader>tA : Browse all tasks in Telescope
    map("n", "<leader>tA", tuxedo.all_todos, { desc = "Tuxedo: All tasks picker" })

    -- <leader>tT : Launch Tuxedo interactive TUI
    map("n", "<leader>tT", tuxedo.open_tui, { desc = "Tuxedo: Launch interactive TUI" })
  end,
}
