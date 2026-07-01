return {
  "cpkb-nvim",
  dir = vim.fn.expand("~/cpkb/extras/plugins/nvim"),
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Load the custom extension from cpkb
    require("telescope").load_extension("cpkb")
    
    -- Map Space+cs to open the snippet picker
    vim.keymap.set("n", "<leader>cs", "<cmd>Telescope cpkb<cr>", { desc = "CPKB Snippets" })
  end,
}
