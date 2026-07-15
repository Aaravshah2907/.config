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
map("n", "<leader>w", "<cmd>w<cr>", { desc = "[W]rite File (Save)" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "[Q]uit" })
map("n", "<leader>x", "<cmd>wq<cr>", { desc = "Save and e[X]it" })
map("n", "<leader>?", "<cmd>e ~/nvim_cheatsheet.md<cr>", { desc = "[?] Open Cheatsheet" })

-- ─── Navigate Between Splits ────────────────────────────────────────────────
-- When you have multiple files open side-by-side (splits), use
-- Ctrl+h/j/k/l to jump between them (h=left, j=down, k=up, l=right).
map("n", "<C-h>", "<C-w>h", { desc = "Move to [H] (Left) split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to [J] (Down) split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to [K] (Up) split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to [L] (Right) split" })

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
map("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "[/] Clear search highlights" })

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
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "[B]uffer [N]ext" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "[B]uffer [P]revious" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "[B]uffer [D]elete" })

-- ─── Better Indenting ───────────────────────────────────────────────────────
-- In visual mode, after indenting with < or >, keep the selection
-- so you can indent/outdent multiple times without reselecting.
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- ─── Visual Mode: Search Selected Text ─────────────────────────────────────
-- Select some text, then press * to search for it across the file.
map("v", "*", '"zy/\\V<C-r>z<cr>', { desc = "[*] Search selected text forward" })
map("v", "#", '"zy?\\V<C-r>z<cr>', { desc = "[#] Search selected text backward" })

-- ─── Visual Mode: Sort Selected Lines ──────────────────────────────────────
-- Select lines, press Space+ss to sort them alphabetically.
map("v", "<leader>ss", ":sort<cr>", { desc = "[S]ort [S]elected lines" })
map("v", "<leader>su", ":sort u<cr>", { desc = "[S]ort [U]nique lines" })

-- ─── Visual Mode: Yank to System Clipboard ─────────────────────────────────
-- Select text, press Space+y to copy to your Mac clipboard (pasteable in other apps).
map("v", "<leader>y", '"+y', { desc = "[Y]ank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "[Y]ank line to system clipboard" })

-- ─── Visual Mode: Code Action on Selection ─────────────────────────────────
-- Select code, then Space+ca for code actions on just the selection.
map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })

-- =============================================================================
-- 🚀 Pro-Tier Keybindings (Advanced QoL)
-- =============================================================================

-- ─── Better Start/End of Line ───────────────────────────────────────────────
-- Use H and L to jump to the start and end of a line instead of ^ and $
map({ "n", "v", "o" }, "H", "^", { desc = "Jump to start of line" })
map({ "n", "v", "o" }, "L", "$", { desc = "Jump to end of line" })

-- ─── Undo Breakpoints ───────────────────────────────────────────────────────
-- Add undo breakpoints when typing punctuation so `u` doesn't undo everything
local undo_chars = { ",", ".", ";", "!", "?" }
for _, char in ipairs(undo_chars) do
	map("i", char, char .. "<c-g>u", { desc = "Auto undo breakpoint" })
end

-- ─── Select All ─────────────────────────────────────────────────────────────
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- ─── Save Anywhere ──────────────────────────────────────────────────────────
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- ─── Ergonomic Split Resizing ───────────────────────────────────────────────
-- Resize splits with Alt + h/j/k/l
map("n", "<M-j>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<M-k>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
