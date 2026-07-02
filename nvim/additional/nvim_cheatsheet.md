# 🚀 Neovim Cheatsheet

Welcome to Neovim! This guide will help you transition from nano and learn the custom shortcuts configured in your setup.

## 🧠 The Most Important Concept: Modes

Unlike nano where typing always enters text, Neovim has **modes**.
1. **Normal Mode** (`Esc` or `jk`): Default mode. Used for navigating, copying, and deleting. Keys act as commands.
2. **Insert Mode** (`i`): Used for actually typing text.
3. **Visual Mode** (`v` or `V`): Used for selecting text (like holding Shift + Arrow keys).

---

## 🚪 Leaving Insert Mode
* **`jk`** - Escape Insert mode quickly without reaching for the `Esc` key (Custom mapping)
* **`Esc`** - Standard way to leave Insert mode

---

## 💾 Saving & Quitting (Leader = Space)
* **`Space w`** - Save file (like nano's `Ctrl+O`)
* **`Space q`** - Quit (like nano's `Ctrl+X`)
* **`Space x`** - Save and quit
* **`:q!`** - Force quit without saving (if you messed up)

---

## 🏃 Basic Movement (Normal Mode)
Instead of arrow keys, use the home row:
* **`h`** - Left
* **`j`** - Down
* **`k`** - Up
* **`l`** - Right
* **`w`** - Jump forward one word
* **`b`** - Jump backward one word
* **`0`** - Jump to start of line
* **`$`** - Jump to end of line
* **`gg`** - Go to top of file
* **`G`** - Go to bottom of file
* **`s`** - Flash: Jump to any visible text by typing 2 characters (Custom)
* **`S`** - Flash: Select a Treesitter text object (Custom)

---

## ✂️ Editing Text (Normal Mode)
* **`i`** - Insert before cursor
* **`a`** - Insert after cursor (Append)
* **`A`** - Jump to end of line and insert
* **`o`** - Open new line below and insert
* **`O`** - Open new line above and insert
* **`x`** - Delete character under cursor (like Delete key)
* **`dd`** - Delete entire line (like nano's `Ctrl+K`)
* **`D`** - Delete from cursor to end of line
* **`yy`** - Yank (copy) current line
* **`p`** - Paste (like nano's `Ctrl+U`)
* **`u`** - Undo
* **`Ctrl+r`** - Redo

**Smart Text Objects (mini.ai):**
*Combine these objects with actions like `d` (delete), `c` (change), `y` (yank), or `v` (visual).*
* **`a` (Argument):** `daa` (Delete An Argument - removes comma too), `cia` (Change Inside Argument)
* **`f` (Function call):** `daf` (Delete Around Function call), `cif` (Change Inside Function call arguments)
* **`q` (Quote):** `ciq` (Change Inside *any* Quote - auto-detects `'`, `"`, or `` ` ``)
* **`b` (Bracket):** `cib` (Change Inside *any* Bracket - auto-detects `()`, `[]`, or `{}`)
* **`t` (Tag):** `cit` (Change Inside HTML/XML Tag)
* **`g[` / `g]`** - Jump to the left/right edge of an object (e.g., `g]f` jumps to the end of the current function call)

---

## 🔎 Searching & Finding (Leader = Space)
* **`/`** - Search forward for a word (press `Enter` to jump)
* **`n`** - Go to next search result (Centers screen automatically)
* **`N`** - Go to previous search result (Centers screen automatically)
* **`Space /`** - Clear search highlights (Custom mapping)

**Telescope (Fuzzy Finder)**:
* **`Space ff`** - Find files by name (like VS Code `Ctrl+P`)
* **`Space fg`** - Find text in all files (grep)
* **`Space fr`** - Find recently opened files
* **`Space fb`** - Find in open buffers (tabs)
* **`Space fc`** - Fuzzy find within current file

---

## 🪟 Windows & Splits
* **`:vsp`** - Open vertical split
* **`:sp`** - Open horizontal split
* **`Ctrl+h/j/k/l`** - Jump between splits (Custom mapping)
* **`Ctrl+Arrow Keys`** - Resize splits (Custom mapping)

---

## 🗂️ Files & Buffers (Tabs)
* **`Space e`** - Open Yazi file manager at current file
* **`Space E`** - Open Yazi file manager at project root
* **`Space bn`** - Next buffer/tab
* **`Space bp`** - Previous buffer/tab
* **`Space bd`** - Close current buffer

---

## ⚓ Harpoon (Quick File Switching)
* **`Space ha`** - Add current file to Harpoon list
* **`Space hh`** - Open Harpoon menu
* **`Space 1..4`** - Jump directly to file 1, 2, 3, or 4 in your Harpoon list

---

## 💻 Coding Intelligence (LSP & Snippets)
* **`gd`** - Go to definition
* **`gD`** - Go to declaration
* **`gr`** - Go to references (opens Trouble panel)
* **`K`** - Hover documentation (see function signature/comments)
* **`Space ca`** - Code Action (quick fixes)
* **`Space rn`** - Rename variable everywhere
* **`Ctrl+Space`** - Trigger autocomplete menu
* **`Tab` / `Shift+Tab`** - Navigate autocomplete menu OR jump through snippet placeholders

**Dynamic Snippets (C++):**
* Type `for` + `Enter` - Generates a complete for-loop. Use `Tab` to jump between the iterator and limit.
* Type `bfs` + `Enter` - Generates a complete BFS queue template.
* Type `segtree` + `Enter` - Generates a complete Segment Tree struct.
* **`Space cf`** - Format file using Prettier/Clang-Format
* **`Space ds`** - List all symbols in current file
* **`Space ws`** - Search symbols across workspace
* **`[d` / `]d`** - Jump to previous/next error
* **`Space dl`** - Show diagnostic error details

---

## 🖥️ Terminal (Toggleterm)
* **`Ctrl+\`** - Toggle floating terminal
* **`Space tf`** - Floating terminal
* **`Space th`** - Horizontal split terminal
* **`Space tv`** - Vertical split terminal
* **`Space tg`** - Lazygit (full git TUI!)
* **`Esc` or `jk`** - Exit terminal mode back to Normal

---

## 🚨 Trouble (Problems Panel)
* **`Space xx`** - Toggle the Trouble panel
* **`Space xd`** - Diagnostics for current file only
* **`Space xw`** - Diagnostics across all open files
* **`Space xt`** - All TODOs across the project
* **`Space xq`** - Quickfix list

---

## ▶️ Code Runner (Competitive Programming)
* **`Space rc`** - Run current file (C++/Python/Java/JS)
* **`Space ri`** - Run with input from `input.txt` (CP mode!)
* **`Space rj`** - Run all test cases from CPOS `.samples.json` (shows PASS/FAIL, press `q` to close)
* **`Space rv`** - View the `.samples.json` test cases in a split
* **`Space rt`** - Toggle multi/single test case mode (comments out `cin >> T` for C++)
* **`Space re`** - Edit `input.txt` in the same directory

---

## 🐛 Debugger (DAP)
* **`Space db`** - Toggle breakpoint on current line
* **`Space dB`** - Conditional breakpoint (with expression)
* **`Space dc`** - Start / Continue debugging
* **`Space do`** - Step over
* **`Space di`** - Step into
* **`Space dO`** - Step out
* **`Space dt`** - Terminate debug session
* **`Space du`** - Toggle debugger UI
* **`Space de`** - Evaluate expression under cursor (works in Visual mode too)

---

## ✨ Visual Mode — Selecting & Acting on Text

Visual mode is how you **select text** in Neovim. Press `Space` in visual mode to see all available actions!

**Entering Visual Mode:**
* **`v`** - Character-wise selection (select individual characters)
* **`V`** - Line-wise selection (select whole lines — most common!)
* **`Ctrl+v`** - Block selection (select a rectangle of text)

**While in Visual Mode — Moving & Selecting:**
* **`j/k`** - Extend selection down/up
* **`w/b`** - Extend selection by word forward/backward
* **`gg`** - Extend selection to top of file
* **`G`** - Extend selection to bottom of file
* **`%`** - Extend to matching bracket `(){}[]`
* **`o`** - Jump cursor to other end of selection

**While in Visual Mode — Actions:**
* **`J` / `K`** - Move selected lines down/up (Custom)
* **`<` / `>`** - Indent/outdent (keeps selection active, Custom)
* **`Space p`** - Paste over selection without losing clipboard (Custom)
* **`Space y`** - Yank selection to **system clipboard** (pasteable in other apps, Custom)
* **`*` / `#`** - Search for selected text forward/backward (Custom)
* **`Space ss`** - Sort selected lines alphabetically (Custom)
* **`Space su`** - Sort + remove duplicates (Custom)
* **`Space ca`** - LSP Code Action on selection (Custom)
* **`gc`** - Toggle comment on selection
* **`S"`** - Surround selection with quotes (from nvim-surround, also works with `()`, `{}`, etc.)
* **`d`** - Delete selection
* **`y`** - Yank (copy) selection
* **`c`** - Change (delete + enter insert mode)
* **`u` / `U`** - Lowercase / uppercase selection

**Visual Mode — Git (in changed files):**
* **`Space gs`** - Stage only the selected lines (Custom)
* **`Space gr`** - Reset only the selected lines (Custom)

---

## 🪄 Other Custom Mappings (Normal Mode)
* **`Space Y`** - Yank current line to system clipboard (Custom)
* **`gcc`** - Toggle comment on current line
* **`ysiw"`** - Surround current word with quotes (from nvim-surround)
* **`ds"`** - Delete surrounding quotes
* **`cs"'`** - Change surrounding `"` to `'`

---

## 🧘 Zen Mode
* **`Space z`** - Toggle Zen Mode (centers code, dims everything else)

---

## 🎨 UI & Panels
* **`Space x x`** - Toggle Trouble panel (workspace errors)
* **`Space x d`** - Toggle Trouble panel (current file errors)
* **`Space a`** - Toggle Aerial Code Outline (shows macros, structs, and functions)
  * When Aerial is open, use `{` and `}` to quickly jump between functions
* **`Ctrl+w h/j/k/l`** - Move between split windows
* **`Ctrl+w v`** - Split window vertically
* **`Ctrl+w s`** - Split window horizontally
* **`Ctrl+w q`** - Close current split

---

## 🔀 Git (Advanced)
* **`Space gd`** - Side-by-side diff view of all changes
* **`Space gh`** - File history (current file)
* **`Space gH`** - Full repo history
* **`Space gc`** - Close diff view
* **`Space gp`** - Preview hunk
* **`Space gb`** - Blame current line
* **`Space gs`** - Stage hunk
* **`Space gr`** - Reset hunk
* **`]h` / `[h`** - Jump to next/previous git change

---

## 📓 Obsidian Notes Integration
* **`Space on`** - Create new note
* **`Space os`** - Search all notes
* **`Space od`** - Open today's daily note
* **`Space oo`** - Quick switch between notes
* **`Space of`** - Follow the link under cursor (Go to Definition)
* **`gf`** - Standard Vim command to 'Go to File' under cursor (works for links too!)
* **`gd`** - Standard LSP 'Go to Definition' (jumps to Markdown reference links)

---

## 🧩 CPKB Snippets
* **`Space cs`** - Search and insert competitive programming snippets from your CPKB library

> **Pro Tip**: Press `Space ?` anywhere in Neovim to open this cheatsheet again!
