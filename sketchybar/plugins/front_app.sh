#!/bin/sh
source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$INFO" 2>/dev/null)
  [ -z "$ICON" ] && ICON="󰀱"
  /opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$INFO" icon.color="$SAPPHIRE" label.color="$SAPPHIRE"
fi
