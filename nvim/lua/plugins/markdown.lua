return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      latex = {
        enabled = true,
        converter = { "utftex", "latex2text" },
        top_pad = 1,
        bottom_pad = 1,
      },
      heading = {
        enabled = true,
        icons = { "◆ ", "◇ ", "◈ ", "▸ ", "▹ ", "▪ " },
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
      },
    },
  },
}
