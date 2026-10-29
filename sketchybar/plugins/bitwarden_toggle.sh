#!/bin/bash

# Toggle Bitwarden: launch if not running, Cmd+H if frontmost, focus otherwise
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
elif [ "$(osascript -e 'tell app "System Events" to get name of first process whose frontmost is true')" = "$APP" ]; then
  osascript -e 'tell app "System Events" to keystroke "h" using command down'
else
  open -a "$APP"
fi
