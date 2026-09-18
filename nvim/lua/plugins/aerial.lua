return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  cmd = {
    "AerialToggle",
    "AerialOpen",
    "AerialClose",
    "AerialNavToggle",
    "AerialPrev",
    "AerialNext",
  },
  keys = {
    { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle Aerial outline" },
    { "<leader>A", "<cmd>AerialNavToggle<cr>", desc = "Toggle Aerial nav" },
    { "[s", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
    { "]s", "<cmd>AerialNext<cr>", desc = "Next symbol" },
  },
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      show_guides = true,
      icons = {
        File = "󰈙",
        Module = "󰆧",
        Namespace = "󰅪",
        Package = "󰏗",
        Class = "󰠱",
        Method = "󰆧",
        Property = "󰜢",
        Field = "󰜢",
        Constructor = "󰒓",
        Enum = "󰕘",
        Interface = "󰕘",
        Function = "󰊕",
        Variable = "󰀫",
        Constant = "󰏿",
        String = "󰀬",
        Number = "󰎠",
        Boolean = "◩",
        Array = "󰅪",
        Object = "󰅩",
        Key = "󰌋",
        Null = "󰟢",
        EnumMember = "󰕘",
        Struct = "󰙅",
        Event = "󰉁",
        Operator = "󰆕",
        TypeParameter = "󰊄",
      },
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol" })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
      end,
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = "right",
      },
      nav = {
        border = "single",
        max_height = 0.8,
        min_height = 12,
        max_width = 0.5,
        min_width = 32,
      },
    })
  end,
}
