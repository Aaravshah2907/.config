#!/usr/bin/env bash

# We use lsappinfo to get badge count for WhatsApp, suppressing errors
COUNT=$(lsappinfo info -app WhatsApp 2>/dev/null | grep "StatusLabel" | awk -F'"' '{print $2}' || echo "")
if [ -z "$COUNT" ]; then
  COUNT="0"
fi
sketchybar --set $NAME label="$COUNT" icon=󰖣
