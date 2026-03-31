#!/usr/bin/env bash

# Handle hover for Clock (Peek mode)
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  # Force update of calendar and weather when hovering
  bash "$HOME/.config/sketchybar/plugins/calendar.sh"
  bash "$HOME/.config/sketchybar/plugins/weather.sh"
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# Update core clock time (on the bar)
sketchybar --set "$NAME" label="$(date '+%I:%M %p')"

# Update the sub-date item (inside the popup)
sketchybar --set clock.date label="$(date '+%A, %d %B')"
