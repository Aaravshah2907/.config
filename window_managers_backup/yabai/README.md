# Yabai Configuration

## Overview

Yabai is a powerful tiling window manager for macOS. This repository contains a customized configuration that sets up a bsp layout, defines spacing, gaps, and integrates with Sketchybar for status bar updates.

## Installation

```bash
# Ensure you have Homebrew installed
brew install koekeishiya/formulae/yabai
brew services start yabai   # Start yabai as a background service
```

You may need to grant the required accessibility permissions:
1. Open **System Settings → Privacy & Security → Accessibility**.
2. Add the `yabai` binary (`/opt/homebrew/bin/yabai`).

## Usage

Place the configuration files in `~/.config/yabai/` and reload yabai:

```bash
brew services restart yabai
# or
yabai --restart  # if running manually
```

The `yabairc` script sets up:
- bsp layout and window placement
- auto‑balance and split ratios
- mouse behavior and gaps
- space labeling and routing rules
- signals to trigger Sketchybar updates

Edit `yabairc` to customize layouts, keybindings, or space assignments.

## Contributing

Feel free to fork this repo and submit pull requests with enhancements or bug fixes.
