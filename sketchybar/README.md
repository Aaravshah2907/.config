# Sketchybar Configuration

My custom "Radiant Floating Bar" configuration for [Sketchybar](https://github.com/FelixKratz/SketchyBar) on macOS. It replaces the default macOS menu bar with a highly customizable, floating, theme-consistent alternative.

## Features

- **Radiant Theme**: Styled with a dark "Deep Night" background, translucent borders, and custom Rosharan/Stormlight-inspired color palette.
- **Dynamic Workspaces**: Integrates with `yabai` (or macOS native spaces) to show active and inactive spaces.
- **Music Integration**: "The Radiant Song" module seamlessly displays currently playing music from the `radiant-player` and Spotify, complete with interactive play/pause controls.
- **System Monitor (RAM & Disk Hover Popup)**: Displays a clean monitor icon (`󰍹`) on the bar which reveals detailed RAM pressure ("Investiture") and Disk usage ("Material World") in a popup when hovered.
- **Interactive Bluetooth Module**: Supports mouse-hover peek to list connected devices, with a click-to-pin feature that keeps the popup open until clicked again.
- **Auto-Hiding/Floating**: Designed to float slightly below the screen edge with rounded corners and blurred backgrounds.

## Requirements

- `sketchybar`
- **Nerd Fonts**: Requires both `Hack Nerd Font` and `JetBrainsMono Nerd Font` for the icons and text styling to render correctly.
- `jq` (For parsing JSON data in scripts)
- `blueutil` (For displaying Bluetooth device names)
- macOS tools (Uses `pmset`, `networksetup`, etc. natively)

Install core dependencies via Homebrew:
```bash
brew tap FelixKratz/formulae
brew install sketchybar jq blueutil
brew install --cask font-hack-nerd-font font-jetbrains-mono-nerd-font
```

## Installation

1. Clone or copy this directory to `~/.config/sketchybar/`.
2. Ensure all scripts in `~/.config/sketchybar/plugins/` are executable:
   ```bash
   chmod +x ~/.config/sketchybar/plugins/*.sh
   ```
3. Start or restart the sketchybar service:
   ```bash
   brew services start sketchybar
   # or if already running
   sketchybar --reload
   ```

## Structure

- `sketchybarrc`: The main configuration file defining the bar layout, items, and brackets.
- `colors.sh`: Defines the global color palette (Stormlight inspired).
- `plugins/`: Contains the bash scripts that drive the logic for battery, clock, music, volume, and spaces.
