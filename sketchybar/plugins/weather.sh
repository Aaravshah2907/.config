#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"

# Fetch detailed weather data: condition, temperature, humidity, wind, feels-like
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t+%h+%w+%f")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Split the data into individual components
IFS=' ' read -r -a weather_parts <<< "$WEATHER_DATA"

# Extract each part
RAW_CONDITION=$(curl -s "wttr.in/?format=%C" | xargs)
HUMIDITY=$(curl -s "wttr.in/?format=%h")
WIND=$(curl -s "wttr.in/?format=%w")

# Cosmere weather color mapping with condition-specific icons
LOWER=$(echo "$RAW_CONDITION" | tr '[:upper:]' '[:lower:]')

if [[ "$LOWER" == *"storm"* ]] || [[ "$LOWER" == *"thunder"* ]]; then
  CONDITION="Storm"
  COLOR="$DEEP_SAPPHIRE"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"rain"* ]] || [[ "$LOWER" == *"drizzle"* ]] || [[ "$LOWER" == *"shower"* ]]; then
  CONDITION="Rain"
  COLOR="$PRES_GLACIAL"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"snow"* ]] || [[ "$LOWER" == *"ice"* ]] || [[ "$LOWER" == *"sleet"* ]] || [[ "$LOWER" == *"blizzard"* ]]; then
  CONDITION="Snow"
  COLOR="$PRES_SILVER"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"dust"* ]] || [[ "$LOWER" == *"sand"* ]] || [[ "$LOWER" == *"smoke"* ]]; then
  CONDITION="Dust"
  COLOR="$SPREN_PEAK"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"clear"* ]] || [[ "$LOWER" == *"sunny"* ]]; then
  CONDITION="Clear"
  COLOR="$SPREN_SIBLING"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"cloud"* ]] || [[ "$LOWER" == *"overcast"* ]]; then
  CONDITION="Cloudy"
  COLOR="$RUIN_ASH"
  CONDITION_ICON=""
elif [[ "$LOWER" == *"mist"* ]] || [[ "$LOWER" == *"fog"* ]] || [[ "$LOWER" == *"haze"* ]]; then
  CONDITION="Mist"
  COLOR="$PRES_MIST"
  CONDITION_ICON=""
else
  CONDITION="$RAW_CONDITION"
  COLOR="$WHITE"
  CONDITION_ICON="🌤️"
fi

# Format the weather data for display
WEATHER_DISPLAY1=$(printf "%s %s |  %s | 󱪉 %s\n" "$CONDITION_ICON" "$CONDITION" "$HUMIDITY" "$WIND")

# Set the weather line in the popup
sketchybar --set clock.weather1 label="$WEATHER_DISPLAY1" label.color="$COLOR"
# Also update the main clock time color to match weather condition
sketchybar --set clock label.color="$COLOR" icon.color="$COLOR"

# Notify Yazi on Storm
if echo "$LOWER" | grep -iq "storm"; then
  if [ ! -f "/tmp/syl_storm_warn" ]; then
    ya pub plugin --str "syl-notify custom '󰀡 Highstorm' 'Aarav, a storm approaches! The sky shows: $WEATHER_DISPLAY1'" >/dev/null 2>&1
    touch /tmp/syl_storm_warn
  fi
else
  rm -f /tmp/syl_storm_warn
fi

# WhatsApp Notify on extreme weather (Storm, Rain, Snow, Blizzard)
if echo "$LOWER" | grep -iqE "storm|rain|snow|blizzard"; then
  if [ ! -f "/tmp/wacli_weather_warn" ]; then
    alert "🌧️ Weather Alert: Expect $CONDITION today! ($HUMIDITY humidity, $WIND wind)" &
    touch /tmp/wacli_weather_warn
  fi
else
  rm -f /tmp/wacli_weather_warn
fi
