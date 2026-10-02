#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

TITLE=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)
APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)

if [ -z "$APP" ] && [ -z "$TITLE" ]; then
  # No active window focused or desktop is selected
  sketchybar --set "$NAME" label="" drawing=off
  exit 0
fi

# Fallback to app name if window has no title
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  TITLE="$APP"
fi

# Truncate title if it's too long
MAX_LEN=40
if [ ${#TITLE} -gt $MAX_LEN ]; then
  TRUNCATED="${TITLE:0:$MAX_LEN}..."
else
  TRUNCATED="$TITLE"
fi

sketchybar --set "$NAME" label=" $TRUNCATED" drawing=on label.color="$SAPPHIRE"
