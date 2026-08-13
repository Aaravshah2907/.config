#!/bin/bash
ICON="$1"
ICON_COLOR="$2"
TEXT="$3"

# Trigger the dynamic notch
sketchybar --set notch icon="$ICON" icon.color="$ICON_COLOR" label="$TEXT" \
           --set notch drawing=on \
           --animate tanh 15 --set notch y_offset=0

# Clean up previous sleep processes for notch hiding
pkill -f "notch_hide"

(
  exec -a "notch_hide" sleep 4
  sketchybar --animate tanh 15 --set notch y_offset=-50
  sleep 0.5
  sketchybar --set notch drawing=off
) &
