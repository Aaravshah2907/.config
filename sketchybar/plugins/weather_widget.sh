#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"

# Handle hover for Weather popup
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

# Fetch detailed weather data
WEATHER_DATA=$(curl -s "wttr.in/?format=%C|%t|%h|%w|%f|%l|%m" || echo "Error")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]] || [[ "$WEATHER_DATA" == *"Unknown"* ]]; then
  sketchybar --set weather label="--" icon="?"
  exit 0
fi

# Split by pipe
IFS='|' read -r CONDITION TEMP HUMIDITY WIND FEELS_LIKE LOCATION MOON <<< "$WEATHER_DATA"

LOWER=$(echo "$CONDITION" | tr '[:upper:]' '[:lower:]')

if [[ "$LOWER" == *"thunder"* ]] || [[ "$LOWER" == *"storm"* ]]; then
  COLOR="$VIOLET"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"snow"* ]] || [[ "$LOWER" == *"blizzard"* ]] || [[ "$LOWER" == *"ice"* ]] || [[ "$LOWER" == *"hail"* ]]; then
  COLOR="$PRES_MIST"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"rain"* ]] || [[ "$LOWER" == *"drizzle"* ]] || [[ "$LOWER" == *"shower"* ]]; then
  COLOR="$PRES_GLACIAL"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"fog"* ]] || [[ "$LOWER" == *"mist"* ]] || [[ "$LOWER" == *"haze"* ]]; then
  COLOR="$SPREN_LOGIC"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"clear"* ]] || [[ "$LOWER" == *"sunny"* ]]; then
  COLOR="$SPREN_GLORY"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"partly cloudy"* ]]; then
  COLOR="$PRES_SILVER"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"cloud"* ]] || [[ "$LOWER" == *"overcast"* ]]; then
  COLOR="$SLATE"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"dust"* ]] || [[ "$LOWER" == *"sand"* ]] || [[ "$LOWER" == *"smoke"* ]]; then
  COLOR="$SPREN_PEAK"
  CONDITION_ICON=""
else
  COLOR="$WHITE"
  CONDITION_ICON="🌤️"
fi

# Strip the plus sign from temps for cleaner display
TEMP=$(echo "$TEMP" | sed 's/+//')
FEELS_LIKE=$(echo "$FEELS_LIKE" | sed 's/+//')

# Main Bar
sketchybar --set weather \
           icon="$CONDITION_ICON" \
           icon.color="$COLOR" \
           label="$TEMP" \
           label.color="$COLOR"

# Popup Details
# Parse short location (just the first part before comma)
SHORT_LOC=$(echo "$LOCATION" | awk -F, '{print $1}')

sketchybar --set weather.location label="$SHORT_LOC" \
           --set weather.condition label="$CONDITION" icon="$CONDITION_ICON" icon.color="$COLOR" label.color="$COLOR" \
           --set weather.feels label="Feels like $FEELS_LIKE" \
           --set weather.humidity label="$HUMIDITY Humidity" \
           --set weather.wind label="$WIND Wind" \
           --set weather.moon label="Phase: $MOON"

# Notify Yazi and WhatsApp on extreme weather (Storm, Rain, Snow, Blizzard)
if echo "$LOWER" | grep -iqE "storm|rain|snow|blizzard"; then
  if [ ! -f "/tmp/syl_weather_warn" ]; then
    ya pub plugin --str "syl-notify custom '󰀡 Highstorm' 'Aarav, expect $CONDITION! ($HUMIDITY Humidity, $WIND Wind)'" >/dev/null 2>&1
    alert "🌧️ Weather Alert: Expect $CONDITION today! ($HUMIDITY humidity, $WIND wind)" &
    touch /tmp/syl_weather_warn
  fi
else
  rm -f /tmp/syl_weather_warn
fi
