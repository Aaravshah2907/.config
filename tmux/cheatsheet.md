# Tmux & Neovim Cheatsheet
**Prefix:** `Ctrl + b` (Press this before any Tmux command)
**No-prefix shell command:** `t <subcommand>` (works from anywhere!)

---

## 🐚 Shell `t` Command (Prefix-Free!)
| Command | Action |
| --- | --- |
| `t` | Attach to last session (or create one) |
| `t <name>` | Attach to session by name (creates if missing) |
| `t ls` | List all active sessions |
| `t new [name]` | Create a new named session |
| `t kill <name>` | Kill a specific session |
| `t kill-all` | Kill ALL sessions |
| `t vs` | Split pane **vertically** (left/right) |
| `t hs` | Split pane **horizontally** (top/bottom) |
| `t win [name]` | Open a new window |
| `t wins` | List all windows in current session |
| `t next` | Switch to next window |
| `t prev` | Switch to previous window |
| `t float` | Open a floating popup shell |
| `t save` | Manually save session (resurrect) |
| `t restore` | Manually restore last saved session |
| `t cheat` | **Show this cheatsheet** |

---

## 🛠️ Terminal Tools (Shell-Level)
| Command | Action |
| --- | --- |
| `t -h` / `ts -h` | Inline usage summary for `t` |
| `t cheat` / `tmux-help` | Full cheatsheet |
| `fv` | Open Yazi file manager (cds on exit) |
| `mux landing` | Launch dashboard Tmuxinator layout |
| `mux dev` | Launch dev Tmuxinator layout |

---

## 🌍 Shell Environment (direnv + fzf-tab)
| Command | Action |
| --- | --- |
| `TAB` after any command | Interactive fuzzy completion (fzf-tab) |
| `echo 'source .venv/bin/activate' > .envrc && direnv allow` | Auto-activate venv in a project |
| `direnv allow` | Trust a new/updated `.envrc` file |
| `direnv deny` | Revoke trust for current directory |

---

## 🧭 Navigation (Seamless Neovim ↔ Tmux)
| Command | Action |
| --- | --- |
| `Ctrl + h` | Focus Left |
| `Ctrl + j` | Focus Down |
| `Ctrl + k` | Focus Up |
| `Ctrl + l` | Focus Right |

---

## 🪟 Window Management (Tabs)
| Command | Action |
| --- | --- |
| `Prefix + c` | Create new window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + 1..9` | Go to window 1..9 |
| `Prefix + ,` | Rename current window |
| `Prefix + w` | List all windows (Interactive) |

---

## ✂️ Pane Management (Splits)
| Command | Action |
| --- | --- |
| `Prefix + v` | Split Vertically (Left/Right) |
| `Prefix + -` | Split Horizontally (Top/Bottom) |
| `Prefix + x` | Close current pane |
| `Prefix + z` | Zoom/unzoom current pane |
| `Prefix + {` / `}` | Swap pane left / right |

---

## 📋 Session Management
| Command | Action |
| --- | --- |
| `Prefix + d` | Detach (leave session running in bg) |
| `Prefix + s` | List sessions (Interactive) |
| `Prefix + o` | Visual switcher (tmux-sessionx) |
| `mux <name>` | Launch Tmuxinator template |

---

## 💾 Persistence (Auto-saves every 15 min)
| Command | Action |
| --- | --- |
| `t save` | Manually save layout now |
| `t restore` | Manually restore last layout |

---

## ❓ Help & Reference
| Command | Action |
| --- | --- |
| `t -h` | Inline usage summary (quick!) |
| `t cheat` | Full cheatsheet (this file, via bat) |
| `t guide` | Full Tmux guide & concepts |
| `tmux-help` | Alias — same as `t cheat` |
| `Prefix + ?` | Show cheatsheet in floating Tmux popup |
| `Prefix + :` | Tmux command prompt |
