#!/bin/bash

# Fetch current weather (Condition and Temperature)
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t")

if [ -z "$WEATHER_DATA" ]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Set the single weather line in the popup
sketchybar --set clock.weather label="$WEATHER_DATA"
