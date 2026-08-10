#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    osascript -e 'set volume input volume 0'
    sketchybar --set $NAME drawing=off
  else
    osascript -e 'set volume input volume 100'
    sketchybar --set $NAME drawing=on
  fi
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    sketchybar --set $NAME drawing=on
  else
    sketchybar --set $NAME drawing=off
  fi
fi
