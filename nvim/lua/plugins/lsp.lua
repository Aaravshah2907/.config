-- =============================================================================
-- LSP: Language Server Protocol — Your Code Intelligence Engine
-- =============================================================================
-- LSP is what gives you IDE-like features:
--   • Go to definition (gd)
--   • Find all references (gr)
--   • Hover documentation (K)
--   • Code actions like "auto import" (Space+ca)
--   • Rename across files (Space+rn)
--   • Error diagnostics (the squiggly underlines!)
--
-- Mason automatically downloads and installs the language servers you need.
-- =============================================================================

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Load when opening a file
    dependencies = {
      -- Mason: auto-installs LSP servers (you don't need to install them manually!)
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      -- ── Mason Setup ──────────────────────────────────────────────────
      -- Mason manages external tools. It installs LSP servers, formatters,
      -- and linters into ~/.local/share/nvim/mason/
      require("mason").setup({
        ui = {
          border = "rounded",       -- Rounded borders on the Mason window
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })



      -- ── Capabilities ────────────────────────────────────────────────
      -- Tell LSP servers what our editor can do (e.g., snippet support).
      -- nvim-cmp adds extra capabilities for better completions.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- ── on_attach: Keymaps That Activate When LSP Connects ────────
      -- These keymaps ONLY work in files where an LSP server is running.
      -- This prevents errors in files that don't have LSP support.
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navigation
        map("gd", vim.lsp.buf.definition,      "Go to definition")
        map("gD", vim.lsp.buf.declaration,      "Go to declaration")
        map("gi", vim.lsp.buf.implementation,    "Go to implementation")
        map("gr", vim.lsp.buf.references,        "Find all references")

        -- Information
        map("K",  vim.lsp.buf.hover,             "Hover documentation")
        map("<leader>D",  vim.lsp.buf.type_definition, "Type definition")

        -- Actions
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>rn", vim.lsp.buf.rename,      "Rename symbol")

        -- Symbols
        map("<leader>ds", vim.lsp.buf.document_symbol,  "Document symbols")
        map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")

        -- Diagnostics (errors/warnings)
        map("[d", vim.diagnostic.goto_prev,    "Previous diagnostic")
        map("]d", vim.diagnostic.goto_next,    "Next diagnostic")
        map("<leader>dl", vim.diagnostic.open_float, "Show diagnostic details")
      end

      -- ── Configure Individual Servers ─────────────────────────────────
      local lspconfig = require("lspconfig")

      -- Handler function that applies shared config to every server
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html",         -- HTML
          "cssls",        -- CSS
          "ts_ls",        -- JavaScript & TypeScript
          "jdtls",        -- Java
          "lua_ls",       -- Lua
          "marksman",     -- Markdown
          "pyright",      -- Python
          "clangd",       -- C/C++
        },
        automatic_installation = true,
        handlers = {
          -- Default handler for all servers
          function(server_name)
            lspconfig[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,

          -- Special config for Lua
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" },
                  },
                  workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  telemetry = { enable = false },
                },
              },
            })
          end,
        },
      })

      -- ── Diagnostic Display Settings ──────────────────────────────────
      -- How errors/warnings appear in the editor
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●", -- Dot icon before inline error text
          spacing = 4,
        },
        signs = true,          -- Show icons in the sign column
        underline = true,      -- Underline the problematic code
        update_in_insert = false, -- Don't update diagnostics while typing
        severity_sort = true,  -- Show errors before warnings
        float = {
          border = "rounded",
          source = true,       -- Show which LSP server reported the error
        },
      })

      -- Custom icons for diagnostics in the sign column
      local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },
}
