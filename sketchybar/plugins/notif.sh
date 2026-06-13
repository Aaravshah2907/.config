#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Handle hover for notifications widget
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# Get badges from common apps
MESSAGES_COUNT=$(osascript -e 'tell application "System Events" to tell process "Messages" to get badge label of UI element 1 of list 1 of application process "Dock"')
MAIL_COUNT=$(osascript -e 'tell application "System Events" to tell process "Mail" to get badge label of UI element 1 of list 1 of application process "Dock"')

# Handle empty or non-numeric results
[ "$MESSAGES_COUNT" = "missing value" ] && MESSAGES_COUNT=0
[ "$MAIL_COUNT" = "missing value" ] && MAIL_COUNT=0

TOTAL=$((MESSAGES_COUNT + MAIL_COUNT))

if [ "$TOTAL" -gt 5 ]; then
    COLOR=$RUIN_MAROON                   # Ruin's grip — overwhelming notifications
    ICON="󰀦" # Angerspren (Ruin-touched alert)
elif [ "$TOTAL" -gt 0 ]; then
    COLOR=$NOTIF_ACCENT                  # Gloryspren gold — attention without alarm
    ICON="󰓎" # Gloryspren (gold orb of joy)
else
    COLOR=$PRES_MIST                     # Preservation mist — calm, clear
    ICON="󰖝" # Windspren (Wind wave / Calm)
fi

# Update popup items
sketchybar --set notif.messages label="Messages: $MESSAGES_COUNT"
sketchybar --set notif.mail label="Mail: $MAIL_COUNT"

# Update main bar icon
/opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off
