#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Fetch current weather (Condition and Temperature)
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Set the single weather line in the popup
sketchybar --set clock.weather label="$WEATHER_DATA"
