#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

# 1. Update selection state (background highlight)
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=$ACCENT_COLOR \
                           label.color=$ITEM_BG_COLOR \
                           icon.color=$ITEM_BG_COLOR
else
  # Retrieve the occupancy state to determine standard icon color
  # We read the current label to see if it is empty/dots
  CURRENT_LABEL=$(sketchybar --query "$NAME" | jq -r '.label.value')
  if [ -z "$CURRENT_LABEL" ] || [ "$CURRENT_LABEL" = "—" ] || [ "$CURRENT_LABEL" = "" ]; then
    # Unoccupied
    sketchybar --set "$NAME" background.drawing=off \
                             label.color=$SLATE \
                             icon.color=$SLATE
  else
    # Occupied
    sketchybar --set "$NAME" background.drawing=off \
                             label.color=$LABEL_COLOR \
                             icon.color=$WHITE
  fi
fi

# 2. Update window icons if the sender is space_windows_change
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
  
  # Check if space is fullscreen (native or zoomed)
  IS_FULLSCREEN="false"
  SPACE_JSON=$(yabai -m query --spaces --space "$SPACE" 2>/dev/null)
  if [ -n "$SPACE_JSON" ] && [ "$SPACE_JSON" != "null" ]; then
    NATIVE_FS=$(echo "$SPACE_JSON" | jq -r '."is-native-fullscreen"')
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
      sketchybar --set "space.$SPACE" label="—" label.drawing=off icon.color=$ITEM_BG_COLOR
    else
      sketchybar --set "space.$SPACE" label="—" label.drawing=off icon.color=$SLATE
    fi
  else
    # Occupied Space
    if [ "$SELECTED" = "true" ]; then
      sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$ITEM_BG_COLOR label.color=$ITEM_BG_COLOR
    else
      sketchybar --set "space.$SPACE" label="$ICON_STRIP" label.drawing=on icon.color=$WHITE label.color=$LABEL_COLOR
    fi
  fi
fi
