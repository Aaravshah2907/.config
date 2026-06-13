#!/bin/bash

# WINDRUNNER - Stormlight Reserve (Battery) Plugin
# Monitors the Investiture level of your Gemstones

source "$HOME/.config/sketchybar/colors.sh"

# Handle hover for battery widget
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="󰁹"
  ;;
  [7-8][0-9]) ICON="󰂂"
  ;;
  [5-6][0-9]) ICON="󰁿"
  ;;
  [3-4][0-9]) ICON="󰁽"
  ;;
  [1-2][0-9]) ICON="󰁻"
  ;;
  *) ICON="󰂎"
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="󰂄"
fi

if [[ "$CHARGING" != "" ]]; then
  COLOR="$HONOR_GOLD"
  LABEL="Infusing ${PERCENTAGE}%"
else
  # Battery Color Palette (Stormlight Reserve Levels)
  if [ "$PERCENTAGE" -le 30 ]; then
    COLOR="$RED"
    LABEL="Dun Gem ${PERCENTAGE}%"
  elif [ "$PERCENTAGE" -le 80 ]; then
    COLOR="$AMBER" # Transitioning to Void/Empty
    LABEL="Reserve ${PERCENTAGE}%"
  else
    COLOR="$SAPPHIRE" # Windrunner Peak
    LABEL="Infused ${PERCENTAGE}%"
  fi
fi

# Update popup battery status
sketchybar --set battery.status \
  icon="$ICON" \
  icon.color="$COLOR" \
  label="$LABEL"

# Set main bar item
sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$COLOR" \
  label.drawing=off

# Charging pulse animation (gentle opacity change)
if [[ "$CHARGING" != "" ]]; then
  sketchybar --animate "$NAME" icon.color $EMERALD $EMERALD duration=1200 repeat=indefinite
fi

# Low battery shake warning when <=15%
if [ "$PERCENTAGE" -le 15 ]; then
  sketchybar --animate "$NAME" icon.y_offset -4 4 duration=150 repeat=3
fi
