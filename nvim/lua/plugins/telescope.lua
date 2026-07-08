-- =============================================================================
-- Telescope: Fuzzy Finder (like Ctrl+P in VS Code)
-- =============================================================================
-- Telescope is how you find things in Neovim:
--   • Find files by name (Space+ff)
--   • Search file contents (Space+fg)
--   • Switch between open files (Space+fb)
--   • And much more!
-- =============================================================================

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required utility library
    {
      -- FZF integration for much faster fuzzy matching
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make", -- Compiles a C library for speed
    },
  },
  event = "VimEnter", -- Load on startup so keys work immediately

  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        -- How results are sorted and searched
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top", -- Search bar at the top
        },
        -- Ignore these directories when searching
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "target/",
          "build/",
          "dist/",
        },
      },
    })

    -- Load the FZF extension for better fuzzy matching
    pcall(telescope.load_extension, "fzf")

    -- ── Keymaps ──────────────────────────────────────────────────────────
    -- All Telescope keymaps start with <leader>f (f = Find)
    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files,    { desc = "Find files" })
    map("n", "<leader>fg", builtin.live_grep,     { desc = "Find in files (grep)" })
    map("n", "<leader>fb", builtin.buffers,       { desc = "Find open buffers" })
    map("n", "<leader>fh", builtin.help_tags,     { desc = "Find help" })
    map("n", "<leader>fr", builtin.oldfiles,      { desc = "Find recent files" })
    map("n", "<leader>fd", builtin.diagnostics,   { desc = "Find diagnostics" })
    map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols" })
    map("n", "<leader>fc", builtin.current_buffer_fuzzy_find, { desc = "Find in current file" })
    map("n", "<leader>ft", builtin.builtin, { desc = "Find Telescope builtins" })
    map("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
    map("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under cursor" })
    map("n", "<leader>fn", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Neovim config files" })
    map("n", "<leader>fR", builtin.registers, { desc = "Find Registers" })
  end,
}
