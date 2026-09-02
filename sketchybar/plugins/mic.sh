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

# Check state
if [ "$MIC_VOLUME" -eq 0 ]; then
  # Muted State: Clean minimal muted icon, muted gray color, no label text
  sketchybar --set $NAME icon="󰍭" icon.color=$SPREN_ASH label.drawing=off drawing=on
else
  # Unmuted (Live)
  echo "$MIC_VOLUME" > "$STATE_FILE"

  # Detect active app recording audio via coreaudio stream or active processes
  IS_RECORDING=$(arecord_check 2>/dev/null)
  if [ -z "$IS_RECORDING" ]; then
    # Fallback process check for common recording apps
    IS_RECORDING=$(pgrep -x "zoom.us|Slack|Discord|Teams|FaceTime|QuickTime Player|obs|Google Chrome|Brave Browser" 2>/dev/null)
  fi

  if [ -n "$IS_RECORDING" ]; then
    # Active Recording / In Use State: Pulsing bright red/coral with sin wave animation
    sketchybar --animate sin 20 --set $NAME icon="󰍬" icon.color=$WARN_COLOR label.drawing=off drawing=on
  else
    # Armed / Active Unmuted Standby: Clean emerald/cultivation color, minimal icon-only design
    sketchybar --set $NAME icon="󰍬" icon.color=$SPREN_CULTIVATION label.drawing=off drawing=on
  fi
fi
