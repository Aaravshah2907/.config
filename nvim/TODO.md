# Neovim Setup — Feature Wishlist

Suggested improvements for the Neovim competitive programming + general editing setup.
Check off items as they get implemented.

---

## 🏆 High Impact — Competitive Programming

- [x] **Quick test-case toggle**
  - Keymap (e.g. `<Space>rt`) to toggle the `cin >> T` line between commented/uncommented
  - Instantly switch between single-test and multi-test mode without navigating to that line
  - Should work by scanning for the pattern in `main()` and toggling the comment

- [x] **Aerial.nvim**
  - Code outline window for viewing macros, structs, and functions.
  - `<Space>a` to toggle the outline.

- [x] **Dynamic Snippets (LuaSnip)**
  - Expands keywords into larger code blocks automatically (e.g. `for`, `bfs`, `segtree`)
  - Massively speeds up repetitive coding for competitive programming.

- [x] **Auto-compile on save**
  - On `:w` for `.cpp` files, compile in the background
  - Parse compiler errors and feed them into Neovim's diagnostics (Trouble panel)
  - No need to manually run — instant red squiggles on save
  - Should be non-blocking (async)

---

## ⚡ High Impact — General Editing

- [x] **flash.nvim** (or leap.nvim)
  - Ultra-fast cursor movement — jump anywhere on screen in 2-3 keystrokes
  - Press `s` + type 2 chars → labels appear → press label to jump
  - Much faster than repeated `w/b/f/t` motions
  - Plugin: `folke/flash.nvim`

- [x] **Harpoon**
  - Pin frequently-used files and switch between them instantly
  - `<Space>ha` — add current file to harpoon list
  - `<Space>1` / `<Space>2` / `<Space>3` / `<Space>4` — jump to pinned files
  - `<Space>hh` — open harpoon menu
  - Perfect for flipping between solution, brute, generator, and input
  - Plugin: `ThePrimeagen/harpoon` (branch: harpoon2)

- [x] **indent-blankline**
  - Show visual indent guides (thin vertical lines at each indent level)
  - Makes nested loops/ifs/blocks much easier to read
  - Highlight the current indent scope
  - Plugin: `lukas-reineke/indent-blankline.nvim`

---

## ✨ Nice to Have

- [x] **noice.nvim**
  - Replaces cmdline, messages, and notifications with a modern floating UI
  - Search (`/`) shows in a floating bar, messages appear as popups
  - Purely aesthetic but makes Neovim feel premium
  - Plugin: `folke/noice.nvim` (requires `MunifTanjim/nui.nvim`)

- [x] **mini.ai**
  - Enhanced text objects for editing
  - `daa` — delete an argument (including trailing comma)
  - `ciq` — change inside any quote type
  - `daf` — delete around function call
  - Much more expressive than default Vim text objects
  - Plugin: `echasnovski/mini.ai`

---

## Notes

- Implement items top-to-bottom for maximum workflow improvement
- Each item should get its own file in `lua/plugins/` to keep things modular
- Test each addition individually before moving on
