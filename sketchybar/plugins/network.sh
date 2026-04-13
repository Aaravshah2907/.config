#!/usr/bin/env bash

# WINDRUNNER - Spren Bond (Network) Plugin
# Monitors the connection to the physical and spiritual realms

# Find the Wi-Fi interface specifically
WIFI_INTERFACE=$(networksetup -listallhardwareports | grep -A 1 "Wi-Fi" | grep "Device:" | awk '{print $2}')
[ -z "$WIFI_INTERFACE" ] && WIFI_INTERFACE="en0"

# Get SSID for Wi-Fi
SSID=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F' : ' '/ SSID :/ {print $2}')

# --- HONOR MAPPING (Translate redacted/hidden SSIDs) ---
# Add your known redacted SSIDs or BSSIDs here
case "$SSID" in
    "<redacted>"|""|"Hidden") 
        # Check BSSID if SSID is hidden (optional but more precise)
        BSSID=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F' : ' '/ BSSID :/ {print $2}')
        SSID="󰖟 University"
        ;;
    "eduroam")
        SSID="󰖟 eduroam"
        ;;
esac

# Fallback to general interface if no SSID after mapping
if [ -z "$SSID" ]; then
    CURRENT_INT=$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')
    if [ -z "$CURRENT_INT" ]; then
        sketchybar --set control_center icon=󰤭 label="Disconnected"
        sketchybar --set cc.net.0.ssid label="No Bond" icon=󰤭
        sketchybar --set cc.net.0.speed label="0 Mbps"
        exit 0
    fi
    
    # Check if this interface has an IP
    HAS_IP=$(ifconfig "$CURRENT_INT" 2>/dev/null | grep "inet ")
    if [ -z "$HAS_IP" ]; then
        sketchybar --set control_center icon=󰤭 label="Searching..."
        exit 0
    fi

    ICON=󰈀
    LABEL="Ethernet"
    SSID="Physical Link"
else
    ICON=󱐋
    LABEL="$SSID"
fi

# Get Link Speed (Tx Rate) using wdutil safely
SPEED=$(wdutil info 2>/dev/null | grep "Tx Rate" | head -n 1 | awk '{print $4}')
[ -z "$SPEED" ] && SPEED="0"

# Update Main Bar (Spren Bond)
sketchybar --set control_center icon="$ICON" label="$LABEL" label.drawing=on

# Update Popup Details
sketchybar --set cc.net.0.ssid label="$SSID" icon="$ICON"
sketchybar --set cc.net.0.speed label="${SPEED} Mbps"
