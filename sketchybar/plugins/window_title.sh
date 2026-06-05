#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"

WINDOW_INFO=$(yabai -m query --windows --window 2>/dev/null)

if [ -z "$WINDOW_INFO" ] || [ "$WINDOW_INFO" = "null" ]; then
  # No active window focused or desktop is selected
  sketchybar --set "$NAME" label="" drawing=off
  exit 0
fi

TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')
APP=$(echo "$WINDOW_INFO" | jq -r '.app')

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
