-- =============================================================================
-- Notebook Support
-- =============================================================================
-- Adds .ipynb editing plus Jupyter cell execution from Neovim.
-- =============================================================================

return {
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb" },
    init = function()
      vim.filetype.add({
        extension = {
          ipynb = "ipynb",
        },
      })
      require("custom.notebook_view").setup()
    end,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
    config = function(_, opts)
      require("jupytext").setup(opts)

      vim.api.nvim_create_user_command("NotebookOpenMarkdown", function()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" or not file:match("%.ipynb$") then
          vim.notify("Open an .ipynb file first", vim.log.levels.WARN, { title = "Notebook" })
          return
        end

        vim.cmd("edit jupytext://" .. vim.fn.fnameescape(file) .. "?format=md")
      end, { desc = "Reopen current notebook through Jupytext as Markdown" })
    end,
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "markdown", "ipynb" },
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
    end,
    config = function()
      local map = vim.keymap.set

      map("n", "<leader>ji", "<cmd>MoltenInit<cr>", { desc = "Notebook: Initialize kernel" })
      map("n", "<leader>jr", "<cmd>MoltenEvaluateOperator<cr>", { desc = "Notebook: Run operator" })
      map("n", "<leader>jrr", "<cmd>MoltenEvaluateLine<cr>", { desc = "Notebook: Run line" })
      map("v", "<leader>jr", ":<c-u>MoltenEvaluateVisual<cr>gv", { desc = "Notebook: Run selection" })
      map("n", "<leader>jo", "<cmd>MoltenShowOutput<cr>", { desc = "Notebook: Show output" })
      map("n", "<leader>jh", "<cmd>MoltenHideOutput<cr>", { desc = "Notebook: Hide output" })
      map("n", "<leader>jd", "<cmd>MoltenDelete<cr>", { desc = "Notebook: Delete cell output" })
    end,
  },
  {
    "Vigemus/iron.nvim",
    ft = { "python", "markdown", "ipynb" },
    config = function()
      local iron = require("iron.core")

      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = { "ipython", "--no-autoindent" },
              format = require("iron.fts.common").bracketed_paste_python,
            },
          },
          repl_open_cmd = "botright 15split",
        },
        keymaps = {
          send_motion = "<leader>js",
          visual_send = "<leader>js",
          send_file = "<leader>jf",
          send_line = "<leader>jl",
          send_paragraph = "<leader>jp",
          interrupt = "<leader>j<space>",
          exit = "<leader>jq",
          clear = "<leader>jc",
        },
      })
    end,
  },
}
