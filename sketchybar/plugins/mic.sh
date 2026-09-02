#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    osascript -e 'set volume input volume 0'
    sketchybar --set $NAME icon="󰍭" icon.color=$SPREN_ASH label="Muted" label.color=$SPREN_ASH label.drawing=on drawing=on
  else
    osascript -e 'set volume input volume 100'
    sketchybar --set $NAME icon="󰍬" icon.color=$WARN_COLOR label="LIVE" label.color=$WARN_COLOR label.drawing=on drawing=on
  fi
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    sketchybar --set $NAME icon="󰍬" icon.color=$WARN_COLOR label="LIVE" label.color=$WARN_COLOR label.drawing=on drawing=on
  else
    sketchybar --set $NAME icon="󰍭" icon.color=$SPREN_ASH label="Muted" label.color=$SPREN_ASH label.drawing=on drawing=on
  fi
fi
