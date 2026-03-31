#!/usr/bin/env bash

# Assumes gh cli is installed and authenticated
# Get unread notifications count
COUNT=$(gh api notifications --cache 1m | jq '. | length' 2>/dev/null || echo "0")

if [ "$COUNT" -gt 0 ]; then
  sketchybar --set $NAME label="$COUNT" icon=󰂚
else
  # Hide label when 0 unread
  sketchybar --set $NAME label="" icon=󰂜
fi
