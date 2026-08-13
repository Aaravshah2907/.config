#!/bin/sh
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  # Requires `brew install brightness`
  if command -v brightness >/dev/null; then
    # brightness takes values from 0.0 to 1.0
    BRT=$(awk "BEGIN {print $PERCENTAGE / 100}")
    brightness -v $BRT
  fi
  BRIGHTNESS=$PERCENTAGE
else
  if command -v brightness >/dev/null; then
    # Output is like: display 0: brightness 1.000000
    BRT_RAW=$(brightness -l | grep -m 1 "brightness" | awk '{print $4}')
    BRIGHTNESS=$(awk "BEGIN {print int($BRT_RAW * 100)}")
  else
    BRIGHTNESS=50
  fi
fi

sketchybar --set "$NAME" slider.percentage="$BRIGHTNESS"
