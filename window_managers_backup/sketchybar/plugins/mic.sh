#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

STATE_FILE="/tmp/sketchybar_mic_volume"
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# Click handler: Toggle Mute / Restore
if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    echo "$MIC_VOLUME" > "$STATE_FILE"
    osascript -e 'set volume input volume 0'
    MIC_VOLUME=0
  else
    TARGET_VOL=80
    if [ -f "$STATE_FILE" ]; then
      SAVED_VOL=$(cat "$STATE_FILE" 2>/dev/null)
      if [ -n "$SAVED_VOL" ] && [ "$SAVED_VOL" -gt 0 ] 2>/dev/null; then
        TARGET_VOL=$SAVED_VOL
      fi
    fi
    osascript -e "set volume input volume $TARGET_VOL"
    MIC_VOLUME=$TARGET_VOL
  fi
fi

# Distinct State Colors:
# 1. Muted: Silver/Ash Gray (0xff8899a6)
# 2. Standby / Unmuted: Cyan/Preservation Teal (0xff00E5FF)
# 3. Active Recording / In Use: Pulsing Neon Red (0xffFF3B30)

if [ "$MIC_VOLUME" -eq 0 ]; then
  # Muted State
  sketchybar --set $NAME icon="󰍭" icon.color=0xff8899a6 label.drawing=off drawing=on
else
  # Unmuted (Live)
  echo "$MIC_VOLUME" > "$STATE_FILE"

  # Query hardware CoreAudio hardware state using compiled Swift tool
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  IS_RECORDING=""
  if [ -x "$DIR/check_mic_active" ]; then
    if "$DIR/check_mic_active" >/dev/null 2>&1; then
      IS_RECORDING="true"
    fi
  fi

  if [ -n "$IS_RECORDING" ]; then
    # Mode 1: Active Hardware Recording / In Use (Pulsing Neon Red)
    sketchybar --animate sin 15 --set $NAME icon="󰍬" icon.color=0xffFF3B30 label.drawing=off drawing=on
  else
    # Mode 2: Unmuted Standby / Armed (Electric Cyan)
    sketchybar --set $NAME icon="󰍬" icon.color=0xff00E5FF label.drawing=off drawing=on
  fi
fi
