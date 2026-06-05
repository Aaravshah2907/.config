#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"

# Get badges from common apps
MESSAGES_COUNT=$(osascript -e 'tell application "System Events" to tell process "Messages" to get badge label of UI element 1 of list 1 of application process "Dock"')
MAIL_COUNT=$(osascript -e 'tell application "System Events" to tell process "Mail" to get badge label of UI element 1 of list 1 of application process "Dock"')

# Handle empty or non-numeric results
[ "$MESSAGES_COUNT" = "missing value" ] && MESSAGES_COUNT=0
[ "$MAIL_COUNT" = "missing value" ] && MAIL_COUNT=0

TOTAL=$((MESSAGES_COUNT + MAIL_COUNT))

if [ "$TOTAL" -gt 0 ]; then
    COLOR=$AMBER
    ICON="󰂚"
    LABEL="$TOTAL"
else
    COLOR=$WHITE
    ICON="󰂚"
    LABEL=""
fi

/opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
