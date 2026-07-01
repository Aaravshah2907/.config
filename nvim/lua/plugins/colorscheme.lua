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
      flavour = "mocha", -- Using mocha as base for our custom Cosmere theme

      transparent_background = true, -- Shows your terminal background
      
      color_overrides = {
        mocha = {
          base = "#001a33",        -- Stormlight / Deep Sapphire Night (DEEP_NIGHT)
          mantle = "#001122",      -- Deeper night for sidebars
          crust = "#000a14",       -- Absolute deepest night
          
          text = "#C8E8F5",        -- Preservation Mist (PRES_MIST)
          subtext1 = "#A0AAB5",    -- Frosted Silver (PRES_SILVER)
          subtext0 = "#708090",    -- Rosharan Stone (SLATE)
          
          blue = "#00BFFF",        -- Windrunner Sapphire (SAPPHIRE)
          sapphire = "#00A8E8",    -- Honorspren Sky Blue (SPREN_HONOR)
          sky = "#5DA8CC",         -- Glacial Teal (PRES_GLACIAL)
          teal = "#006064",        -- Nightwatcher Teal (SPREN_NIGHT)
          green = "#50fa7b",       -- Lifebound Emerald (EMERALD)
          yellow = "#FFD700",      -- Radiance of Oaths Gold (HONOR_GOLD)
          peach = "#FFAB40",       -- Sibling Crystal Amber (SPREN_SIBLING)
          
          maroon = "#6B1A1A",      -- Ruin's Bloodline (RUIN_MAROON)
          red = "#ed8796",         -- Odium's Touch (CRIMSON)
          mauve = "#E040FB",       -- Willshaper Amethyst (SPREN_WILL)
          pink = "#DA70D6",        -- Cryptic Orchid (SPREN_CRYPTIC)
          flamingo = "#FF4500",    -- Volcanic Ashspren (SPREN_ASH)
          rosewater = "#C3AEE8",   -- Preservation Lavender (PRES_LAVENDER)
        },
      },

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
