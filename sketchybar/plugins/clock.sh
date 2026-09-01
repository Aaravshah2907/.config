#!/usr/bin/env bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  DRAWING=$(/opt/homebrew/bin/sketchybar --query clock | jq -r '.popup.drawing')
  if [ "$DRAWING" = "on" ]; then
    /opt/homebrew/bin/sketchybar --set clock popup.drawing=off
  else
    /opt/homebrew/bin/sketchybar --set clock popup.drawing=on
    bash "$HOME/.config/sketchybar/plugins/calendar.sh" &
  fi
  exit 0
fi

if [ "$SENDER" = "mouse.exited.global" ]; then
  /opt/homebrew/bin/sketchybar --set clock popup.drawing=off
  exit 0
fi

/opt/homebrew/bin/sketchybar --set "$NAME" label="$(date '+%I:%M %p')" label.color="$CLOCK_ACCENT" icon.color="$CLOCK_ACCENT"
/opt/homebrew/bin/sketchybar --set clock.date label="$(date '+%A, %d %B')"
