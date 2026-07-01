-- =============================================================================
-- Code Runner: Compile & Run Code Instantly
-- =============================================================================
-- Press a key and your code runs immediately in a split terminal.
-- Supports C++, Python, Java, and more.
--
--   Space+rc  → Run current file
--   Space+rr  → Run with input from 'input.txt' (competitive programming!)
-- =============================================================================

return {
  "code-runner",
  name = "code-runner",
  dir = vim.fn.stdpath("config") .. "/lua/custom/code-runner",
  event = "VeryLazy",

  config = function()
    -- File type → shell command mapping
    local runners = {
      cpp = "cd '%:p:h' && g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%:p' && /tmp/nvim_run",
      c = "cd '%:p:h' && gcc -std=c11 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%:p' && /tmp/nvim_run",
      python = "cd '%:p:h' && python3 '%:p'",
      java = "cd '%:p:h' && javac '%:p' && java -cp '%:p:h' '%:t:r'",
      javascript = "cd '%:p:h' && node '%:p'",
      typescript = "cd '%:p:h' && npx ts-node '%:p'",
      lua = "cd '%:p:h' && lua '%:p'",
      sh = "cd '%:p:h' && bash '%:p'",
      html = "open '%:p'",
    }

    -- Run current file
    vim.keymap.set("n", "<leader>rc", function()
      local ft = vim.bo.filetype
      local cmd = runners[ft]
      if not cmd then
        vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
        return
      end
      -- Save first, then run in a horizontal split terminal
      vim.cmd("w")
      vim.cmd("belowright 15split | terminal " .. cmd)
      vim.cmd("startinsert")
    end, { desc = "Run: Current file" })

    -- Run with input.txt (for competitive programming)
    vim.keymap.set("n", "<leader>ri", function()
      local ft = vim.bo.filetype
      local dir = vim.fn.expand("%:p:h")
      local input_file = dir .. "/input.txt"
      local cmd

      if ft == "cpp" then
        cmd = string.format(
          "cd '%s' && g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s' && /tmp/nvim_run < '%s'",
          dir, vim.fn.expand("%:p"), input_file
        )
      elseif ft == "python" then
        cmd = string.format("cd '%s' && python3 '%s' < '%s'", dir, vim.fn.expand("%:p"), input_file)
      elseif ft == "c" then
        cmd = string.format(
          "cd '%s' && gcc -std=c11 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s' && /tmp/nvim_run < '%s'",
          dir, vim.fn.expand("%:p"), input_file
        )
      elseif ft == "java" then
        cmd = string.format(
          "cd '%s' && javac '%s' && java -cp '%s' '%s' < '%s'",
          dir, vim.fn.expand("%:p"), dir, vim.fn.expand("%:t:r"), input_file
        )
      else
        vim.notify("No input runner for filetype: " .. ft, vim.log.levels.WARN)
        return
      end

      vim.cmd("w")
      vim.cmd("belowright 15split | terminal " .. cmd)
      vim.cmd("startinsert")
    end, { desc = "Run: With input.txt" })

    -- Quick create input.txt in the same directory
    vim.keymap.set("n", "<leader>re", function()
      local dir = vim.fn.expand("%:p:h")
      vim.cmd("edit " .. dir .. "/input.txt")
    end, { desc = "Run: Edit input.txt" })
  end,
}
