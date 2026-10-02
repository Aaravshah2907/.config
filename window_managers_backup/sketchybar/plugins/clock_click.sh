#!/bin/bash

STATE_FILE="/tmp/sketchybar_calendar_visible"

if [ -f "$STATE_FILE" ]; then
  # Hide calendar lines
  rm "$STATE_FILE"
  for i in {1..8}
  do
    sketchybar --set clock.calendar.line.$i drawing=off
  done
else
  # Show calendar lines
  touch "$STATE_FILE"
  
  # Read cal output line by line
  # Use standard loop for compatibility with older bash on macOS
  IFS=$'\n' read -d '' -r -a CAL_LINES < <(cal)
  
  for i in {1..8}
  do
    LINE_INDEX=$((i - 1))
    LINE_TEXT="${CAL_LINES[$LINE_INDEX]}"
    # If the line is empty, display space
    if [ -z "$LINE_TEXT" ]; then
      LINE_TEXT=" "
    fi
    sketchybar --set clock.calendar.line.$i drawing=on label="$LINE_TEXT"
  done
fi
