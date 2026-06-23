#!/usr/bin/env bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  /opt/homebrew/bin/sketchybar --set control_center popup.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  /opt/homebrew/bin/sketchybar --set control_center popup.drawing=off
  exit 0
fi

# Find the Wi-Fi interface
WIFI_INTERFACE=$(networksetup -listallhardwareports | grep -A 1 "Wi-Fi" | grep "Device:" | awk '{print $2}')
[ -z "$WIFI_INTERFACE" ] && WIFI_INTERFACE="en0"

# Function to run shortcuts with a 1.5-second timeout
get_ssid_with_timeout() {
  (
    # Start the command in the background
    /usr/bin/shortcuts run "GetSSID" 2>/dev/null &
    PID=$!
    # Start a timer in the background
    ( sleep 1.5; kill $PID 2>/dev/null ) &
    TIMER_PID=$!
    # Wait for the command to finish
    wait $PID 2>/dev/null
    # Clean up timer
    kill $TIMER_PID 2>/dev/null
  )
}

normalize_ssid() {
  printf "%s" "$1" \
    | tr -d '\r' \
    | awk 'NF { print; exit }' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

is_redacted_ssid() {
  [ -z "$1" ] || [[ "$1" == *"<redacted>"* ]]
}

get_ssid_from_fallbacks() {
  local ssid

  ssid=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F': ' '/^[[:space:]]*SSID[[:space:]]*:/ {print $2; exit}')
  ssid=$(normalize_ssid "$ssid")
  if ! is_redacted_ssid "$ssid"; then
    printf "%s" "$ssid"
    return
  fi

  ssid=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')
  ssid=$(normalize_ssid "$ssid")
  if ! is_redacted_ssid "$ssid" && [[ "$ssid" != *"not associated"* ]]; then
    printf "%s" "$ssid"
    return
  fi

  if [ -x "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" ]; then
    ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F': ' '/^[[:space:]]*SSID[[:space:]]*:/ {print $2; exit}')
    ssid=$(normalize_ssid "$ssid")
    if ! is_redacted_ssid "$ssid"; then
      printf "%s" "$ssid"
    fi
  fi
}

# Get SSID
SSID=$(get_ssid_with_timeout)
SSID=$(normalize_ssid "$SSID")

# Detect internal IP
INTERNAL_IP=$(ifconfig "$WIFI_INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')

# Fallback: If Shortcuts timed out/failed/redacted, try local Wi-Fi tools.
if is_redacted_ssid "$SSID" && [ -n "$INTERNAL_IP" ]; then
  SSID=$(get_ssid_from_fallbacks)
  SSID=$(normalize_ssid "$SSID")
fi

# General Location/SSID Logic
if ! is_redacted_ssid "$SSID"; then
    LOCATION="$SSID"
elif [ -n "$INTERNAL_IP" ]; then
    LOCATION="$INTERNAL_IP"
else
    LOCATION="Severed Bond"
fi

# Icon and Color Logic — Preservation (order/connection) vs Ruin (severed bond)
ICON="󰤨"
COLOR="$PRES_GLACIAL"                    # Glacial teal — Preservation's calm bond

if [ "$LOCATION" = "Severed Bond" ]; then
    ICON="󰤭"
    COLOR="$RUIN_MAROON"                  # Ruin's bloodline — connection destroyed
fi

/opt/homebrew/bin/sketchybar --set control_center icon="$ICON" label.drawing=off icon.color="$COLOR" \
                             --set control_center.ssid label="SSID: $LOCATION" icon=󰤨 icon.color="$COLOR"
