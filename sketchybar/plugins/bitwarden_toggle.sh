#!/bin/bash

# Toggle Bitwarden app: open if not running, activate if backgrounded, hide if frontmost
APP="Bitwarden"

if ! pgrep -xq "$APP"; then
  open -a "$APP"
elif [ "$(osascript -e "tell app \"System Events\" to get name of first process whose frontmost is true")" = "$APP" ]; then
  osascript -e "tell app \"$APP\" to set miniaturized of every window to true"
else
  open -a "$APP"
fi
