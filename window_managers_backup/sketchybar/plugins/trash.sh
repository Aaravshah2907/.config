#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set $NAME popup.drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set $NAME popup.drawing=toggle
  exit 0
fi

TRASH_SIZE=$(du -sm ~/.Trash 2>/dev/null | awk '{print $1}')
TRASH_COUNT=$(ls -1A ~/.Trash 2>/dev/null | wc -l | xargs)

if [ -n "$TRASH_SIZE" ] && [ "$TRASH_SIZE" -gt 0 ]; then
  sketchybar --set $NAME drawing=on label="${TRASH_SIZE}MB" \
             --set trash.status label="Trash: ${TRASH_SIZE} MB (${TRASH_COUNT} items)"
else
  sketchybar --set $NAME drawing=off popup.drawing=off
fi
