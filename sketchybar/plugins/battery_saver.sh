#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

STATE_FILE="/tmp/battery_saver_active"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE_FILE" ]; then
    # Turn OFF Battery Saver → Restore Radiant Performance Mode
    rm -f "$STATE_FILE"
    nohup /Users/aaravshah2975/.config/borders/bordersrc >/dev/null 2>&1 &
    sketchybar --animate tanh 15 \
      --set battery_saver icon="󱐋" \
                          icon.color=$RADIANT_GOLD \
                          label="Radiant" \
                          label.color=$RADIANT_GOLD \
                          background.color=$PRES_DEEP_TRANSLUCENT
  else
    # Turn ON Battery Saver → Ultra Eco Mode
    touch "$STATE_FILE"
    pkill -f borders 2>/dev/null
    sketchybar --animate tanh 15 \
      --set battery_saver icon="󰌪" \
                          icon.color=$SPREN_CULTIVATION \
                          label="Eco" \
                          label.color=$SPREN_CULTIVATION \
                          background.color=$PRES_DEEP_TRANSLUCENT
  fi
  exit 0
fi

# Sync on load
if [ -f "$STATE_FILE" ]; then
  sketchybar --set battery_saver icon="󰌪" \
                                 icon.color=$SPREN_CULTIVATION \
                                 label="Eco" \
                                 label.color=$SPREN_CULTIVATION
else
  sketchybar --set battery_saver icon="󱐋" \
                                 icon.color=$RADIANT_GOLD \
                                 label="Radiant" \
                                 label.color=$RADIANT_GOLD
fi
