# Radiant Player

A terminal-native, hybrid local and Spotify music player and queue manager for macOS, heavily inspired by the aesthetics and themes of Brandon Sanderson's *The Stormlight Archive*.

## Features

- **Hybrid Queue**: Seamlessly mix local audio files and Spotify tracks in a single unified queue.
- **Terminal UI**: A beautiful, gemstone-themed dashboard built purely in Bash and Python (`dashboard.sh`).
- **Spotify Integration**: Search and play Spotify tracks and playlists directly from the terminal without using the heavy desktop app.
- **Interactive Controls**: Move, delete, skip, and pause tracks via keyboard shortcuts.
- **Album Art**: Terminal-based album art rendering using `chafa`.
- **Save/Load Queues**: Save your current hybrid queue to `.rpl.json` playlists and load them later.
- **Stormlight Theme**: Custom color palettes based on Rosharan gemstones, ideals, and Surgebinding.

## Requirements

Ensure you have the following dependencies installed on your macOS system:

- `python3` (Core queue management and logic)
- `mpv` (For local file playback)
- `spotify_player` & `librespot` (For Spotify integration)
- `jq` (JSON parsing)
- `fzf` (Fuzzy finding for interactive menus)
- `ffmpeg` (For extracting album art from local files)
- `chafa` (For rendering album art in the terminal)

You can install most of these via Homebrew:
```bash
brew install python mpv spotify_player librespot jq fzf ffmpeg chafa
```

## Setup & Installation

1. **Clone/Copy** this directory to `~/.config/radiant-player/`.
2. **Authenticate Spotify**: Run `spotify_player` in your terminal once to complete the first-run authentication, then quit.
3. **Verify Tool Health**: Run the health check to ensure dependencies are found:
   ```bash
   python3 ~/.config/radiant-player/queue.py spotify_health
   ```
4. **Run the Dashboard**: Start the interface by running:
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
