-- =============================================================================
-- Treesitter: Smart Syntax Highlighting & Code Understanding
-- =============================================================================
-- Treesitter parses your code into a syntax tree, giving Neovim a deep
-- understanding of code structure. This enables:
--   • Beautiful, accurate syntax highlighting (not just regex-based)
--   • Smart indentation
--   • Text objects (select a function, a class, etc.)
-- =============================================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Auto-update parsers when the plugin updates

    config = function()
      require("nvim-treesitter").setup({
        -- Install parsers for these languages automatically
        ensure_installed = {
          "html",
          "css",
          "javascript",
          "typescript",
          "java",
          "lua",
          "python",
          "c",
          "cpp",
          "json",
          "yaml",
          "markdown",
          "markdown_inline",
          "vim",
          "vimdoc",
          "bash",
          "regex",
        },

        -- Automatically install parsers when you open a new file type
        auto_install = true,

        highlight = {
          enable = true, -- Enable syntax highlighting (the main feature!)
        },

        indent = {
          enable = true, -- Smart indentation based on syntax tree
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            -- Press Enter to expand selection, Backspace to shrink:
            -- First press: selects the word → then the expression →
            -- then the statement → then the function → etc.
            init_selection = "<CR>",     -- Start selecting
            node_incremental = "<CR>",   -- Expand selection
            node_decremental = "<BS>",   -- Shrink selection
            scope_incremental = false,   -- Disabled (use CR instead)
          },
        },
      })
    end,
  },

  -- Smart text objects powered by Treesitter
  -- Lets you do things like: "daf" = delete a function, "vac" = select a class
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
