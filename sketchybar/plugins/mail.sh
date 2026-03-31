#!/usr/bin/env bash

# Fetch unread count from Apple Mail
COUNT=$(osascript -e 'tell application "Mail" to get unread count of inbox' 2>/dev/null)

if [ -z "$COUNT" ]; then
  COUNT="0"
fi

sketchybar --set $NAME label="$COUNT" 
