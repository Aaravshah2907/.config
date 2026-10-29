#!/bin/bash

# Toggle Bitwarden: launch → show → hide cycle
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
else
  VISIBLE=$(osascript -e 'tell app "System Events" to get visible of process "Bitwarden"' 2>/dev/null)
  if [ "$VISIBLE" = "true" ]; then
    # Click the "Hide Bitwarden" menu item directly — no focus race
    osascript -e '
      tell app "Bitwarden" to activate
      delay 0.5
      tell app "System Events" to tell process "Bitwarden"
        click menu item "Hide Bitwarden" of menu "Bitwarden" of menu bar 1
      end tell
    '
  else
    open -a "$APP"
  fi
fi
