#!/bin/bash

# --- Location: Pilani fallback, auto-detected via IP otherwise ---
LAT="28.3674"
LON="75.6044"

LOCATION=$(curl -s --max-time 2 "http://ip-api.com/json/")
IP_LAT=$(echo "$LOCATION" | jq -r '.lat')
IP_LON=$(echo "$LOCATION" | jq -r '.lon')

if [ "$IP_LAT" != "null" ] && [ -n "$IP_LAT" ]; then
  LAT="$IP_LAT"
  LON="$IP_LON"
fi

# --- Fetch current weather (extended fields) ---
DATA=$(curl -s --max-time 5 \
  "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}\
&current=temperature_2m,apparent_temperature,weather_code,precipitation,\
relative_humidity_2m,wind_speed_10m\
&hourly=precipitation_probability\
&forecast_hours=1\
&timezone=Asia%2FKolkata")

TEMP=$(echo "$DATA"   | jq -r '.current.temperature_2m')
FEELS=$(echo "$DATA"  | jq -r '.current.apparent_temperature')
CODE=$(echo "$DATA"   | jq -r '.current.weather_code')
PRECIP=$(echo "$DATA" | jq -r '.current.precipitation')
HUMID=$(echo "$DATA"  | jq -r '.current.relative_humidity_2m')
WIND=$(echo "$DATA"   | jq -r '.current.wind_speed_10m')
RAIN_PROB=$(echo "$DATA" | jq -r '.hourly.precipitation_probability[0]')

# Guard against API failure
if [ -z "$TEMP" ] || [ "$TEMP" = "null" ]; then
  sketchybar --set "$NAME" label="N/A"
  exit 0
fi

# --- Map WMO weather code to Nerd Font icon ---
case $CODE in
  0) ICON="" ;;      # Clear sky
  1|2|3) ICON="" ;;  # Clear to Overcast
  45|48) ICON="" ;;  # Fog
  51|53|55) ICON="" ;;  # Drizzle
  61|63|65) ICON="" ;;  # Rain
  71|73|75) ICON="󰖘" ;;  # Snowfall
  80|81|82) ICON="" ;;  # Rain showers
  95|96|99) ICON="󰖓" ;;  # Thunderstorm
  *) ICON="" ;;          # Unknown
esac

TEMP_LABEL="$(printf "%.0f°C" "$TEMP")"
FEELS_LABEL="$(printf "%.0f°C" "$FEELS")"
WIND_LABEL="$(printf "%.0f km/h" "$WIND")"

# --- Update popup detail items (nested in clock) ---
sketchybar \
  --set clock.weather.feels_like label="$FEELS_LABEL" \
  --set clock.weather.humidity   label="${HUMID}%" \
  --set clock.weather.wind       label="$WIND_LABEL" \
  --set clock.weather.rain       label="${RAIN_PROB}%"

# --- Update main bar item (if it still exists) and clock popup item ---
if [ "$(echo "$PRECIP > 0" | bc -l)" -eq 1 ]; then
  LABEL="${TEMP_LABEL}  ${PRECIP}mm"
  sketchybar --set "$NAME" \
    icon="$ICON" label="$LABEL" \
    icon.color=0xFF89b4fa label.color=0xFF89b4fa 2>/dev/null
  sketchybar --set clock.weather \
    icon="$ICON" label="$LABEL" \
    icon.color=0xFF89b4fa label.color=0xFF89b4fa
else
  sketchybar --set "$NAME" \
    icon="$ICON" label="$TEMP_LABEL" \
    icon.color=0xffffffff label.color=0xffffffff 2>/dev/null
  sketchybar --set clock.weather \
    icon="$ICON" label="$TEMP_LABEL" \
    icon.color=0xffffffff label.color=0xffffffff
fi
