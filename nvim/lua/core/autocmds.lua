-- =============================================================================
-- Autocommands — Things That Happen Automatically
-- =============================================================================
-- Autocommands (autocmds) are like "triggers" — when something happens
-- (you save a file, open a file, yank text), Neovim runs code automatically.
-- =============================================================================

local augroup = vim.api.nvim_create_augroup   -- Create a group of autocmds
local autocmd = vim.api.nvim_create_autocmd   -- Create an autocmd

-- ─── Flash Yanked Text ──────────────────────────────────────────────────────
-- When you yank (copy) text, briefly highlight it so you can SEE what
-- was copied. Super helpful when you're learning Vim motions!
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch", -- Use the search highlight color
      timeout = 200,         -- Flash for 200ms
    })
  end,
  desc = "Briefly highlight yanked text",
})

-- ─── Remove Trailing Whitespace ─────────────────────────────────────────────
-- Automatically clean up invisible trailing spaces when you save.
-- These spaces cause messy diffs in git and serve no purpose.
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = [[%s/\s\+$//e]],
  desc = "Remove trailing whitespace on save",
})

-- ─── Return to Last Edit Position ───────────────────────────────────────────
-- When you reopen a file, jump back to where your cursor was last time.
-- (Neovim remembers this in its shada file.)
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last cursor position when opening a file",
})

-- ─── Auto-Resize Splits ─────────────────────────────────────────────────────
-- When you resize your terminal window, automatically resize all
-- Neovim split windows to keep them proportional.
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
  group = "ResizeSplits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto-resize splits when terminal is resized",
})

-- ─── Filetype-Specific Settings ─────────────────────────────────────────────
-- Different languages have different conventions:
--   • Java: 4 spaces per indent (Google/Oracle style)
--   • Markdown: Enable word wrap so long paragraphs are readable
augroup("FileTypeSettings", { clear = true })

autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = "java",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
  desc = "Use 4-space indentation for Java",
})

autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true          -- Wrap long lines in markdown
    vim.opt_local.linebreak = true     -- Wrap at word boundaries, not mid-word
    vim.opt_local.spell = true         -- Enable spell checking
  end,
  desc = "Markdown-friendly settings (wrap, spell check)",
})
