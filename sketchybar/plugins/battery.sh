#!/bin/bash

# PRESERVATION — Stormlight Reserve (Battery) Plugin
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
  COLOR="$PRES_ATIUM"                  # Atium gold — power flowing in
  LABEL="Infusing ${PERCENTAGE}%"
else
  # Preservation Reserve Levels: draining toward Ruin
  if [ "$PERCENTAGE" -le 15 ]; then
    COLOR="$RUIN_MAROON"              # Ruin's grip — critical
    LABEL="Dun Gem ${PERCENTAGE}%"
  elif [ "$PERCENTAGE" -le 30 ]; then
    COLOR="$RUIN_SPIKE"              # Hemalurgic amber — danger
    LABEL="Dun Gem ${PERCENTAGE}%"
  elif [ "$PERCENTAGE" -le 80 ]; then
    COLOR="$PRES_LAVENDER"           # Preservation calm — midpoint
    LABEL="Reserve ${PERCENTAGE}%"
  else
    COLOR="$BATT_ACCENT"            # Preservation mist — fully infused
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

# Charging pulse animation: Preservation mist ↔ Atium gold
if [[ "$CHARGING" != "" ]]; then
  sketchybar --animate "$NAME" icon.color $PRES_MIST $PRES_ATIUM duration=1200 repeat=indefinite
fi

# Low battery shake warning when <=15%
if [ "$PERCENTAGE" -le 15 ]; then
  sketchybar --animate "$NAME" icon.y_offset -4 4 duration=150 repeat=3
fi
