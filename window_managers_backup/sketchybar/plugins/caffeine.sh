#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

CAFFEINE_PID=$(pgrep caffeinate)

if [ "$1" = "click" ]; then
  if [ -z "$CAFFEINE_PID" ]; then
    # Start caffeinate in background for display sleep
    caffeinate -d &
    sketchybar --set $NAME icon.color=$HONOR_GOLD \
               --set utilities icon.color=$HONOR_GOLD
  else
    # Kill caffeinate
    kill -9 $CAFFEINE_PID
    sketchybar --set $NAME icon.color=$WHITE \
               --set utilities icon.color=$PRES_GLACIAL
  fi
  exit 0
fi

# Update state for regular updates
if [ -z "$CAFFEINE_PID" ]; then
  sketchybar --set $NAME icon.color=$WHITE \
             --set utilities icon.color=$PRES_GLACIAL
else
  sketchybar --set $NAME icon.color=$HONOR_GOLD \
             --set utilities icon.color=$HONOR_GOLD
fi
