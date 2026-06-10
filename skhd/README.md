# Skhd Configuration

## Overview

Skhd is a simple hotkey daemon for macOS. This repository contains a customized keybinding configuration that provides window management, application launching, scratchpad toggles, and media controls integrated with Yabai and Sketchybar.

## Installation

```bash
# Install skhd via Homebrew
brew install koekeishiya/formulae/skhd
brew services start skhd   # Start skhd as a background service
```

Make sure to grant the necessary accessibility permissions:
1. Open **System Settings → Privacy & Security → Accessibility**.
2. Add the `skhd` binary (`/opt/homebrew/bin/skhd`).

Place the configuration files (`skhdrc`, scripts, etc.) in `~/.config/skhd/`.

## Usage

- The keybindings are defined in `skhdrc`. Reload the configuration with:
  ```bash
  skhd --restart
  ```
- Common shortcuts include:
  - `alt + h/j/k/l` – Focus windows in Yabai.
  - `shift + alt + r/y/x` – Rotate or mirror spaces.
  - `hyper + number` – Switch to specific spaces.
  - `hyper + shift + number` – Move windows to specific spaces.
  - `cmd + ctrl + alt + shift + return` – Toggle the iTerm scratchpad.
  - `cmd + ctrl + alt + shift + p` – Toggle VLC playback speed.

Edit `skhdrc` and the accompanying scripts to customize the behavior to your workflow.

## Contributing

Feel free to fork this repository and submit pull requests to add new shortcuts or improve existing scripts.
