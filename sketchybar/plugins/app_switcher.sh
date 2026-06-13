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

ADD_CMD=()

while read -r row; do
  [ -z "$row" ] && continue
  APP=$(echo "$row" | jq -r '.app')
  FOCUSED=$(echo "$row" | jq -r '.focused')
  
  # Clean name for sketchybar item
  CLEAN_NAME=$(echo "$APP" | sed 's/[^a-zA-Z0-9]//g')
  ITEM_NAME="app.switcher.$CLEAN_NAME"
  
  # Fetch icon
  ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$APP" 2>/dev/null)
  [ -z "$ICON" ] && ICON="󰀱"
  
  if [ "$FOCUSED" = "true" ]; then
    COLOR="$FRONTAPP_ACCENT"             # Cryptic shimmer — focused app
    BG_DRAW="on"
  else
    COLOR="$WHITE"
    BG_DRAW="off"
  fi
  
  ADD_CMD+=(--add item "$ITEM_NAME" left)
  ADD_CMD+=(--set "$ITEM_NAME" \
              icon="$ICON" \
              label.drawing=off \
              icon.color="$COLOR" \
              background.color="$FRONTAPP_ACCENT_T" \
              background.drawing="$BG_DRAW" \
              background.corner_radius=6 \
              background.height=24 \
              click_script="open -a \"$APP\"")
done <<< "$(echo "$APPS" | jq -c '.[]')"

if [ ${#ADD_CMD[@]} -gt 0 ]; then
  sketchybar "${ADD_CMD[@]}"
fi
