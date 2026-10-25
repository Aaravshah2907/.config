#!/usr/bin/env bash
# Toggle mpv windowless <-> windowed for the radiant-player IPC instance

SOCKET="/tmp/mpv-yazi.sock"

if [ ! -S "$SOCKET" ]; then exit 0; fi

CURRENT=$(echo '{"command": ["get_property", "force-window"]}' | socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null | jq -r '.data // false')

if [ "$CURRENT" == "true" ]; then
  # Switch back to windowless mode
  echo '{"command": ["set_property", "vid", "no"]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["set_property", "force-window", false]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["set_property", "border", false]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  sketchybar --set music.mpv_window icon="󰹙"
else
  # Capture active workspace before opening window
  CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)

  # Switch to windowed mode with album art, OSC controls, and window border
  echo '{"command": ["set_property", "force-window", true]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["set_property", "vid", "auto"]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["set_property", "border", true]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["script-message", "osc-visibility", "auto", "no-osd"]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  echo '{"command": ["show-progress"]}' | socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1

  sleep 0.3

  # AeroSpace integration: bring window to the active workspace as a tiled window so it is selectable
  WIN_ID=$(aerospace list-windows --all --format '%{window-id} %{app-name}' 2>/dev/null | awk '$2=="mpv"{print $1}')
  if [ -n "$WIN_ID" ]; then
    [ -n "$CURRENT_WS" ] && aerospace move-node-to-workspace --window-id "$WIN_ID" "$CURRENT_WS" 2>/dev/null
    aerospace layout --window-id "$WIN_ID" tiling 2>/dev/null
    aerospace focus --window-id "$WIN_ID" 2>/dev/null
  fi

  osascript -e 'tell application "System Events" to tell process "mpv" to set frontmost to true' 2>/dev/null
  sketchybar --set music.mpv_window icon="󱂬"
fi
