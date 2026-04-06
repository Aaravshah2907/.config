#!/bin/bash
# ~/.config/yazi/scripts/load_playlist.sh
PLAYLIST_DIR="/Users/aaravshah2975/.config/mpv/playlists"
PYTHON_SCRIPT="/Users/aaravshah2975/.config/yazi/scripts/music_queue.py"

# Select playlist using fzf
selected=$(/bin/ls "$PLAYLIST_DIR" | fzf --prompt="📂 Select Playlist > " --reverse --height=40% --border)

if [ -n "$selected" ]; then
    /opt/homebrew/bin/python3 "$PYTHON_SCRIPT" load "$selected"
    echo "Loaded $selected."
    sleep 0.5
fi
