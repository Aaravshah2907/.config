#!/bin/bash
ICON="$1"
ICON_COLOR="$2"
TEXT="$3"

# Check if music is playing
MUSIC_DRAWING=$(sketchybar --query music | jq -r '.geometry.drawing')

NOTCH_TO_USE="notch1"

# Determine which notch to use
if [ "$MUSIC_DRAWING" = "on" ]; then
    # Only notch1 is available
    NOTCH_TO_USE="notch1"
else
    # Can use notch1 or notch2
    NOTCH1_DRAWING=$(sketchybar --query notch1 | jq -r '.geometry.drawing')
    if [ "$NOTCH1_DRAWING" = "on" ]; then
        NOTCH_TO_USE="notch2"
    else
        NOTCH_TO_USE="notch1"
    fi
fi

# Clean up previous sleep process for this specific notch
if [ -f "/tmp/sketchybar_${NOTCH_TO_USE}_pid" ]; then
    PID=$(cat "/tmp/sketchybar_${NOTCH_TO_USE}_pid")
    kill -9 "$PID" 2>/dev/null
fi

# Trigger the dynamic notch
sketchybar --set "$NOTCH_TO_USE" icon="$ICON" icon.color="$ICON_COLOR" label="$TEXT" \
           --set "$NOTCH_TO_USE" drawing=on \
           --animate tanh 15 --set "$NOTCH_TO_USE" y_offset=0

# Hide it after 15 seconds
(
  sleep 15
  sketchybar --animate tanh 15 --set "$NOTCH_TO_USE" y_offset=-50
  sleep 0.5
  sketchybar --set "$NOTCH_TO_USE" drawing=off
) &
echo $! > "/tmp/sketchybar_${NOTCH_TO_USE}_pid"
