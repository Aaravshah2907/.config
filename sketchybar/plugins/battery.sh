#!/bin/bash

# PRESERVATION — Stormlight Reserve (Battery) Plugin
# Monitors the Investiture level of your Gemstones

source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"

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
else
  sketchybar --set "$NAME" icon.y_offset=0
fi

# WhatsApp Notifications (Wacli)
if [[ "$CHARGING" == "" ]]; then
  if [ "$PERCENTAGE" -le 5 ]; then
    if [ ! -f "/tmp/wacli_batt_5" ]; then
      alert "🚨 CRITICAL: Battery at ${PERCENTAGE}%. Shutting down soon!" &
      touch "/tmp/wacli_batt_5"
    fi
  elif [ "$PERCENTAGE" -le 10 ]; then
    if [ ! -f "/tmp/wacli_batt_10" ]; then
      alert "⚠️ WARNING: Battery low at ${PERCENTAGE}%." &
      touch "/tmp/wacli_batt_10"
    fi
  elif [ "$PERCENTAGE" -le 20 ]; then
    if [ ! -f "/tmp/wacli_batt_20" ]; then
      alert "🔋 NOTICE: Battery at ${PERCENTAGE}%." &
      touch "/tmp/wacli_batt_20"
    fi
  fi
  # Clean up charging warning lock
  rm -f "/tmp/wacli_batt_95"
  
  # Also trigger the original system notification logic for <=15
  if [ "$PERCENTAGE" -le 15 ] && [ ! -f "/tmp/syl_batt_warn" ]; then
    ya pub plugin --str "syl-notify custom '󰚌 Odium Approaches' 'Aarav, the stormlight is failing... we only have ${PERCENTAGE}% left!'" >/dev/null 2>&1
    touch /tmp/syl_batt_warn
  fi
else
  # Clean up discharge warning locks
  rm -f "/tmp/wacli_batt_5" "/tmp/wacli_batt_10" "/tmp/wacli_batt_20" "/tmp/syl_batt_warn"
  
  if [ "$PERCENTAGE" -ge 95 ]; then
    if [ ! -f "/tmp/wacli_batt_95" ]; then
      alert "⚡ Battery charged to ${PERCENTAGE}%. You can unplug now." &
      touch "/tmp/wacli_batt_95"
    fi
  fi
fi

# Smart Battery Border
if [ "$PERCENTAGE" -le 20 ] && [[ "$CHARGING" == "" ]]; then
  sketchybar --set bar border_color=$RUIN_MAROON
else
  sketchybar --set bar border_color=$SAPPHIRE_TRANSLUCENT
fi
