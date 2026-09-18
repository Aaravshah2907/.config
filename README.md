# 🌌 Dotfiles

A collection of configuration files and scripts for my macOS setup, featuring a custom terminal-based music player, window management, and status bar.

## 🌟 Highlights

*   **[Radiant Player](./radiant-player/README.md):** A custom, terminal-based hybrid music player and dashboard integrating Spotify and local MPV playback, styled with a unique "gemstone" aesthetic inspired by *The Stormlight Archive*.
*   **[Sketchybar](./sketchybar/README.md):** A minimalist, hover‑enabled status bar featuring a combined RAM & Disk monitor popup, interactive Bluetooth peek‑and‑pin, streamlined system stats, and elegant icons.
*   **[Yazi](./yazi/README.md):** A blazing fast terminal file manager configuration, tightly integrated with Radiant Player and a polished Cosmere flavor with custom file, folder, and fallback icons.
*   **Yabai & Skhd:** Tiling window management and hotkey daemon configurations for a keyboard-driven macOS experience.
*   **Neovim:** Custom Neovim setup with Cosmere-inspired theming, a live theme picker, nvim-tree project sidebar, and polished statusline/window UI.
*   **Spicetify:** Custom Spotify themes.

## 🛠️ Components

| Component | Description |
| :--- | :--- |
| [`radiant-player/`](./radiant-player/) | Terminal music dashboard, Spotify/MPV integration. |
| [`sketchybar/`](./sketchybar/) | Custom macOS menu bar replacement. |
| [`yazi/`](./yazi/) | Terminal file manager with custom music integrations and Cosmere-styled flavor/icons. |
| [`yabai/`](./yabai/) | Tiling window manager for macOS. |
| [`skhd/`](./skhd/) | Hotkey daemon for macOS. |
| [`nvim/`](./nvim/) | Neovim configuration with theme switching, nvim-tree, Lualine, Bufferline, and editor UI plugins. |
| [`iterm2/`](./iterm2/) | iTerm2 terminal configuration. |
| [`spicetify/`](./spicetify/) | Spotify client customization. |

## 📝 Recent Updates

The latest commits focus on editor and file-manager polish:

*   **Neovim themes:** Added a Themery-powered theme picker with live preview, light/dark options, and Cosmere-inspired presets such as Roshar Highstorm, Scadrial Ashfall, Taldain Dayside, Shadesmar, Elantris Glow, Nalthis BioChromatic, Selish Dor, and Silverlight.
*   **Neovim navigation:** Added `nvim-tree` as a persistent project sidebar alongside the existing Yazi workflow, with bindings for toggling, finding the current file, refreshing, and collapsing the tree.
*   **Neovim UI:** Refined Lualine, Bufferline, Incline, and related UI integrations so theme changes, project navigation, diagnostics, search counts, and LSP status are easier to scan.
*   **Yazi flavor:** Updated the Cosmere flavor with richer Nerd Font icons for named folders, file states, symlinks, executables, and regular files, plus a catch-all folder fallback so unrecognized directories stay visually consistent.

## 🚀 Installation

*Note: Since these are personal dotfiles, you might want to cherry-pick the configurations that interest you rather than copying everything blindly.*

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Aaravshah2907/.config.git ~/.config
    ```

2.  **Explore specific configurations:**
    Each major component (Radiant Player, Sketchybar, Yazi) has its own `README.md` with detailed installation instructions and dependencies. Please refer to them for specific setup guides.
