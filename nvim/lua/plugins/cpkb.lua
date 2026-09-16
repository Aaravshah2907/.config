return {
  "cpkb-nvim",
  dir = vim.fn.expand("~/cpkb/extras/plugins/nvim"),
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Load the custom extension from cpkb
    pcall(require("telescope").load_extension, "cpkb")

    -- Add commands
    vim.api.nvim_create_user_command("CPKBAddVisual", function()
      require("cpkb.add").add_from_visual()
    end, { desc = "Add snippet to CPKB from visual selection" })

    vim.api.nvim_create_user_command("CPKBAddYank", function()
      require("cpkb.add").add_from_yank()
    end, { desc = "Add snippet to CPKB from yank register" })

    -- Map CPKB keys under <leader>c namespace
    local map = vim.keymap.set
    -- <leader>cs: Telescope Snippets Picker
    map("n", "<leader>cs", "<cmd>Telescope cpkb<cr>", { desc = "CPKB Snippets Picker" })
    
    -- <leader>cv: Add snippet from visual selection
    map("v", "<leader>cv", function()
      require("cpkb.add").add_from_visual()
    end, { desc = "CPKB Add from Visual Selection" })

    -- <leader>cy: Add snippet from yank register
    map("n", "<leader>cy", function()
      require("cpkb.add").add_from_yank()
    end, { desc = "CPKB Add from Yank Register" })
  end,
}
