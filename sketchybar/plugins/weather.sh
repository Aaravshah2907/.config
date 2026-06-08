#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"
# Fetch current weather (Condition and Temperature)
WEATHER_DATA=$(curl -s "wttr.in/?format=%C+%t")

if [ -z "$WEATHER_DATA" ] || [[ "$WEATHER_DATA" == *"Error"* ]]; then
  WEATHER_DATA="Weather Unavailable"
fi

# Determine color based on common Indian weather conditions (Pilani, Rajasthan, Mumbai)
LOWER=$(echo "$WEATHER_DATA" | tr '[:upper:]' '[:lower:]')
if echo "$LOWER" | grep -iq "rain"; then
  COLOR="$SAPPHIRE"   # Light blue for rain
elif echo "$LOWER" | grep -iq "thunderstorm\|storm"; then
  COLOR="$DEEP_NIGHT" # Dark blue for thunderstorms
elif echo "$LOWER" | grep -iq "clear\|sunny"; then
  COLOR="$HONOR_GOLD" # Gold for clear skies
elif echo "$LOWER" | grep -iq "cloud"; then
  COLOR="$SLATE"      # Slate for clouds
elif echo "$LOWER" | grep -iq "haze"; then
  COLOR="$AMBER"      # Amber for haze
else
  COLOR="$WHITE"
fi

# Set the weather line in the popup
sketchybar --set clock.weather label="$WEATHER_DATA" label.color="$COLOR"
# Also update the main clock time color to match weather condition
sketchybar --set clock label.color="$COLOR" icon.color="$COLOR"
