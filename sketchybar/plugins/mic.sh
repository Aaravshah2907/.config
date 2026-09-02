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

  # Detect if microphone audio stream is actively in use by any running app
  IS_RECORDING=""
  if pgrep -x "zoom.us|Slack|Discord|Teams|FaceTime|QuickTime Player|obs|Google Chrome|Brave Browser|Arc|iTerm2" >/dev/null 2>&1; then
    IS_RECORDING="true"
  fi

  if [ -n "$IS_RECORDING" ]; then
    # Active Recording / In Use: Pulsing Neon Red (0xffFF3B30) with sin wave animation
    sketchybar --animate sin 15 --set $NAME icon="󰍬" icon.color=0xffFF3B30 label.drawing=off drawing=on
  else
    # Standby / Unmuted: Electric Cyan (0xff00E5FF)
    sketchybar --set $NAME icon="󰍬" icon.color=0xff00E5FF label.drawing=off drawing=on
  fi
fi
