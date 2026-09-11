# 🌀 Tmux Guide — The Complete Reference

> Tmux = **Terminal Multiplexer**. One terminal window → infinite sessions, windows, and panes.
> Think of it like a tiling window manager *inside* your terminal.

---

## 🧠 Mental Model

```
Server  (runs silently in background, survives terminal close)
└── Session  "dev"          ← a project / context
    ├── Window 0: "editor"  ← a tab
    │   ├── Pane (left): nvim
    │   └── Pane (right): shell
    └── Window 1: "logs"
        └── Pane: tail -f app.log

Session  "music"
└── Window 0: "radiant-player"
```

Key insight: **Sessions survive closing your terminal.** `t dev` brings it all back.

---

## 🚀 Quick Start (Your Workflow)

```bash
# Open Ghostty → you're in shell
t dev           # jump into your dev session (creates it if needed)

# Inside Tmux:
t vs            # split right pane
t hs            # split bottom pane
t win logs      # open new "logs" tab
t float         # floating shell overlay for quick one-off commands

# Navigate panes with Ctrl+h/j/k/l (works across Neovim splits too!)
```

---

## 📚 Core Concepts

### Sessions
A session is an isolated workspace. You can have many running simultaneously.

| Action | Command |
|--------|---------|
| Create | `t new <name>` or `t <name>` |
| List | `t ls` |
| Attach | `t <name>` |
| Detach (keep alive) | `Ctrl+b d` |
| Kill | `t kill <name>` |

> **Tip:** Name sessions after projects: `t tracker`, `t physics-kb`, `t dotfiles`

---

### Windows (Tabs)
Within a session, windows are like browser tabs — each has its own layout of panes.

| Action | Keyboard | Shell |
|--------|----------|-------|
| New window | `Ctrl+b c` | `t win [name]` |
| Next window | `Ctrl+b n` | `t next` |
| Prev window | `Ctrl+b p` | `t prev` |
| List windows | `Ctrl+b w` | `t wins` |
| Rename window | `Ctrl+b ,` | — |
| Go to window N | `Ctrl+b 1..9` | — |

---

### Panes (Splits)
Windows are split into panes. Each pane is an independent shell.

| Action | Keyboard | Shell |
|--------|----------|-------|
| Split right | `Ctrl+b v` | `t vs` |
| Split down | `Ctrl+b -` | `t hs` |
| Close pane | `Ctrl+b x` | — |
| Zoom pane | `Ctrl+b z` | — |
| Move pane | `Ctrl+b {` / `}` | — |
| Navigate pane | `Ctrl+h/j/k/l` | — (smart-splits!) |

> **Tip:** `Ctrl+b z` is like "fullscreen toggle" for a pane. Very useful when running nvim.

---

### Floating Popup
Press `t float` (or `Ctrl+b space`) to get a floating overlay shell — great for quick lookups, running a command, or checking docs without leaving your current layout.

---

## 💡 Power Workflows

### The Dev Setup
```bash
t dev                    # attach to dev session
t win nvim               # window 1: editor
t vs                     # split → right side for shell
t win logs               # window 2: logs
tail -f ~/.local/share/app.log
# Ctrl+b 1 → back to editor
```

### Using Tmuxinator Templates
```bash
mux landing              # 3-pane dashboard: btop + fastfetch
mux dev                  # nvim + shell, ready to go
mux new <name>           # create a new named template
```

### Session Persistence (Auto)
Sessions are **auto-saved every 15 minutes** by tmux-continuum.

After a reboot, just open Ghostty — tmux-resurrect will restore your layout automatically.

Manual control:
```bash
t save                   # save right now
t restore                # restore last saved state
```

---

## 🔌 Plugins Installed

| Plugin | What It Does |
|--------|-------------|
| `tmux-sessionx` | Visual session switcher — `Ctrl+b o` |
| `tmux-resurrect` | Save/restore sessions across reboots |
| `tmux-continuum` | Auto-saves resurrect state every 15 min |
| `tpm` | Plugin manager (manages the above) |

---

## 🧭 Navigation (Neovim ↔ Tmux Seamless)

You use `smart-splits.nvim` configured with Tmux integration. This means:
- `Ctrl+h/j/k/l` navigates **both** Neovim splits **and** Tmux panes
- Hitting the edge of Neovim automatically focuses the adjacent Tmux pane

No more `Ctrl+b arrow` for pane switching — just `Ctrl+h/j/k/l` everywhere.

---

## 🎯 Cheatsheet Access

| Where | How |
|-------|-----|
| Shell (anywhere) | `t cheat` or `tmux-help` |
| Inside Tmux | `Ctrl+b ?` (popup) |
| This guide | `t guide` |
| Inline help | `t -h` |

