#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

STATE_FILE="/tmp/sketchybar_pomodoro.state"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE_FILE" ]; then
    # Cancel timer
    rm "$STATE_FILE"
    sketchybar --set pomodoro icon=󰔟 icon.color=$SPREN_HONOR label.drawing=off
  else
    # Start timer - Prompt for minutes using AppleScript
    MINS=$(osascript -e 'Tell application "System Events" to display dialog "Enter minutes for Pomodoro:" default answer "25"' -e 'text returned of result' 2>/dev/null)
    if [ -n "$MINS" ]; then
      END_TIME=$(($(date +%s) + MINS * 60))
      echo "$END_TIME" > "$STATE_FILE"
      sketchybar --set pomodoro icon=󰔟 icon.color=$WARN_COLOR label.drawing=on
    fi
  fi
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  if [ -f "$STATE_FILE" ]; then
    END_TIME=$(cat "$STATE_FILE")
    NOW=$(date +%s)
    REMAINING=$((END_TIME - NOW))
    
    if [ $REMAINING -le 0 ]; then
      # Timer done! Animation and sound
      rm "$STATE_FILE"
      afplay /System/Library/Sounds/Glass.aiff &
      sleep 1
      afplay /System/Library/Sounds/Glass.aiff &
      
      # Ringing animation for 6 seconds (toggles icon and color 6 times)
      for i in {1..6}; do
        sketchybar --set pomodoro icon=󰂞 icon.color=$RELOAD_COLOR label="DONE!"
        sleep 0.5
        sketchybar --set pomodoro icon=󰂟 icon.color=$WHITE label="DONE!"
        sleep 0.5
      done
      
      sketchybar --set pomodoro icon=󰔟 icon.color=$SPREN_HONOR label.drawing=off
    else
      # Update time
      MINUTES=$((REMAINING / 60))
      SECONDS=$((REMAINING % 60))
      FORMATTED=$(printf "%02d:%02d" $MINUTES $SECONDS)
      sketchybar --set pomodoro label="$FORMATTED" label.drawing=on
    fi
  fi
fi
