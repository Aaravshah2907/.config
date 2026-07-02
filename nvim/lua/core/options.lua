-- =============================================================================
-- Core Options — How Neovim Behaves
-- =============================================================================
-- These settings control the fundamental behavior of the editor.
-- Think of this as your "Preferences" panel in a GUI editor.
-- =============================================================================

local opt = vim.opt -- Shorthand so we don't type vim.opt every time

-- ─── Line Numbers ───────────────────────────────────────────────────────────
-- Shows the current line number AND relative numbers for other lines.
-- Relative numbers make it easy to jump: "5j" moves down 5 lines.
opt.number = true -- Show the actual line number on the current line
opt.relativenumber = true -- Other lines show distance from current line

-- ─── Mouse ──────────────────────────────────────────────────────────────────
-- Enable mouse support in all modes. You can click to place cursor, scroll,
-- resize splits, and select text — just like in nano or any GUI editor.
opt.mouse = "a"

-- ─── Search ─────────────────────────────────────────────────────────────────
-- Smart case searching: if you search lowercase, it's case-insensitive.
-- If you include ANY uppercase letter, it becomes case-sensitive.
-- Example: "/hello" matches "Hello" and "hello", but "/Hello" only matches "Hello"
opt.ignorecase = true
opt.smartcase = true

-- ─── Window Splits ──────────────────────────────────────────────────────────
-- When you split the window (like having two files side by side), these
-- control where the new window appears. Most editors put new splits to
-- the right and below, so we do the same.
opt.splitright = true -- Vertical splits open to the right
opt.splitbelow = true -- Horizontal splits open below

-- ─── Colors ─────────────────────────────────────────────────────────────────
-- Enable 24-bit RGB colors in the terminal. Required for our colorscheme
-- to look correct. Your terminal (iTerm2, Alacritty, Kitty, etc.) needs
-- to support true color too — most modern terminals do.
opt.termguicolors = true

-- ─── Sign Column ────────────────────────────────────────────────────────────
-- The sign column is the thin strip to the left of line numbers.
-- Git changes, errors, and breakpoints show icons here.
-- "yes" means always show it, so the text doesn't jump left/right.
opt.signcolumn = "yes"

-- ─── Performance ────────────────────────────────────────────────────────────
-- updatetime: how long (ms) Neovim waits after you stop typing before
-- triggering CursorHold events. Lower = faster feedback for things like
-- git blame, diagnostics highlights, etc. Default is 4000ms — way too slow.
opt.updatetime = 250

-- timeoutlen: how long (ms) Neovim waits for the next key in a multi-key
-- mapping. Example: you press <leader> and have 300ms to press the next key.
opt.timeoutlen = 300

-- ─── Persistent Undo ────────────────────────────────────────────────────────
-- This saves your undo history to a file, so you can undo changes even
-- after closing and reopening a file. Like infinite Ctrl+Z across sessions!
opt.undofile = true

-- ─── Indentation ────────────────────────────────────────────────────────────
-- Use spaces instead of tabs, with 2 spaces per indent level.
-- This is the most common setting for web development (HTML/CSS/JS).
-- Java uses 4 spaces — we set that per-filetype in autocmds.lua.
opt.expandtab = true -- Press Tab → insert spaces (not a tab character)
opt.shiftwidth = 4 -- Number of spaces for each indent level
opt.tabstop = 4 -- How wide a tab character looks (if one exists)

-- ─── Line Wrapping ──────────────────────────────────────────────────────────
-- Don't wrap long lines — let them scroll horizontally.
-- This keeps code neatly aligned. (In nano, lines wrap by default.)
opt.wrap = true

-- ─── Scroll Offset ──────────────────────────────────────────────────────────
-- Keep at least 8 lines visible above and below the cursor when scrolling.
-- This prevents the cursor from getting "trapped" at the very edge of the screen.
opt.scrolloff = 8
opt.sidescrolloff = 8 -- Same but for horizontal scrolling

-- ─── Cursor Line ────────────────────────────────────────────────────────────
-- Highlight the line the cursor is on. Makes it easier to find your cursor.
opt.cursorline = true

-- ─── Clipboard ──────────────────────────────────────────────────────────────
-- Sync Neovim's clipboard with your system clipboard.
-- When you yank (copy) in Neovim, it goes to Cmd+V clipboard too.
-- When you copy something outside Neovim, you can paste with p inside.
opt.clipboard = "unnamedplus"

-- ─── Completion Menu ────────────────────────────────────────────────────────
-- Controls how the autocomplete popup behaves:
-- "menuone" = show menu even with only one match
-- "noselect" = don't auto-select the first item (let you choose)
opt.completeopt = "menuone,noselect"

-- ─── Misc ───────────────────────────────────────────────────────────────────
opt.showmode = false -- Don't show "-- INSERT --" (lualine already shows it)
opt.backup = false -- Don't create backup files (we have undofile + git)
opt.swapfile = false -- Don't create swap files
opt.fileencoding = "utf-8" -- Use UTF-8 encoding
opt.conceallevel = 3 -- Hide markup in markdown (nice for Obsidian notes)
