# Radiant Player

## Overview

Radiant Player is a terminal-native music player and queue manager for macOS that blends local audio playback with Spotify streaming. Inspired by the Stormlight Archive aesthetics, it offers a gemstone-themed UI, hybrid queues, and rich interactive controls.

## Features

- **Hybrid Queue**: Mix local files and Spotify tracks.
- **Terminal UI**: Bash/Python dashboard with a gemstone-inspired theme.
- **Spotify Integration**: Search and play Spotify directly from the terminal.
- **Interactive Controls**: Keyboard shortcuts for play, pause, skip, loop, shuffle, etc.
- **Album Art**: Render album art in the terminal via `chafa`.
- **Save/Load Queues**: Export/import playlists as `.rpl.json`.

## Requirements

- `python3`
- `mpv`
- `spotify_player` & `librespot`
- `jq`
- `fzf`
- `ffmpeg`
- `chafa`

Install dependencies with Homebrew:
```bash
brew install python mpv spotify_player librespot jq fzf ffmpeg chafa
```

## Setup & Installation

1. Clone or copy the repository to `~/.config/radiant-player/`.
2. Authenticate Spotify by running `spotify_player` once.
3. Verify the health of the setup:
```bash
python3 ~/.config/radiant-player/queue.py spotify_health
```
4. Start the dashboard:
```bash
~/.config/radiant-player/dashboard.sh
```

## Usage

Once `dashboard.sh` is running, use the **Surge Deck** (keyboard shortcuts) to navigate:

- **[↑/↓]**: Move cursor
- **[ENTER]**: Play selected track
- **[n/p]**: Next / Previous
- **[a]**: Search & Play Spotify Track
- **[P]**: Select Spotify Playlist
- **[l/s]**: Toggle Loop / Shuffle
- **[Ctrl+S / Ctrl+L]**: Save / Load Playlist
- **[q]**: Quit

## Integration

Radiant Player integrates smoothly with Yazi (via custom open rules) and Sketchybar (for menubar display of the current playing track).
