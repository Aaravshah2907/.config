#!/bin/bash
# ~/.config/yazi/scripts/save_playlist.sh
PYTHON_SCRIPT="/Users/aaravshah2975/.config/yazi/scripts/music_queue.py"

clear
echo "💾 Save Current Playlist"
echo "------------------------"
read -p "Enter name (without .m3u): " name

if [ -n "$name" ]; then
    /opt/homebrew/bin/python3 "$PYTHON_SCRIPT" save "$name"
    echo "Playlist '$name' saved successfully."
    sleep 1
else
    echo "Cancelled."
    sleep 0.5
fi
