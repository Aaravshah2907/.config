#!/bin/bash

# Parses the INFO variable passed by sketchybar natively on space_windows_change.
# INFO contains a JSON object like {"space": 1, "apps": {"Spotify": 1, "Code": 1}}

if [ "$SENDER" = "space_windows_change" ]; then
  SPACE="$(echo "$INFO" | jq -r '.space')"
  APPS="$(echo "$INFO" | jq -r '.apps | keys[]')"
  
  ICON_STRIP=""
  
  if [ "$APPS" != "" ]; then
    while read -r APP; do
      # Source the generic icon map or fallback to a default app icon
      ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$APP" 2>/dev/null)
      if [ -z "$ICON" ]; then
        ICON="DefaultIcon" # Fallback if map missing
      fi
      ICON_STRIP+=" $ICON"
    done <<< "${APPS}"
  fi
  
  if [ -z "$ICON_STRIP" ]; then
    ICON_STRIP=" —"
  fi
  
  sketchybar --set space.$SPACE label="$ICON_STRIP"
fi
