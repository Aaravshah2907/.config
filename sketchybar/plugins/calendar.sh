#!/bin/bash

# Fetch next 2 events for compactness
EVENTS=$(icalBuddy -n -nc -ps "/ | /" -eep "notes,location,attendees" -nrd -ea -li 2 eventsToday 2>/dev/null)

if [ -z "$EVENTS" ]; then
  EVENTS="No upcoming events"
fi

# Join multiple lines with a bullet character if needed, 
# but icalBuddy usually handles the layout well.

sketchybar --set clock.events label="$EVENTS"
