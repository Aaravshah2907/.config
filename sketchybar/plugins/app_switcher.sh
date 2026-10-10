#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

# Bail out if Dinky / tiling is disabled
if [ -f /tmp/dinky_disabled ] || [ -f /tmp/aerospace_disabled ]; then
  sketchybar --remove '/app\.switcher\..*/' 2>/dev/null
  exit 0
fi

# Query running apps on the focused space
RAW_APPS=$(dinky list-windows --workspace focused --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter" | awk NF)
if [ -z "$RAW_APPS" ]; then
  RAW_APPS=$(dinky list-windows --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter" | awk NF)
fi

FOCUSED_RAW=$(dinky list-windows --focused --format '%{app-name}' 2>/dev/null)
FOCUSED_APP=$(echo "$FOCUSED_RAW" | awk NF | head -n 1)

# Clean up all existing app switcher items
sketchybar --remove '/app\.switcher\..*/'

if [ -z "$RAW_APPS" ]; then
  exit 0
fi

# Parse unique apps preserving order
UNIQUE_APPS=$(echo "$RAW_APPS" | awk '!seen[$0]++')

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
  
  # Fetch icon using sketchybar-app-font
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
    BG_COLOR="$SPREN_HONOR"
  else
    ICON_COLOR="$PRES_GLACIAL_TRANSLUCENT"
    BG_DRAW="on"
    BG_COLOR="$PRES_DEEP_TRANSLUCENT"
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
              background.height=24 \
              padding_left=2 \
              padding_right=2 \
              icon.padding_left=6 \
              icon.padding_right=6 \
              click_script="open -a \"$APP\"")
done <<< "$UNIQUE_APPS"

if [ ${#ADD_CMD[@]} -gt 0 ]; then
  sketchybar "${ADD_CMD[@]}"
fi
