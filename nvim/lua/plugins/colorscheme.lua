-- =============================================================================
-- Colorscheme: Catppuccin
-- =============================================================================
-- Catppuccin is a warm, pastel colorscheme that's easy on the eyes.
-- The "mocha" flavour is the darkest variant — great for late-night coding.
--
-- priority = 1000 → loads BEFORE other plugins so colors are ready.
-- lazy = false   → loads immediately at startup (not deferred).
-- =============================================================================

return {
  "catppuccin/nvim",
  name = "catppuccin", -- How lazy.nvim refers to this plugin internally
  priority = 1000,     -- High priority = loads first
  lazy = false,        -- Load immediately, not on-demand

  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- Options: latte (light), frappe, macchiato, mocha (darkest)

      -- Enable integrations so other plugins pick up Catppuccin colors
      integrations = {
        cmp = true,              -- Completion menu
        treesitter = true,       -- Syntax highlighting
        telescope = {            -- Fuzzy finder
          enabled = true,
        },
        gitsigns = true,         -- Git change markers in the gutter
        native_lsp = {           -- Language Server Protocol highlights
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        indent_blankline = {     -- Indent guide lines
          enabled = true,
          scope_color = "lavender",
          colored_indent_levels = false,
        },
        noice = true,            -- Better command-line UI
        notify = true,           -- Notification popups
        which_key = true,        -- Keybinding helper popup
        illuminate = {           -- Word highlighting under cursor
          enabled = true,
          lsp = true,
        },
        alpha = true,            -- Dashboard
      },
    })

    -- Actually apply the colorscheme
    vim.cmd.colorscheme("catppuccin")
  end,
}
