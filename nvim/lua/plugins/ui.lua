-- =============================================================================
-- UI Plugins
-- =============================================================================
-- This file bundles all the visual/UI enhancement plugins together.
-- In lazy.nvim, returning a list of tables means each entry is a separate plugin.
-- =============================================================================

return {

  -- ---------------------------------------------------------------------------
  -- Lualine: Statusline at the bottom of the screen
  -- ---------------------------------------------------------------------------
  -- Think of it like the status bar in other editors — shows file name, git
  -- branch, errors, your position in the file, etc.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy", -- Load after startup for speed

    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- Match our colorscheme
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        -- Sections control what appears in each part of the statusline:
        --   a | b | c              x | y | z
        --  (left side)           (right side)
        sections = {
          lualine_a = { "mode" },        -- Current mode (NORMAL, INSERT, etc.)
          lualine_b = { "branch", "diff", "diagnostics" }, -- Git info + errors
          lualine_c = { "filename" },    -- Current file name
          lualine_x = { "filetype" },    -- File type (lua, python, etc.)
          lualine_y = { "progress" },    -- How far through the file (%)
          lualine_z = { "location" },    -- Line:Column number
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Bufferline: Tabs at the top of the screen
  -- ---------------------------------------------------------------------------
  -- Each open file gets a "tab" at the top, like browser tabs.
  -- Makes it easy to switch between open files.
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",

    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp", -- Show error/warning counts on tabs
          -- (Using default bufferline highlights which pick up our colorscheme)
          separator_style = "slant",    -- Angled tab separators
          show_buffer_close_icons = true,
          show_close_icon = false,
          always_show_bufferline = true, -- Show even with one file open
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Indent Blankline: Subtle vertical indent guides
  -- ---------------------------------------------------------------------------
  -- Draws thin vertical lines at each indentation level so you can see
  -- which code belongs to which block (like matching braces visually).
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl", -- The module name is "ibl", not "indent_blankline"
    event = { "BufReadPost", "BufNewFile" }, -- Load when opening a file

    config = function()
      require("ibl").setup({
        indent = {
          char = "│",           -- The character used for indent lines
        },
        scope = {
          enabled = true,       -- Highlight the current scope's indent line
          show_start = false,   -- Don't underline the scope start
          show_end = false,     -- Don't underline the scope end
        },
        exclude = {
          filetypes = { "help", "alpha", "dashboard", "lazy", "mason" },
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Web Devicons: File type icons
  -- ---------------------------------------------------------------------------
  -- Adds little icons next to file names (e.g., a JS icon for .js files).
  -- Many other plugins depend on this for their icons.
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true, -- Loaded when other plugins need it
  },

  -- ---------------------------------------------------------------------------
  -- Alpha: Dashboard / Start screen
  -- ---------------------------------------------------------------------------
  -- The screen you see when you open Neovim without a file.
  -- Shows a cool ASCII art header and quick-access buttons.
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter", -- Show on startup

    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- ASCII art header — this is what you see at the top of the dashboard
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }
      dashboard.section.header.opts.hl = "Statement" -- This will give it a nice blue/sapphire color

      -- Quick-access buttons — press the highlighted letter to trigger
      -- The format is: button("shortcut", "  Icon  Label", ":command")
      dashboard.section.buttons.val = {
        dashboard.button("n", "  New File",     ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "  Find File",    ":Telescope find_files <CR>"),
        dashboard.button("r", "  Recent Files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Find Word",    ":Telescope live_grep <CR>"),
        dashboard.button("e", "  Open Yazi",    ":Yazi <CR>"),

        dashboard.button("q", "  Quit",         ":qa<CR>"),
      }

      -- Footer — shows a message at the bottom
      dashboard.section.footer.val = "Life before death. Strength before weakness. Journey before destination. ⚔️"
      dashboard.section.footer.opts.hl = "Comment"

      -- Apply padding between sections
      dashboard.config.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)

      -- Don't show the statusline on the dashboard
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          vim.opt_local.laststatus = 0
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Noice: Better UI for messages, cmdline, and popups
  -- ---------------------------------------------------------------------------
  -- Replaces the default command line at the bottom with a centered popup,
  -- shows search results count, and makes notifications prettier.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",       -- UI components library
      "rcarriga/nvim-notify",       -- Pretty notification popups
    },

    config = function()
      require("noice").setup({
        lsp = {
          -- Use Noice for LSP hover/signature instead of defaults
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,         -- Classic search at bottom
          command_palette = true,        -- Centered command popup
          long_message_to_split = true,  -- Long messages go to a split
          inc_rename = false,            -- Don't use for rename
          lsp_doc_border = true,         -- Add border to LSP hover docs
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Dressing: Better vim.ui.select and vim.ui.input
  -- ---------------------------------------------------------------------------
  -- When Neovim asks you to pick something from a list or type input,
  -- this makes those popups look much nicer.
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {}, -- Use defaults — they're already great
  },
}
