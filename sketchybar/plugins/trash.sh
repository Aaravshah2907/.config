#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  rm -rf ~/.Trash/*
  sketchybar --set $NAME drawing=off
  exit 0
fi

TRASH_SIZE=$(du -sm ~/.Trash 2>/dev/null | awk '{print $1}')

if [ -n "$TRASH_SIZE" ] && [ "$TRASH_SIZE" -gt 512 ]; then
  sketchybar --set $NAME drawing=on label="${TRASH_SIZE}MB"
else
  sketchybar --set $NAME drawing=off
fi
