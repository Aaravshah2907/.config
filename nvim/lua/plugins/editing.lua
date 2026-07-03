-- =============================================================================
-- Editing Helpers — Quality of Life Plugins
-- =============================================================================
-- These plugins make everyday editing smoother and more pleasant.
-- Each one handles a specific task.
-- =============================================================================

return {

  -- ---------------------------------------------------------------------------
  -- Autopairs: Auto-close brackets, quotes, etc.
  -- ---------------------------------------------------------------------------
  -- When you type ( it adds ) automatically. Same for {}, [], "", '', ``.
  -- Also integrates with nvim-cmp so completions work with autopairs.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      -- Make autopairs work with completions (auto-add parentheses after function)
      local ok, cmp = pcall(require, "cmp")
      if ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Comment.nvim: Toggle comments easily
  -- ---------------------------------------------------------------------------
  -- gcc → toggle comment on current line
  -- gc  → toggle comment on selected lines (in visual mode)
  -- Automatically uses the right comment syntax for each language.
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {}, -- Defaults are perfect
  },

  -- ---------------------------------------------------------------------------
  -- nvim-surround: Surround text with brackets/quotes
  -- ---------------------------------------------------------------------------
  -- Powerful motions for adding, changing, and deleting surroundings:
  --   ys{motion}{char} → surround with char (e.g., ysiw" wraps word in quotes)
  --   ds{char}         → delete surrounding char (e.g., ds" removes quotes)
  --   cs{old}{new}     → change surrounding (e.g., cs"' changes " to ')
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- ---------------------------------------------------------------------------
  -- Todo Comments: Highlight TODO, FIXME, NOTE in your code
  -- ---------------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#C3AEE8" }, -- Elsecaller Purple
        test = { "Identifier", "#FF00FF" }
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- Which-Key: Keybinding Helper Popup
  -- ---------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          spelling = { enabled = true },
        },
        win = {
          border = "rounded",
        },
        keys = {
          scroll_down = "<c-d>",
          scroll_up = "<c-u>",
        },
      })
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>o", group = "Obsidian" },
        { "<leader>r", group = "Run" },
        { "<leader>s", group = "Surround" },
        { "<leader>t", group = "Terminal" },
        { "<leader>w", group = "Workspace" },
        { "<leader>x", group = "Trouble" },
        { "<leader>z", desc = "Zen Mode" },
        { "<leader>c", group = "Code", mode = "v" },
        { "<leader>d", group = "Debug", mode = "v" },
        { "<leader>g", group = "Git", mode = "v" },
        { "<leader>s", group = "Surround", mode = "v" },
        { "<leader>p", desc = "Paste (keep clipboard)", mode = "v" },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Gitsigns: Git integration in the gutter
  -- ---------------------------------------------------------------------------
  -- Shows which lines have been added (+), modified (~), or deleted (-)
  -- in the sign column. Also enables inline git blame.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        -- Keymaps for git operations
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
          end

          map("n", "]h", gs.next_hunk, "Next hunk")
          map("n", "[h", gs.prev_hunk, "Previous hunk")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")

          -- Visual mode: stage/reset selected lines
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selected")
          map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selected")
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Illuminate: Highlight other occurrences of the word under cursor
  -- ---------------------------------------------------------------------------
  -- When your cursor is on a variable, all other uses of that variable
  -- get subtly highlighted. Great for tracking variable usage.
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        delay = 200,           -- Wait 200ms before highlighting
        large_file_cutoff = 2000, -- Disable in very large files
        filetypes_denylist = {    -- Don't run in these file types
          "alpha",
          "lazy",
          "mason",
          "help",
        },
      })
    end,
  },
}
