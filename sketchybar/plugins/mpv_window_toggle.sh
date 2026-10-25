#!/usr/bin/env bash
# Toggle mpv windowless <-> windowed for the radiant-player IPC instance

SOCKET="/tmp/mpv-yazi.sock"

if [ ! -S "$SOCKET" ]; then exit 0; fi

CURRENT=$(echo '{"command": ["get_property", "force-window"]}' | socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null | jq -r '.data // false')

if [ "$CURRENT" == "true" ]; then
  echo '{"command": ["set_property", "force-window", false]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  sketchybar --set music.mpv_window icon="󰹙"
else
  echo '{"command": ["set_property", "force-window", true]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  # Bring the window to front after opening
  sleep 0.3
  osascript -e 'tell application "System Events" to tell process "mpv" to set frontmost to true' 2>/dev/null
  sketchybar --set music.mpv_window icon="󱂬"
fi
