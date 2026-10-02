#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if ! command -v SwitchAudioSource &> /dev/null; then
  if [ -x "/opt/homebrew/bin/SwitchAudioSource" ]; then
    SAS="/opt/homebrew/bin/SwitchAudioSource"
  else
    sketchybar --set $NAME drawing=off
    exit 0
  fi
else
  SAS="SwitchAudioSource"
fi

# Check if any external/real output devices are available 
# (Filtering out typical built-in and software devices)
OUTPUTS=$($SAS -a -t output)
EXTERNAL_COUNT=$(echo "$OUTPUTS" | grep -viE "MacBook.*Speakers|Built-in Output|ZoomAudioDevice|BlackHole|Mac mini Speakers|iMac Speakers|Microsoft Teams Audio" | grep -c '[^[:space:]]')

if [ "$EXTERNAL_COUNT" -eq 0 ]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  $SAS -n
  sleep 0.2
fi

CURRENT=$($SAS -c)
ICON="󰓃"
COLOR=$PRES_GLACIAL

if echo "$CURRENT" | grep -iq "headphone\|airpods\|earbuds\|bose\|sony\|jabra\|beats\|buds\|rockerz"; then
  ICON="󰋋"
  COLOR=$SPREN_HONOR
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label.drawing=off drawing=on
