#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# 1. Update selection state (background highlight)
# Map each space to a Radiant Order color
case "$NAME" in
  space.1) SPACE_COLOR=$SPREN_HONOR;;       # Honorspren (Terminal — wind & sky)     ;;
  space.2) SPACE_COLOR=$SPREN_INK;;         # Inkspren (Code — logic & precision)    ;;
  space.3) SPACE_COLOR=$SPREN_CULTIVATION;; # Cultivationspren (Browser — growth)   ;;
  space.4) SPACE_COLOR=$SPREN_SIBLING;;     # Sibling/Urithiru (Chat — crystal bond) ;;
  space.5) SPACE_COLOR=$SPREN_ASH;;         # Ashspren (Media — fire & entropy)     ;;
  space.6) SPACE_COLOR=$SPREN_PEAK;;        # Peakspren (Misc — stone endurance)    ;;
  space.7) SPACE_COLOR=$SPREN_WILL;;        # Willshaper (Spotify — freedom & song) ;;
  *)       SPACE_COLOR=$SPACE_ACCENT;;
esac
if [ -z "$SELECTED" ]; then
  SELECTED=$(sketchybar --query "$NAME" | jq -r '.selected')
fi
# Highlight handled by separate bracket (removed old border logic)

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
    # sketchybar --set "space.highlight.$SPACE" drawing=on
  else
    sketchybar --set "space.$SPACE" label="—" label.drawing=off icon.color=$WHITE background.drawing=off
    # sketchybar --set "space.highlight.$SPACE" drawing=off
  fi
else
    # Occupied Space
  if [ "$SELECTED" = "true" ]; then
    sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$SPACE_COLOR label.color=$SPACE_COLOR background.drawing=off background.color=$BAR_COLOR
    #sketchybar --set "space.highlight.$SPACE" drawing=on
  else
    sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$SPACE_COLOR label.color=$SPACE_COLOR background.drawing=off background.drawing=off
    #sketchybar --set "space.highlight.$SPACE" drawing=off
  fi
fi
