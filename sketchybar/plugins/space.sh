#!/bin/bash

# Loads all defined colors
source "$HOME/.config/sketchybar/colors.sh"

# 1. Update selection state (background highlight)
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=$ACCENT_COLOR \
                           label.color=$ITEM_BG_COLOR \
                           icon.color=$ITEM_BG_COLOR
else
  sketchybar --set "$NAME" background.drawing=off \
                           label.color=$WHITE \
                           icon.color=$WHITE
fi

# 2. Update window icons if the sender is space_windows_change
# INFO contains {"space": 1, "apps": {"Spotify": 1, "Code": 1}}
if [ "$SENDER" = "space_windows_change" ]; then
  SPACE="$(echo "$INFO" | jq -r '.space')"
  APPS="$(echo "$INFO" | jq -r '.apps | keys[]')"
  
  ICON_STRIP=""
  if [ "$APPS" != "" ]; then
    while read -r APP; do
      # Fetch icon from map
      ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$APP" 2>/dev/null)
      [ -z "$ICON" ] && ICON="󰀱"
      ICON_STRIP+=" $ICON"
    done <<< "${APPS}"
  fi
  
  [ -z "$ICON_STRIP" ] && ICON_STRIP=" —"
  
  # Set label for the current space invoking the change
  sketchybar --set "space.$SPACE" label="$ICON_STRIP"
fi
