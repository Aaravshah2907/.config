#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Fetch detailed weather data: condition, temperature, humidity, wind, feels-like
WEATHER_DATA=$(curl -s "wttr.in/?format=%t+%f")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Split the data into individual components
IFS=' ' read -r -a weather_parts <<< "$WEATHER_DATA"

# Extract each part
TEMPERATURE=${weather_parts[0]}
FEELS_LIKE=${weather_parts[1]}

# Determine day/night based on current time
CURRENT_HOUR=$(date +%H)
if (( CURRENT_HOUR >= 6 && CURRENT_HOUR < 18 )); then
  ICON="󰖨"
  COLOR="$HONOR_GOLD"
else
  ICON=""
  COLOR="$PRES_MIST"
fi

# Format the weather data for display
WEATHER_DISPLAY2=$(echo "$ICON $TEMPERATURE°C |  $FEELS_LIKE°C")

# Set the weather line in the popup
sketchybar --set clock.weather2 label="$WEATHER_DISPLAY2" label.color="$COLOR"
