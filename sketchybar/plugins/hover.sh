#!/usr/bin/env bash

NORMAL_SIZE=18
HOVER_SIZE=24

if [[ "$SENDER" == "mouse.entered" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=$HOVER_SIZE
elif [[ "$SENDER" == "mouse.exited" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=$NORMAL_SIZE
fi

# Always call the original script so it can handle popups and other logic
if [[ -n "$1" ]]; then
  "$@"
fi
