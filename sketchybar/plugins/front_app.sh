#!/bin/sh
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$INFO" 2>/dev/null)
  [ -z "$ICON" ] && ICON="󰀱"
  /opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$INFO" icon.color="$FRONTAPP_ACCENT" label.color="$FRONTAPP_ACCENT"
fi
