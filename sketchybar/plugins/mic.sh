#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

STATE_FILE="/tmp/sketchybar_mic_volume"

MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    # Save current volume level so we can restore it accurately later
    echo "$MIC_VOLUME" > "$STATE_FILE"
    osascript -e 'set volume input volume 0'
    sketchybar --set $NAME icon="󰍭" icon.color=$SPREN_ASH label="Muted" label.color=$SPREN_ASH label.drawing=on drawing=on
  else
    # Restore previous volume level or default to 80% if no stored level exists
    TARGET_VOL=80
    if [ -f "$STATE_FILE" ]; then
      SAVED_VOL=$(cat "$STATE_FILE" 2>/dev/null)
      if [ -n "$SAVED_VOL" ] && [ "$SAVED_VOL" -gt 0 ] 2>/dev/null; then
        TARGET_VOL=$SAVED_VOL
      fi
    fi
    osascript -e "set volume input volume $TARGET_VOL"
    sketchybar --set $NAME icon="󰍬" icon.color=$WARN_COLOR label="LIVE" label.color=$WARN_COLOR label.drawing=on drawing=on
  fi
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  if [ "$MIC_VOLUME" -gt 0 ]; then
    # Continuously update saved volume while unmuted
    echo "$MIC_VOLUME" > "$STATE_FILE"
    sketchybar --set $NAME icon="󰍬" icon.color=$WARN_COLOR label="LIVE" label.color=$WARN_COLOR label.drawing=on drawing=on
  else
    sketchybar --set $NAME icon="󰍭" icon.color=$SPREN_ASH label="Muted" label.color=$SPREN_ASH label.drawing=on drawing=on
  fi
fi
