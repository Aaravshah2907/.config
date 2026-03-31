#!/usr/bin/env bash

# Query current space layout from yabai
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

case "$LAYOUT" in
  bsp)
    ICON="󰕪" # Tiled icon
    ;;
  stack)
    ICON="󰓫" # Stacked icon
    ;;
  float)
    ICON="󰉨" # Floating icon
    ;;
  *)
    ICON="󱂬" # Default
    ;;
esac

sketchybar --set $NAME icon="$ICON"
