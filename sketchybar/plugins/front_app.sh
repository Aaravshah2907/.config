#!/bin/sh
source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  /opt/homebrew/bin/sketchybar --set "$NAME" label="$INFO" label.color="$SAPPHIRE"
fi
