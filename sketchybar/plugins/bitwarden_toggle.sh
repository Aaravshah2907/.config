#!/bin/bash

# Toggle Bitwarden: state file tracks show/hide
STATE_FILE="/tmp/bitwarden_visible"
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
  touch "$STATE_FILE"
elif [ -f "$STATE_FILE" ]; then
  # Hide: activate in background, wait for focus, then Cmd+H
  (
    /usr/bin/osascript -e 'tell app "Bitwarden" to activate'
    sleep 0.5
    /usr/bin/osascript -e 'tell app "System Events" to keystroke "h" using command down'
  ) &
  rm -f "$STATE_FILE"
else
  open -a "$APP"
  touch "$STATE_FILE"
fi
