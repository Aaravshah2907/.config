#!/bin/sh
source "$HOME/.config/sketchybar/colors.sh"

# Hover Expansion
if [ "$SENDER" = "mouse.entered" ]; then
  /opt/homebrew/bin/sketchybar --animate circ 20 --set volume_slider slider.width=100
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  # Wait a bit before collapsing to allow moving mouse to slider
  sleep 1
  # Check if mouse is still in the neighborhood (optional, usually handled by slider's own exit)
  /opt/homebrew/bin/sketchybar --animate circ 20 --set volume_slider slider.width=0
  exit 0
fi

if [ "$SENDER" = "volume_change" ]; then
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

  # Sync slider
  /opt/homebrew/bin/sketchybar --set volume_slider slider.percentage="$VOLUME"
fi
