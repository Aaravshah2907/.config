# Tmux & Neovim Cheatsheet
**Prefix:** `Ctrl + b` (Press this before any standard Tmux command)
**No-prefix shell command:** `t <subcommand>` or `todo` (works from anywhere!)

---

## 🐚 Shell `t` Command & Helpers (Prefix-Free!)
| Command | Action |
| --- | --- |
| `todo` / `tux` | Open Tuxedo TUI in dedicated `Tuxedo` session (auto-kills on exit) |
| `t todo` / `t tux` | Dispatch Tuxedo session via `t` command center |
| `t` | Attach to last session (or create new default) |
| `t <name>` | Attach to session by name (creates if missing) |
| `t ls` | List all active sessions |
| `t new [name]` | Create a new named session |
| `t kill <name>` | Kill a specific session |
| `t kill-all` | Kill ALL sessions (server kill) |
| `t vs` | Split pane **vertically** (left/right) |
| `t hs` | Split pane **horizontally** (top/bottom) |
| `t win [name]` | Open a new window |
| `t wins` | List all windows in current session |
| `t next` | Switch to next window |
| `t prev` | Switch to previous window |
| `t float` | Open a floating popup shell |
| `t save` | Manually save session (resurrect) |
| `t restore` | Manually restore last saved session |
| `t cheat` | Show this cheatsheet |
| `chtm` | Interactive fuzzy search tmux cheatsheet (bat + fzf) |

---

## 📋 Session & Client Management
| Keybinding | Action |
| --- | --- |
| `Prefix + d` | **Detach** from current session (leaves background running) |
| `Prefix + D` | Choose client to detach interactively |
| `Prefix + s` | **Session tree**: Interactively switch between active sessions |
| `Prefix + $` | **Rename session** |
| `Prefix + (` | Switch to **previous session** |
| `Prefix + )` | Switch to **next session** |
| `Prefix + L` | Switch to the **last active session** |
| `Prefix + t` | Display digital clock in current pane |
| `Prefix + :` | Open Tmux **command prompt** (`:`) |
| `Prefix + ?` | Show keybindings / popup cheatsheet |
| `Prefix + ~` | Show Tmux message and window log history |
| `Prefix + o` | Visual switcher (**tmux-sessionx** with zoxide integration) |

---

## 🪟 Window Management (Tabs)
| Keybinding | Action |
| --- | --- |
| `Prefix + c` | **Create new window** |
| `Prefix + ,` | **Rename current window** |
| `Prefix + &` | **Kill / close current window** (prompts for confirmation) |
| `Prefix + n` | Select **next window** |
| `Prefix + p` | Select **previous window** |
| `Prefix + l` | Select **last active window** (toggle back and forth) |
| `Prefix + 1 .. 9` | Select window by number (1 through 9) |
| `Prefix + w` | Choose window from interactive tree |
| `Prefix + f` | Find / search window by text |
| `Prefix + .` | Move / renumber window index |
| `Prefix + '` | Select window by index prompt |

---

## ✂️ Pane Management (Splits)
| Keybinding | Action |
| --- | --- |
| `Prefix + \|` or `Prefix + %` or `Prefix + v` | **Split vertically** (left / right) |
| `Prefix + -` or `Prefix + "` or `Prefix + s` | **Split horizontally** (top / bottom) |
| `Prefix + x` | **Kill current pane** (prompts confirmation) |
| `Prefix + z` | **Zoom / unzoom current pane** (toggle full screen) |
| `Prefix + {` | Swap current pane with previous pane |
| `Prefix + }` | Swap current pane with next pane |
| `Prefix + q` | **Display pane numbers** (type number 1..9 to jump immediately) |
| `Prefix + !` | **Break pane out** into a new standalone window |
| `Prefix + ;` | Move to previously active pane |
| `Prefix + Space` | **Cycle pane layout presets** (even-horiz, even-vert, main-horiz, main-vert, tiled) |
| `Prefix + ↑ / ↓ / ← / →` | Select pane in specified direction |
| `Prefix + Alt + ↑ / ↓ / ← / →` | Resize active pane in steps of 5 cells |
| `Prefix + Ctrl + ↑ / ↓ / ← / →` | Resize active pane in steps of 1 cell |

---

## 🧭 Seamless Neovim ↔ Tmux Navigation
*No prefix required — works transparently across Neovim splits and Tmux panes!*
| Keybinding | Action |
| --- | --- |
| `Ctrl + h` | Focus Left (pane / vim split) |
| `Ctrl + j` | Focus Down (pane / vim split) |
| `Ctrl + k` | Focus Up (pane / vim split) |
| `Ctrl + l` | Focus Right (pane / vim split) |

---

## 📜 Copy Mode & Paste Buffers (Vi Keys)
| Keybinding | Action |
| --- | --- |
| `Prefix + [` | **Enter Copy / Scroll mode** |
| `Prefix + ]` | **Paste** most recently copied buffer |
| `Prefix + #` | List all paste buffers |
| `Prefix + =` | Interactively choose and paste from paste buffer history |
| `Prefix + -` | Delete top paste buffer |

### Inside Copy Mode (Vi Keymaps):
| Key | Action |
| --- | --- |
| `h` / `j` / `k` / `l` | Move cursor left, down, up, right |
| `w` / `b` / `e` | Word forward, backward, end of word |
| `0` / `^` / `$` | Start of line, first non-blank char, end of line |
| `g` / `G` | Jump to top of buffer / bottom of buffer |
| `Ctrl + u` / `Ctrl + d` | Scroll half-page Up / Down |
| `Ctrl + b` / `Ctrl + f` | Scroll full-page Up / Down |
| `/` / `?` | Search forward / Search backward |
| `n` / `N` | Next search match / Previous search match |
| `v` / `Space` | Begin character selection |
| `V` | Begin line selection |
| `y` / `Enter` | **Yank (copy) selection** and exit copy mode |
| `q` / `Esc` | Exit copy mode without copying |

---

## 💾 Persistence & Automated Session Recovery
| Command / Key | Action |
| --- | --- |
| `t save` | Manually save active layout and sessions (tmux-resurrect) |
| `t restore` | Manually restore last saved layout (tmux-resurrect) |
| `tmux-continuum` | Auto-saves session state every 15 minutes in background |

---

## 💻 Raw Native Tmux Commands (Shell Under the Hood)
| Command | Action |
| --- | --- |
| `tmux ls` | List active sessions |
| `tmux attach -t <name>` | Attach to a specific session |
| `tmux new -s <name>` | Create a new session |
| `tmux kill-session -t <name>` | Kill specific session |
| `tmux kill-server` | Kill entire tmux server and all sessions |
| `tmux source ~/.tmux.conf` | Reload configuration |
