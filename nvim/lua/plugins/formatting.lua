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
          python = { "isort", "black" },
          c = { "clang-format" },
          cpp = { "clang-format" },
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
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "stylua",
          "isort",
          "black",
          "clang-format",
          "google-java-format",
        },
      })
    end,
  }
}
