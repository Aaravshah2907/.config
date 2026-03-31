#!/usr/bin/env bash

# Hide all slots first
sketchybar --set cc.bt.none drawing=off \
           --set cc.bt.0 drawing=off \
           --set cc.bt.1 drawing=off \
           --set cc.bt.2 drawing=off \
           --set cc.bt.3 drawing=off \
           --set cc.bt.4 drawing=off

DEVICES=$(blueutil --connected --format json 2>/dev/null)
COUNT=$(echo "$DEVICES" | jq '. | length' 2>/dev/null || echo "0")

if [ -z "$DEVICES" ] || [ "$COUNT" -eq 0 ]; then
  sketchybar --set cc.bt.none drawing=on icon="󰂲" label="No Devices Connected" \
                   click_script="open x-apple.systempreferences:com.apple.preference.bluetooth; sketchybar --set control_center popup.drawing=off"
  exit 0
fi

INDEX=0
echo "$DEVICES" | jq -c '.[]' | while read -r device; do
  if [ "$INDEX" -ge 5 ]; then break; fi
  
  NAME=$(echo "$device" | jq -r '.name')
  
  # Determine icon based on name
  ICON="󰂯"
  if echo "$NAME" | grep -iq "airpods\|earpods\|headphone\|buds\|audio"; then
    ICON="󰋋"
  elif echo "$NAME" | grep -iq "mouse\|trackpad"; then
    ICON="󰍽"
  elif echo "$NAME" | grep -iq "keyboard"; then
    ICON="󰌌"
  elif echo "$NAME" | grep -iq "watch"; then
    ICON="󰥔"
  elif echo "$NAME" | grep -iq "speaker"; then
    ICON="󰓃"
  fi

  sketchybar --set cc.bt.$INDEX drawing=on icon="$ICON" label="$NAME" \
                   click_script="open x-apple.systempreferences:com.apple.preference.bluetooth; sketchybar --set control_center popup.drawing=off"
  
  INDEX=$((INDEX + 1))
done
