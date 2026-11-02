#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"
# Battery power helper (caches result 10s to avoid repeated pmset calls)
source "$(dirname "$0")/battery_power.sh"

STATE_FILE="/tmp/sketchybar_pomodoro.state"

if [ "$SENDER" = "mouse.clicked" ] || [ "${1:-}" = "click" ]; then
  if [ -f "$STATE_FILE" ]; then
    # Cancel timer
    rm "$STATE_FILE"
    /opt/homebrew/bin/sketchybar --set pomodoro icon=󰔟 icon.color=$SPREN_HONOR label.drawing=off update_freq=1
  else
    # Start timer using SwiftDialog rather than an AppleScript prompt.
    DIALOG=/usr/local/bin/dialog
    INPUT_JSON=$("$DIALOG" --title "Pomodoro" \
      --message "" --hideicon \
      --textfield '{"title":"Minutes","name":"minutes","value":"30","regex":"^[0-9]{1,3}$","regexerror":"Enter a whole number from 1 to 240"}' \
      --json --button1text "Start" --button2text "Cancel" --hideicon --small --width 380 --height 225 --ontop) || exit 0
    MINS=$(printf '%s' "$INPUT_JSON" | /opt/homebrew/bin/jq -r '.minutes // empty')
    if [[ "$MINS" =~ ^[0-9]+$ ]] && (( MINS > 0 && MINS <= 240 )); then
      END_TIME=$(($(date +%s) + MINS * 60))
      echo "$END_TIME" > "$STATE_FILE"
      /opt/homebrew/bin/sketchybar --set pomodoro icon=󰔟 icon.color=$WARN_COLOR label.drawing=on update_freq=1
    fi
  fi
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  if [ -f "$STATE_FILE" ]; then
    # Timer is active — always run at 1s precision regardless of power source
    /opt/homebrew/bin/sketchybar --set pomodoro update_freq=1
    END_TIME=$(cat "$STATE_FILE")
    NOW=$(date +%s)
    REMAINING=$((END_TIME - NOW))
    
    if [ $REMAINING -le 0 ]; then
      # Timer done! Animation and sound
      rm "$STATE_FILE"
      alert "🍅 Pomodoro completed! Time to take a short break." &
      afplay /System/Library/Sounds/Glass.aiff &
      sleep 1
      afplay /System/Library/Sounds/Glass.aiff &
      
      # Ringing animation for 6 seconds (toggles icon and color 6 times)
      for i in {1..6}; do
        /opt/homebrew/bin/sketchybar --set pomodoro icon=󰂞 icon.color=$RELOAD_COLOR label="DONE!"
        sleep 0.5
        /opt/homebrew/bin/sketchybar --set pomodoro icon=󰂟 icon.color=$WHITE label="DONE!"
        sleep 0.5
      done
      
      /opt/homebrew/bin/sketchybar --set pomodoro icon=󰔟 icon.color=$SPREN_HONOR label.drawing=off
      # No active timer — throttle if on battery
      on_battery && /opt/homebrew/bin/sketchybar --set pomodoro update_freq=30
    else
      # Update time display
      MINUTES=$((REMAINING / 60))
      SECONDS=$((REMAINING % 60))
      FORMATTED=$(printf "%02d:%02d" $MINUTES $SECONDS)
      /opt/homebrew/bin/sketchybar --set pomodoro label="$FORMATTED" label.drawing=on
    fi
  else
    # No active timer — throttle polling to save CPU on battery
    if on_battery; then
      /opt/homebrew/bin/sketchybar --set pomodoro update_freq=30
    else
      /opt/homebrew/bin/sketchybar --set pomodoro update_freq=1
    fi
  fi
fi
