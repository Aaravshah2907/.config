-- =============================================================================
-- Toggleterm: Floating Terminal Inside Neovim
-- =============================================================================
-- Open a terminal without leaving the editor! Great for running commands,
-- git operations, or quick shell tasks.
--
--   Ctrl+\      → Toggle the floating terminal
--   Space+tf    → Floating terminal
--   Space+th    → Horizontal split terminal
--   Space+tv    → Vertical split terminal
--   Space+tg    → Lazygit (full git TUI inside Neovim!)
-- =============================================================================

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",

  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
    })

    -- Custom terminals
    local Terminal = require("toggleterm.terminal").Terminal

    -- Lazygit terminal (full git TUI)
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      float_opts = { border = "curved" },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })

    -- Keymaps
    local map = vim.keymap.set
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })
    map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
    map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
    map("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Terminal: Lazygit" })

    -- Exit terminal mode with Esc (instead of Ctrl+\+Ctrl+n)
    map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
    map("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
  end,
}
