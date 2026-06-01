#!/bin/sh
source "$HOME/.config/sketchybar/colors.sh"

VOLUME="$INFO"

# Fallback to current volume if INFO is empty (manual trigger)
if [ -z "$VOLUME" ]; then
  VOLUME=$(osascript -e "output volume of (get volume settings)")
fi

case "$VOLUME" in
  [6-9][0-9]|100) ICON="󰕾"; COLOR="$EMERALD" ;;
  [3-5][0-9])     ICON="󰖀"; COLOR="$SAPPHIRE" ;;
  [1-9]|[1-2][0-9]) ICON="󰕿"; COLOR="$AMBER" ;;
  *)              ICON="󰖁"; COLOR="$RED" ;;
esac

# Update main item (Always show label)
/opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" drawing=on icon.color="$COLOR" label.color="$COLOR" label.drawing=on
