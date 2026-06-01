#!/usr/bin/env sh

# Query the current space layout from Yabai
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

case "$LAYOUT" in
  bsp)
    ICON="󰕰"
    LABEL="BSP"
    COLOR=0xff00BFFF # SAPPHIRE
    ;;
  float)
    ICON="󰖲"
    LABEL="FLOAT"
    COLOR=0xffFFD700 # HONOR_GOLD
    ;;
  stack)
    ICON="󰖳"
    LABEL="STACK"
    COLOR=0xff8989ff # PURPLE
    ;;
  *)
    ICON="🛠️"
    LABEL="UNKNOWN"
    COLOR=0xffffffff
    ;;
esac

# Update the item
sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"
