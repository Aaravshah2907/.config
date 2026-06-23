#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  EVENT=$(/opt/homebrew/bin/icalBuddy -n -ea -li 1 -b "" -nc -iep "title,datetime" eventsToday 2>/dev/null | head -1 | xargs)
  
  if [ -n "$EVENT" ] && [ "$EVENT" != "No upcoming events" ]; then
    sketchybar --set upcoming_alert label="$EVENT" drawing=on
  else
    sketchybar --set upcoming_alert drawing=off
  fi
fi
