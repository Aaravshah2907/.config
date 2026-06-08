#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

# 1. Update selection state (background highlight)
# Map each space to a Radiant Order color
case "$NAME" in
  space.1) SPACE_COLOR=$SAPPHIRE;;   # Windrunner (Terminal)   ;;
  space.2) SPACE_COLOR=$PURPLE;;    # Elsecaller (Code)        ;;
  space.3) SPACE_COLOR=$EMERALD;;   # Edgedancer (Browser)    ;;
  space.4) SPACE_COLOR=$HONOR_GOLD;; # Bondsmith (Chat)        ;;
  space.5) SPACE_COLOR=$AMBER;;    # Lightweaver (Media)     ;;
  space.6) SPACE_COLOR=$SLATE;;    # Additional space (Utility) ;;
  space.7) SPACE_COLOR=$PURPLE;;    # Spotify (Music)        ;;
  *)      SPACE_COLOR=$ACCENT_COLOR;;
esac
if [ -z "$SELECTED" ]; then
  SELECTED=$(sketchybar --query "$NAME" | jq -r '.selected')
fi
if [ "$SELECTED" = "true" ]; then
   # Active space: box outline with space color
   sketchybar --set "$NAME" background.drawing=off label.color=$SPACE_COLOR icon.color=$SPACE_COLOR border.drawing=on border.color=$SPACE_COLOR border.width=2
else
   # Inactive space: plain label with space color
   sketchybar --set "$NAME" background.drawing=off label.color=$SPACE_COLOR icon.color=$SPACE_COLOR
fi

# 2. Compute icons for this space (unconditional)
# Derive space number from the item name
SPACE="${NAME#space.}"
# Get list of apps in the space via yabai
APPS=$(yabai -m query --windows --space "$SPACE" | jq -r '.[].app' | sort -u)
ICON_STRIP=""
if [ -n "$APPS" ]; then
  while read -r APP; do
      # Fetch icon from map
    ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$APP" 2>/dev/null)
    [ -z "$ICON" ] && ICON="󰀱"
    ICON_STRIP+=" $ICON"
  done <<< "$APPS"
fi

# Check if space is fullscreen (native or zoomed)
IS_FULLSCREEN="false"
SPACE_JSON=$(yabai -m query --spaces --space "$SPACE" 2>/dev/null)
if [ -n "$SPACE_JSON" ] && [ "$SPACE_JSON" != "null" ]; then
  NATIVE_FS=$(echo "$SPACE_JSON" | jq -r '.is-native-fullscreen')
  if [ "$NATIVE_FS" = "true" ]; then
    IS_FULLSCREEN="true"
  else
      # Check zoomed windows
    WINDOWS_JSON=$(yabai -m query --windows --space "$SPACE" 2>/dev/null)
    if [ -n "$WINDOWS_JSON" ] && [ "$WINDOWS_JSON" != "null" ] && [ "$WINDOWS_JSON" != "[]" ]; then
      ZOOMED_FS=$(echo "$WINDOWS_JSON" | jq -r 'any(.[]; ."has-fullscreen-zoom" == true)')
      if [ "$ZOOMED_FS" = "true" ]; then
        IS_FULLSCREEN="true"
      fi
    fi
  fi
fi

if [ "$IS_FULLSCREEN" = "true" ]; then
  ICON_STRIP="󰊓$ICON_STRIP"
fi

# Apply occupied/unoccupied styling based on whether windows exist
if [ -z "$ICON_STRIP" ]; then
    # Unoccupied Space
  if [ "$SELECTED" = "true" ]; then
    sketchybar --set "space.$SPACE" label="—" label.drawing=off icon.color=$WHITE background.drawing=on background.color=$BAR_COLOR background.border_color=$SPACE_COLOR background.border_width=2 background.corner_radius=6 background.height=42
  else
    sketchybar --set "space.$SPACE" label="—" label.drawing=off icon.color=$WHITE background.drawing=off
  fi
else
    # Occupied Space
  if [ "$SELECTED" = "true" ]; then
    sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$SPACE_COLOR label.color=$SPACE_COLOR background.drawing=on background.color=$BAR_COLOR background.border_color=$SPACE_COLOR background.border_width=2 background.corner_radius=6 background.height=42
  else
    sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$SPACE_COLOR label.color=$SPACE_COLOR background.drawing=off background.drawing=off
  fi
fi
