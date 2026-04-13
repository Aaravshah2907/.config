#!/bin/bash

# WINDRUNNER - Stormlight Reserve (Battery) Plugin
# Monitors the Investiture level of your Gemstones

source "$HOME/.config/sketchybar/colors.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="􀛨"
  ;;
  [6-8][0-9]) ICON="􀺸"
  ;;
  [3-5][0-9]) ICON="􀺶"
  ;;
  [1-2][0-9]) ICON="􀛩"
  ;;
  *) ICON="􀛪"
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="􀢋"
fi

# Battery Color Palette (Stormlight Reserve Levels)
if [ "$PERCENTAGE" -le 15 ]; then
  COLOR="$RED"
elif [ "$PERCENTAGE" -le 35 ]; then
  COLOR="$AMBER" # Transitioning to Void/Empty
elif [ "$PERCENTAGE" -le 60 ]; then
  COLOR="$HONOR_GOLD" # Balanced Reserve
elif [ "$PERCENTAGE" -le 85 ]; then
  COLOR="$EMERALD" # Healthy Stormlight
else
  COLOR="$SAPPHIRE" # Windrunner Peak
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.color="$COLOR" \
  label.color="$COLOR" \
  padding_right=0
