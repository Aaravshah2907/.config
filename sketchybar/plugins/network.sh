#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

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

# Get SSID
SSID=$(get_ssid_with_timeout)

# Detect internal IP
INTERNAL_IP=$(ifconfig "$WIFI_INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')

# Fallback: If shortcuts timed out/failed but we have an IP, use ipconfig SSID or generic fallback
if [ -z "$SSID" ] && [ -n "$INTERNAL_IP" ]; then
  SSID=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F': ' '/SSID/ {print $2}')
  if [ -z "$SSID" ] || [ "$SSID" = "<redacted>" ]; then
    SSID="University"
  fi
fi

# General Location/SSID Logic
if [ -n "$SSID" ]; then
    # Handle redacted or hidden SSIDs
    if [[ "$SSID" == "<redacted>" || "$SSID" == "" ]]; then
        LOCATION="University"
    else
        LOCATION="$SSID"
    fi
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

/opt/homebrew/bin/sketchybar --set control_center icon="$ICON" label="$LOCATION" icon.color="$COLOR" label.color="$COLOR"
