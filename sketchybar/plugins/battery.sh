#!/bin/bash

# PRESERVATION — Stormlight Reserve (Battery) Plugin
# Monitors the Investiture level of your Gemstones

source "$HOME/.local/bin/cosmere_colors.sh"

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

if [[ "$CHARGING" != "" ]]; then
  sketchybar --set "$NAME" update_freq=5
else
  sketchybar --set "$NAME" update_freq=120
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
  *) ICON="󱃍"
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="󰂄"
fi

if [[ "$CHARGING" != "" ]]; then
  COLOR="$BATT_ACCENT"
  LABEL="󰇚 Infusing ${PERCENTAGE}%"

elif [ "$PERCENTAGE" -le 15 ]; then
  COLOR="$RUIN_MAROON"
  LABEL="Dun Gem ${PERCENTAGE}%"

elif [ "$PERCENTAGE" -le 30 ]; then
  COLOR="$RUIN_SPIKE"
  LABEL="Dun Gem ${PERCENTAGE}%"

elif [ "$PERCENTAGE" -le 80 ]; then
  COLOR="$PRES_LAVENDER"
  LABEL="Reserve ${PERCENTAGE}%"

else
  COLOR="$BATT_ACCENT"
  LABEL="Infused ${PERCENTAGE}%"
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

# Charging pulse animation: Preservation mist <-> Atium gold
if [[ "$CHARGING" != "" ]]; then
  CHARGE_PHASE_FILE="/tmp/syl_batt_charge_phase"

  if [ -f "$CHARGE_PHASE_FILE" ]; then
    CHARGE_COLOR="$PRES_ATIUM"
    rm -f "$CHARGE_PHASE_FILE"
  else
    CHARGE_COLOR="$BATT_ACCENT"
    touch "$CHARGE_PHASE_FILE"
  fi

  sketchybar --animate sin 60 --set "$NAME" icon.color="$CHARGE_COLOR"
else
  rm -f /tmp/syl_batt_charge_phase
fi

# Low battery shake warning when <=15%
if [ "$PERCENTAGE" -le 15 ]; then
  sketchybar --animate sin 15 --set "$NAME" icon.y_offset=-4
  sketchybar --animate sin 15 --set "$NAME" icon.y_offset=0
  
  if [ -z "$CHARGING" ]; then
    if [ ! -f "/tmp/syl_batt_warn" ]; then
      ya pub plugin --str "syl-notify custom '󰚌 Odium Approaches' 'Aarav, the stormlight is failing... we only have ${PERCENTAGE}% left!'" >/dev/null 2>&1
      touch /tmp/syl_batt_warn
    fi
  else
    rm -f /tmp/syl_batt_warn
  fi
else
  rm -f /tmp/syl_batt_warn
  sketchybar --set "$NAME" icon.y_offset=0
fi
