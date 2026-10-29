#!/bin/bash

# Toggle Bitwarden: launch → show → hide cycle
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
else
  # Check if the app is currently visible
  VISIBLE=$(osascript -e 'tell app "System Events" to get visible of process "Bitwarden"' 2>/dev/null)
  if [ "$VISIBLE" = "true" ]; then
    # Bring to front then Cmd+H
    osascript -e '
      tell app "Bitwarden" to activate
      delay 0.3
      tell app "System Events" to keystroke "h" using command down
    '
  else
    open -a "$APP"
  fi
fi
