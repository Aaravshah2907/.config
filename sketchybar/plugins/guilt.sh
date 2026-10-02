#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
# Battery power helper (caches pmset result for 10s)
source "$(dirname "$0")/battery_power.sh"

STATE_FILE="/tmp/sketchybar_guilt.state"

CURRENT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
NOW=$(date +%s)

# List of distracting apps (lowercase for easy matching)
DISTRACTING_APPS=("discord" "slack" "whatsapp" "instagram" "reddit")

is_distracting() {
  local app=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  for da in "${DISTRACTING_APPS[@]}"; do
    if [[ "$app" == *"$da"* ]]; then
      return 0
    fi
  done
  return 1
}

if ! is_distracting "$CURRENT_APP"; then
  rm -f "$STATE_FILE"
  sketchybar --set guilt drawing=off
  # On battery, slow down polling when there's nothing to show
  on_battery && sketchybar --set guilt update_freq=20
  exit 0
fi

# Distracting app is focused — restore responsive polling and track time
on_battery && sketchybar --set guilt update_freq=5

if [ -f "$STATE_FILE" ]; then
  SAVED_DATA=$(cat "$STATE_FILE")
  SAVED_APP=$(echo "$SAVED_DATA" | cut -d':' -f1)
  START_TIME=$(echo "$SAVED_DATA" | cut -d':' -f2)
  
  if [ "$SAVED_APP" != "$CURRENT_APP" ]; then
    echo "$CURRENT_APP:$NOW" > "$STATE_FILE"
    START_TIME=$NOW
  fi
else
  echo "$CURRENT_APP:$NOW" > "$STATE_FILE"
  START_TIME=$NOW
fi

ELAPSED=$((NOW - START_TIME))
MINUTES=$((ELAPSED / 60))

if [ "$MINUTES" -ge 20 ]; then
  COLOR=$CRIMSON
  sketchybar --animate sin 10 --set guilt icon.y_offset=-2
  sketchybar --animate sin 10 --set guilt icon.y_offset=0
elif [ "$MINUTES" -ge 10 ]; then
  COLOR=$WARN_COLOR
else
  COLOR=$PRES_MIST
fi

FORMATTED=$(printf "%02d:%02d" $MINUTES $((ELAPSED % 60)))

sketchybar --set guilt drawing=on \
                     label="$FORMATTED" \
                     icon="󰈈" \
                     icon.color=$COLOR \
                     label.color=$COLOR \
                     label.drawing=on
