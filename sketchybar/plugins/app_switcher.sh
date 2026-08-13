#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# Query the running apps in screen coordinate order (left-to-right)
WINDOWS=$(yabai -m query --windows --space 2>/dev/null)

# Clean up all existing app switcher items
sketchybar --remove '/app\.switcher\..*/'

if [ -z "$WINDOWS" ] || [ "$WINDOWS" = "null" ] || [ "$WINDOWS" = "[]" ]; then
  exit 0
fi

# Parse unique apps preserving screen order (x-coordinate)
APPS=$(echo "$WINDOWS" | jq -c 'map(select(."is-minimized" == false and .app != "")) | sort_by(.frame.x) | reduce .[] as $w ([]; if map(.app) | contains([$w.app]) then (map(if .app == $w.app then .focused = (.focused or $w."has-focus") else . end)) else . + [{app: $w.app, focused: $w."has-focus"}] end)')

# Source the icon map once
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

ADD_CMD=()

while read -r row; do
  [ -z "$row" ] && continue
  APP=$(echo "$row" | jq -r '.app')
  FOCUSED=$(echo "$row" | jq -r '.focused')
  
  # Clean name for sketchybar item
  CLEAN_NAME=$(echo "$APP" | sed 's/[^a-zA-Z0-9]//g')
  ITEM_NAME="app.switcher.$CLEAN_NAME"
  
  # Fetch icon using sketchybar-app-font (custom overrides first)
  __icon_map_custom "$APP" || __icon_map "$APP"
  ICON="$icon_result"
  [ -z "$ICON" ] && ICON=":default:"
  
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
              icon.font="sketchybar-app-font:Regular:14.0" \
              icon.color="$ICON_COLOR" \
              label.drawing=off \
              background.color="$BG_COLOR" \
              background.drawing="$BG_DRAW" \
              background.corner_radius=6 \
              background.height=22 \
              padding_left=2 \
              padding_right=2 \
              click_script="open -a \"$APP\"")
done <<< "$(echo "$APPS" | jq -c '.[]')"

if [ ${#ADD_CMD[@]} -gt 0 ]; then
  sketchybar "${ADD_CMD[@]}"
fi
