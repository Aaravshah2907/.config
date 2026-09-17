-- =============================================================================
-- nvim-tree: Sidebar File Explorer
-- =============================================================================
-- Yazi stays as the full terminal file manager on <leader>e / <leader>E.
-- nvim-tree gives you a persistent editor sidebar for project navigation.
-- =============================================================================

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = {
    "NvimTreeToggle",
    "NvimTreeFocus",
    "NvimTreeFindFile",
    "NvimTreeCollapse",
    "NvimTreeRefresh",
  },
  keys = {
    { "<leader>nt", "<cmd>NvimTreeToggle<cr>", desc = "[N]vim-tree [T]oggle" },
    { "<leader>nf", "<cmd>NvimTreeFindFile<cr>", desc = "[N]vim-tree [F]ind current file" },
    { "<leader>nr", "<cmd>NvimTreeRefresh<cr>", desc = "[N]vim-tree [R]efresh" },
    { "<leader>nc", "<cmd>NvimTreeCollapse<cr>", desc = "[N]vim-tree [C]ollapse" },
  },
  init = function()
    -- Disable netrw so nvim-tree can own directory buffers cleanly.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {
    hijack_directories = {
      enable = false, -- Keep `nvim .` opening Yazi via your yazi.nvim config.
    },
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    reload_on_bufenter = true,
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 34,
      side = "left",
      preserve_window_proportions = true,
      signcolumn = "yes",
    },
    renderer = {
      root_folder_label = ":~:s?$?/..?",
      highlight_git = true,
      highlight_diagnostics = "name",
      indent_markers = {
        enable = true,
      },
      icons = {
        glyphs = {
          git = {
            unstaged = "!",
            staged = "+",
            unmerged = "=",
            renamed = "»",
            untracked = "?",
            deleted = "x",
            ignored = "-",
          },
        },
      },
    },
    diagnostics = {
      enable = true,
      show_on_dirs = true,
      icons = {
        hint = "h",
        info = "i",
        warning = "!",
        error = "x",
      },
    },
    filters = {
      dotfiles = false,
      git_ignored = false,
    },
    git = {
      enable = true,
      ignore = false,
      timeout = 400,
    },
    actions = {
      open_file = {
        quit_on_open = false,
        resize_window = true,
      },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
  },
}
