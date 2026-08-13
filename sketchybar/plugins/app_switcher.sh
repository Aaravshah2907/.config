#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# Query the running apps
APPS_IN_SPACE=$(aerospace list-windows --workspace focused --format '%{app-name}' 2>/dev/null)
FOCUSED_APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)

# Clean up all existing app switcher items
sketchybar --remove '/app\.switcher\..*/'

if [ -z "$APPS_IN_SPACE" ]; then
  exit 0
fi

# Parse unique apps preserving order
UNIQUE_APPS=$(echo "$APPS_IN_SPACE" | awk '!seen[$0]++')

# Source the icon map once
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

ADD_CMD=()

while read -r APP; do
  [ -z "$APP" ] && continue
  
  if [ "$APP" = "$FOCUSED_APP" ]; then
    FOCUSED="true"
  else
    FOCUSED="false"
  fi
  
  # Clean name for sketchybar item
  CLEAN_NAME=$(echo "$APP" | sed 's/[^a-zA-Z0-9]//g')
  ITEM_NAME="app.switcher.$CLEAN_NAME"
  
  # Fetch icon using sketchybar-app-font (custom overrides first)
  __icon_map_custom "$APP" || __icon_map "$APP"
  ICON="$icon_result"
  [ -z "$ICON" ] && ICON=":default:"

  if [ "$icon_font_override" = "nerd" ]; then
    ICON_FONT="Hack Nerd Font:Bold:14.0"
  else
    ICON_FONT="sketchybar-app-font:Regular:14.0"
  fi
  
  if [ "$FOCUSED" = "true" ]; then
    ICON_COLOR="$WHITE"
    BG_DRAW="on"
    BG_COLOR="$PRES_GLACIAL_TRANSLUCENT"
  else
    ICON_COLOR="$PRES_GLACIAL_TRANSLUCENT"
    BG_DRAW="off"
    BG_COLOR="0x00000000"
  fi
  
  ADD_CMD+=(--add item "$ITEM_NAME" left)
  ADD_CMD+=(--set "$ITEM_NAME" \
              icon="$ICON" \
              icon.font="$ICON_FONT" \
              icon.color="$ICON_COLOR" \
              label.drawing=off \
              background.color="$BG_COLOR" \
              background.drawing="$BG_DRAW" \
              background.corner_radius=6 \
              background.height=22 \
              padding_left=2 \
              padding_right=2 \
              click_script="open -a \"$APP\"")
done <<< "$UNIQUE_APPS"

if [ ${#ADD_CMD[@]} -gt 0 ]; then
  sketchybar "${ADD_CMD[@]}"
fi
