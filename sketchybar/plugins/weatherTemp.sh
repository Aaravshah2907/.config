#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Debug: Print current directory and script path
echo "Running script: $0" >&2

# Fetch temperature and feels-like data
WEATHER_DATA=$(curl -s "wttr.in/?format=%t+%f")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  echo "Weather data unavailable" >&2
  WEATHER_DISPLAY2="󰖨 Unknown"
  COLOR="$PRES_MIST"
else
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
  WEATHER_DISPLAY2=$(printf "%s %s |  %s\n" "$ICON" "$TEMPERATURE" "$FEELS_LIKE")
fi

# Set the weather line in the popup
sketchybar --set clock.temperature label="$WEATHER_DISPLAY2" label.color="$COLOR"
