# Yazi Configuration

My custom configuration for [Yazi](https://github.com/sxyazi/yazi), a blazing fast terminal file manager written in Rust.

## Features

- **Dracula Theme**: Consistent and beautiful styling using the `dracula` flavor.
- **Radiant Player Integration**: Custom opener rules to instantly send audio files (`.mp3`, `.flac`, etc.) or `.spot`/`.spotify` pointer files directly to the `radiant-player` queue.
- **Enhanced Previews**: Rich file previews for images, videos, audio, and git repositories directly in the terminal.
- **Custom Keybindings**: Highly customized `keymap.toml` for efficient navigation and file manipulation.

## Plugins Used

- `chmod`
- `simple-tag`
- `preview-git`
- `spot` / `spot-audio` / `spot-video`

## Requirements

- `yazi` (The file manager itself)
- `ya` (Yazi's command-line tool for package management)
- `ffmpegthumbnailer` / `ffmpeg` (For video previews)
- `imagemagick` / `chafa` (For image previews, depending on terminal support)
- `poppler` (For PDF previews)
- `exiftool` (For media info)

You can install the core tools via Homebrew:
```bash
brew install yazi ffmpegthumbnailer imagemagick poppler exiftool
```

## Installation

1. Copy this directory to `~/.config/yazi/`.
2. Install the defined plugins and flavors using the `ya` package manager:
   ```bash
   ya pack -i
   ```

## Integrations

- **VLC**: Video files (`.mp4`, `.mkv`) are configured to open in VLC via macOS `open -a "VLC"`.
- **Radiant Player**: Pressing enter on an audio file or `.m3u` playlist will automatically hand off the playback to the `radiant-player` backend.
