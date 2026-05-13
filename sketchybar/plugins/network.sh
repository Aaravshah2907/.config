#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

# Find the Wi-Fi interface
WIFI_INTERFACE=$(networksetup -listallhardwareports | grep -A 1 "Wi-Fi" | grep "Device:" | awk '{print $2}')
[ -z "$WIFI_INTERFACE" ] && WIFI_INTERFACE="en0"

# Get SSID
SSID=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F' : ' '/ SSID :/ {print $2}')

# Detect internal IP for BITS Pilani mapping
INTERNAL_IP=$(ifconfig "$WIFI_INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')

# General Location/SSID Logic
#if [[ "$INTERNAL_IP" =~ ^172\.1[6789]\. ]] || [[ "$INTERNAL_IP" =~ ^172\.2[0-7]\. ]] || [[ "$INTERNAL_IP" =~ ^172\.31\. ]] || [[ "$INTERNAL_IP" =~ ^10\. ]]; then
    #LOCATION="BITS Pilani"
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

# Icon and Color Logic
ICON="󰤨"
COLOR="$SAPPHIRE"

if [ "$LOCATION" = "Severed Bond" ]; then
    ICON="󰤭"
    COLOR="$RED"
fi

/opt/homebrew/bin/sketchybar --set control_center icon="$ICON" label="$LOCATION" icon.color="$COLOR" label.color="$COLOR"
