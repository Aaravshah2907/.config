#!/bin/sh
source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾"; COLOR="$EMERALD" ;;
    [3-5][0-9])     ICON="󰖀"; COLOR="$SAPPHIRE" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿"; COLOR="$AMBER" ;;
    *)              ICON="󰖁"; COLOR="$RED" ;;
  esac

  if [ "$VOLUME" -ne 0 ]; then
    /opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" drawing=on icon.color="$COLOR" label.color="$COLOR"
  else
    /opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" drawing=on icon.color="$RED" label.drawing=off
  fi
fi
