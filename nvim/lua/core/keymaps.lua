-- =============================================================================
-- Keymaps — Your Keyboard Shortcuts
-- =============================================================================
-- These are your custom keyboard shortcuts. The "leader" key is Space
-- (set in init.lua), so <leader>w means: press Space, then w.
--
-- Quick reference for modes:
--   "n" = Normal mode (navigating, not typing)
--   "i" = Insert mode (typing text)
--   "v" = Visual mode (selecting text)
--   "x" = Visual Block mode
--   "t" = Terminal mode
-- =============================================================================

local map = vim.keymap.set -- Shorthand for setting keymaps

-- ─── Escape Insert Mode ─────────────────────────────────────────────────────
-- Instead of reaching for the Escape key, type "jk" quickly to leave
-- insert mode. This is a very common Vim trick — your fingers stay on
-- the home row. If you actually need to type "jk", just type slowly.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ─── Save, Quit, Save+Quit ─────────────────────────────────────────────────
-- Coming from nano: Ctrl+O was save, Ctrl+X was quit.
-- In Neovim: Space+w saves, Space+q quits, Space+x does both.
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>wq<cr>", { desc = "Save and quit" })
map("n", "<leader>?", "<cmd>e ~/nvim_cheatsheet.md<cr>", { desc = "Open Cheatsheet" })

-- ─── Navigate Between Splits ────────────────────────────────────────────────
-- When you have multiple files open side-by-side (splits), use
-- Ctrl+h/j/k/l to jump between them (h=left, j=down, k=up, l=right).
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to split below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to split above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ─── Resize Splits ──────────────────────────────────────────────────────────
-- Ctrl+Arrow keys to resize the current split window.
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ─── Move Lines in Visual Mode ──────────────────────────────────────────────
-- Select lines in visual mode, then press J to move them down or K to
-- move them up. Very handy for rearranging code!
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })

-- ─── Clear Search Highlights ────────────────────────────────────────────────
-- After searching with /, the matches stay highlighted. Press Space+/
-- to clear them so they stop distracting you.
map("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- ─── Yazi File Browser ──────────────────────────────────────────────────────
-- NOTE: The <leader>e and <leader>E keymaps for Yazi are set in
-- lua/plugins/yazi.lua so they only activate when the plugin loads.

-- ─── Centered Scrolling ─────────────────────────────────────────────────────
-- When jumping half a page with Ctrl+d/u, keep the cursor in the center
-- of the screen. This prevents disorientation when scrolling fast.
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- ─── Centered Search Navigation ─────────────────────────────────────────────
-- When jumping between search results with n/N, center the result
-- on screen and open any folds. Makes it easy to see context.
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- ─── Better Paste ───────────────────────────────────────────────────────────
-- When you select text and paste over it, Vim normally replaces your
-- clipboard with the deleted text. This keeps your original clipboard
-- intact so you can paste the same thing multiple times.
map("x", "<leader>p", '"_dP', { desc = "Paste without losing clipboard" })

-- ─── Buffer Navigation ─────────────────────────────────────────────────────
-- Buffers are like tabs. Navigate between open files:
--   Space+bn = next buffer, Space+bp = previous buffer, Space+bd = close
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- ─── Better Indenting ───────────────────────────────────────────────────────
-- In visual mode, after indenting with < or >, keep the selection
-- so you can indent/outdent multiple times without reselecting.
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })
