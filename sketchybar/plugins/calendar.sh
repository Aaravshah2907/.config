#!/bin/bash

# We will try to get the next event using icalBuddy if installed.
# If not installed, we will use a basic AppleScript fallback.

if command -v icalBuddy &> /dev/null; then
  # Gets the first event happening today that hasn't finished yet
  # -nc = no calendar names, -nrd = no relative dates, -ea = exclude all day events
  NEXT_EVENT=$(icalBuddy -nc -nrd -ea -n -b "" -eed -limitItems 1 eventsToday | head -n 1)
  
  if [ -n "$NEXT_EVENT" ]; then
    # Format might be something like: "Meeting with Client (10:00 - 11:00)"
    LABEL="$NEXT_EVENT"
  else
    # No upcoming events today
    LABEL="No Events Today"
  fi
else
  # Fallback to a basic AppleScript fetching the first upcoming event today across all calendars
  NEXT_EVENT=$(osascript -e '
    set now to current date
    set endOfDay to now
    set time of endOfDay to (23 * hours + 59 * minutes + 59)
    
    set upcomingEvents to {}
    tell application "Calendar"
      repeat with cal in calendars
        try
          set eventList to (every event of cal whose start date is greater than now and start date is less than endOfDay and allday event is false)
          repeat with ev in eventList
            set end of upcomingEvents to {summary of ev, start date of ev}
          end repeat
        end try
      end repeat
    end tell
    
    -- Find the earliest one if any
    set nextEventName to ""
    if (count of upcomingEvents) > 0 then
      set earliestTime to item 2 of item 1 of upcomingEvents
      set nextEventName to item 1 of item 1 of upcomingEvents
      repeat with i from 2 to count of upcomingEvents
        set evTime to item 2 of item i of upcomingEvents
        if evTime < earliestTime then
          set earliestTime to evTime
          set nextEventName to item 1 of item i of upcomingEvents
        end if
      end repeat
    end if
    
    if nextEventName is not "" then
      return nextEventName
    else
      return "No Events Today"
    end if
  ' 2>/dev/null)

  if [ -n "$NEXT_EVENT" ]; then
    LABEL="$NEXT_EVENT"
  else
    # If osascript fails (e.g. lack of permissions), fallback to date
    LABEL=$(date '+%a %d %b')
  fi
fi

sketchybar --set "$NAME" label="$LABEL"
