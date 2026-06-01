#!/bin/bash

YAZI_SCRIPT="/Users/aaravshah2975/.config/radiant-player/queue.py"

# Check if Radiant Player is running
MPV_STATUS=$(python3 "$YAZI_SCRIPT" status_json 2>/dev/null)
if [[ -n "$MPV_STATUS" && $(echo "$MPV_STATUS" | jq -r '.running') == "true" ]]; then
  # If Radiant Player is running, focus the terminal app hosting the dashboard
  if pgrep -x "iTerm2" >/dev/null || pgrep -f "iTerm" >/dev/null; then
    open -a "iTerm"
  elif pgrep -x "Terminal" >/dev/null; then
    open -a "Terminal"
  else
    # Launch dashboard in terminal if not currently in a known host
    osascript -e 'tell application "Terminal" to do script "~/.config/radiant-player/dashboard.sh"' 2>/dev/null
    open -a "Terminal"
  fi
else
  # Default to launching/focusing Spotify
  open -a Spotify
fi
