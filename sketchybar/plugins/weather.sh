#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"
# Fetch current weather (Condition and Temperature)
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Cosmere weather color mapping
LOWER=$(echo "$WEATHER_DATA" | tr '[:upper:]' '[:lower:]')
if echo "$LOWER" | grep -iq "rain"; then
  COLOR="$PRES_GLACIAL"       # Preservation glacial — calm falling water
elif echo "$LOWER" | grep -iq "thunderstorm\|storm"; then
  COLOR="$RUIN_OBSIDIAN"      # Ruin's volcanic black — destruction descends
elif echo "$LOWER" | grep -iq "clear\|sunny"; then
  COLOR="$SPREN_SIBLING"      # Sibling/Urithiru crystal amber — tower warmth
elif echo "$LOWER" | grep -iq "cloud"; then
  COLOR="$RUIN_ASH"           # Ruin ash — ashfall sky
elif echo "$LOWER" | grep -iq "haze"; then
  COLOR="$RUIN_BRONZE"        # Ruin bronze — Scadrial's hazy corroded sky
else
  COLOR="$WHITE"
fi

# Set the weather line in the popup
sketchybar --set clock.weather label="$WEATHER_DATA" label.color="$COLOR"
# Also update the main clock time color to match weather condition
sketchybar --set clock label.color="$COLOR" icon.color="$COLOR"
