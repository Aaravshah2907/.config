-- =============================================================================
-- Formatting: Auto-format Code on Save
-- =============================================================================
-- conform.nvim runs code formatters automatically when you save a file.
-- It uses external tools like Prettier (web) and google-java-format (Java).
--
-- Mason will install these formatters, but you can also install them manually:
--   brew install prettier
--   brew install google-java-format
--
-- Space+cf → Manually format the current file or selection
-- =============================================================================

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          html = { "prettier" },
          css = { "prettier" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          java = { "google-java-format" },
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          tex = { "latexindent" },
          latex = { "latexindent" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_format = "fallback",
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ timeout_ms = 1000, lsp_format = "fallback" })
      end, { desc = "Format file/selection" })
    end,
  },
}
