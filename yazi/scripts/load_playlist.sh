#!/bin/bash
# ~/.config/yazi/scripts/load_playlist.sh

PLAYLIST_DIR="$HOME/.config/mpv/playlists"
PYTHON_SCRIPT="$HOME/.config/yazi/scripts/music_queue.py"

selected=$(ls "$PLAYLIST_DIR" | fzf --prompt="📂 Select Playlist > " --reverse --height=40% --border)

if [ -n "$selected" ]; then
    /opt/homebrew/bin/python3 "$PYTHON_SCRIPT" load "$selected"
    echo "Loaded $selected."
    sleep 0.3
fi
