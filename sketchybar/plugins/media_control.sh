#!/bin/bash
# ~/.config/sketchybar/plugins/media_control.sh
ACTION=$1 # toggle, next, prev
YAZI_SCRIPT="/Users/aaravshah2975/.config/radiant-player/queue.py"

# Route controls to the hybrid queue first.
QUEUE_STATUS=$(/opt/homebrew/bin/python3 "$YAZI_SCRIPT" status_json 2>/dev/null)
if [ -n "$QUEUE_STATUS" ] && [ "$(echo "$QUEUE_STATUS" | /opt/homebrew/bin/jq -r '.running // false')" = "true" ]; then
    /opt/homebrew/bin/python3 "$YAZI_SCRIPT" "$ACTION" >/dev/null 2>&1
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
