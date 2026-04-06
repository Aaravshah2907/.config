#!/bin/bash
# ~/.config/sketchybar/plugins/media_control.sh
ACTION=$1 # toggle, next, prev
YAZI_SCRIPT="/Users/aaravshah2975/.config/yazi/scripts/music_queue.py"

# If mpv-yazi is running, control it
if /opt/homebrew/bin/python3 "$YAZI_SCRIPT" status_json | grep -q '"running": true'; then
    /opt/homebrew/bin/python3 "$YAZI_SCRIPT" "$ACTION"
else
    # Otherwise, fallback to nowplaying-cli for system-wide media
    case "$ACTION" in
        "toggle") nowplaying-cli togglePlayPause ;;
        "next") nowplaying-cli next ;;
        "prev") nowplaying-cli previous ;;
    esac
fi

# Notify sketchybar to update its display
sketchybar --trigger media_change
