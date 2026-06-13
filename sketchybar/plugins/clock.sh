#!/usr/bin/env bash
source "$HOME/.local/bin/cosmere_colors.sh"

# Handle hover for Clock (Peek mode)
if [ "$SENDER" = "mouse.entered" ]; then
  /opt/homebrew/bin/sketchybar --set "$NAME" popup.drawing=on
  bash "$HOME/.config/sketchybar/plugins/calendar.sh"
  bash "$HOME/.config/sketchybar/plugins/weather.sh"
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  /opt/homebrew/bin/sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

/opt/homebrew/bin/sketchybar --set "$NAME" label="$(date '+%I:%M %p')" label.color="$CLOCK_ACCENT" icon.color="$CLOCK_ACCENT"
/opt/homebrew/bin/sketchybar --set clock.date label="$(date '+%A, %d %B')"
