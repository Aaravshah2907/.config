#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

CAFFEINE_PID=$(pgrep caffeinate)

if [ "$1" = "click" ]; then
  if [ -z "$CAFFEINE_PID" ]; then
    # Start caffeinate in background for display sleep
    caffeinate -d &
    sketchybar --set $NAME icon.color=$HONOR_GOLD
  else
    # Kill caffeinate
    kill -9 $CAFFEINE_PID
    sketchybar --set $NAME icon.color=$WHITE
  fi
  exit 0
fi

# Update state for regular updates
if [ -z "$CAFFEINE_PID" ]; then
  sketchybar --set $NAME icon.color=$WHITE
else
  sketchybar --set $NAME icon.color=$HONOR_GOLD
fi
