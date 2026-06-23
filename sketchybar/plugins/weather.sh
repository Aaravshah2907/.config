#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Fetch detailed weather data: condition, temperature, humidity, wind, feels-like
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t+%h+%w+%f")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Split the data into individual components
IFS=' ' read -r -a weather_parts <<< "$WEATHER_DATA"

# Extract each part
CONDITION=${weather_parts[0]}
TEMPERATURE=${weather_parts[1]}
HUMIDITY=${weather_parts[2]}
WIND=${weather_parts[3]}
FEELS_LIKE=${weather_parts[4]}

# Cosmere weather color mapping
LOWER=$(echo "$CONDITION" | tr '[:upper:]' '[:lower:]')
if echo "$LOWER" | grep -iq "rain"; then
  COLOR="$PRES_GLACIAL"       # Preservation glacial — calm falling water
elif echo "$LOWER" | grep -iq "thunderstorm\|storm"; then
  COLOR="$RUIN_OBSIDIAN"      # Ruin's volcanic black — destruction descends
elif echo "$LOWER" | grep -iq "clear\|sunny"; then
  COLOR="$SPREN_SIBLING"      # Sibling/Urithiru crystal amber — tower warmth
elif echo "$LOWER" | grep -iq "cloud"; then
  COLOR="$RUIN_ASH"           # Ruin ash — ashfall sky
elif echo "$LOWER" | grep -iq "haze"; then
  COLOR="$PRES_SILVER"        # Preservation silver - misty fog
else
  COLOR="$WHITE"
fi

# Format the weather data for display
WEATHER_DISPLAY="Condition: $CONDITION\n"
WEATHER_DISPLAY+="Temperature: $TEMPERATURE°C\n"
WEATHER_DISPLAY+="Humidity: $HUMIDITY%\n"
WEATHER_DISPLAY+="Wind: $WIND km/h\n"
WEATHER_DISPLAY+="Feels Like: $FEELS_LIKE°C"

# Set the weather line in the popup
sketchybar --set clock.weather label="$WEATHER_DISPLAY" label.color="$COLOR"
# Also update the main clock time color to match weather condition
sketchybar --set clock label.color="$COLOR" icon.color="$COLOR"

# Notify Yazi on Storm
if echo "$LOWER" | grep -iq "storm"; then
  if [ ! -f "/tmp/syl_storm_warn" ]; then
    ya pub plugin --str "syl-notify custom '󰀡 Highstorm' 'Aarav, a storm approaches! The sky shows: $WEATHER_DISPLAY'" >/dev/null 2>&1
    touch /tmp/syl_storm_warn
  fi
else
  rm -f /tmp/syl_storm_warn
fi
