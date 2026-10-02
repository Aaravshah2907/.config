#!/bin/sh

# Diagnostic: Log environment variables to a temp file
# env > /tmp/sketchybar_vol_debug.txt

# When a slider is moved, it executes its script with the PERCENTAGE env var
if [ -n "$PERCENTAGE" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
fi

# Handle mouse exit to collapse
if [ "$SENDER" = "mouse.exited" ]; then
  /opt/homebrew/bin/sketchybar --animate circ 20 --set volume_slider slider.width=0
fi
