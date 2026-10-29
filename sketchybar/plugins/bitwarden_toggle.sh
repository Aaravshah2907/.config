#!/bin/bash

# Toggle Bitwarden: state file tracks show/hide since frontmost check is unreliable from sketchybar
STATE_FILE="/tmp/bitwarden_visible"
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
  touch "$STATE_FILE"
elif [ -f "$STATE_FILE" ]; then
  /usr/bin/osascript -e 'tell app "System Events" to set visible of process "Bitwarden" to false'
  rm -f "$STATE_FILE"
else
  open -a "$APP"
  touch "$STATE_FILE"
fi
