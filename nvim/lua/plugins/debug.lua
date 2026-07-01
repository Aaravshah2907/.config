-- =============================================================================
-- Debug Adapter Protocol (DAP): Debugger
-- =============================================================================
-- Set breakpoints, step through code, inspect variables — all inside Neovim.
--
--   Space+db  → Toggle breakpoint on current line
--   Space+dc  → Start/Continue debugging
--   Space+do  → Step over
--   Space+di  → Step into
--   Space+dO  → Step out
--   Space+dt  → Terminate debug session
--   Space+du  → Toggle debugger UI
--   Space+de  → Evaluate expression under cursor
-- =============================================================================

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Debugger UI — shows variables, breakpoints, call stack, etc.
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
      -- Virtual text showing variable values inline
      "theHamsta/nvim-dap-virtual-text",
      -- Mason integration for auto-installing debug adapters
      "jay-babu/mason-nvim-dap.nvim",
      -- Python debugger (auto-configures debugpy)
      "mfussenegger/nvim-dap-python",
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- ── Mason DAP: auto-install debug adapters ──────────────────────
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb" }, -- Python + C/C++/Rust
        automatic_installation = true,
        handlers = {},
      })

      -- ── DAP UI setup ───────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      -- Virtual text (shows variable values inline next to code)
      require("nvim-dap-virtual-text").setup()

      -- Python debugger setup
      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local debugpy_path = mason_path .. "/packages/debugpy/venv/bin/python"
      if vim.fn.filereadable(debugpy_path) == 1 then
        require("dap-python").setup(debugpy_path)
      end

      -- ── C/C++ debugger (codelldb) ──────────────────────────────────
      local codelldb_path = mason_path .. "/packages/codelldb/extension/adapter/codelldb"
      if vim.fn.filereadable(codelldb_path) == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
        }
        dap.configurations.cpp = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
        dap.configurations.c = dap.configurations.cpp
      end

      -- ── Auto open/close DAP UI ─────────────────────────────────────
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- ── Breakpoint icons ───────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

      -- ── Keymaps ────────────────────────────────────────────────────
      local map = vim.keymap.set
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Conditional breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      map("n", "<leader>do", dap.step_over, { desc = "Debug: Step over" })
      map("n", "<leader>di", dap.step_into, { desc = "Debug: Step into" })
      map("n", "<leader>dO", dap.step_out, { desc = "Debug: Step out" })
      map("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })
      map("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
      map({ "n", "v" }, "<leader>de", dapui.eval, { desc = "Debug: Evaluate expression" })
    end,
  },
}
