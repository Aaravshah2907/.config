#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  EVENT=$(/opt/homebrew/bin/icalBuddy -n -ea -li 1 -b "" -nc -iep "title,datetime" eventsToday 2>/dev/null | head -1 | xargs)
  
  if [ -n "$EVENT" ] && [ "$EVENT" != "No upcoming events" ]; then
    sketchybar --set upcoming_alert label="$EVENT" drawing=on
    
    # Send one WhatsApp alert per unique event
    SAFE_EVENT=$(echo "$EVENT" | tr -cd '[:alnum:]')
    if [ ! -f "/tmp/wacli_event_${SAFE_EVENT}" ]; then
      rm -f /tmp/wacli_event_*
      alert "🗓️ Upcoming Calendar Event: $EVENT" &
      touch "/tmp/wacli_event_${SAFE_EVENT}"
    fi
  else
    sketchybar --set upcoming_alert drawing=off
    rm -f /tmp/wacli_event_*
  fi
fi
