#!/bin/bash
STATE_FILE="$HOME/.config/skhd/.vlc_speed"

# Check if VLC is running
if ! pgrep -x "VLC" > /dev/null; then
    exit 0
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "1.0" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "1.0" ]; then
    NEW_STATE="1.5"
    KEYS='keystroke "="
    delay 0.1
    keystroke "=" using command down'
else
    NEW_STATE="1.0"
    KEYS='keystroke "="'
fi

osascript <<EOF
tell application "System Events"
    set activeApp to name of first application process whose frontmost is true
end tell

tell application "VLC" to activate
delay 0.1

tell application "System Events"
    $KEYS
end tell

if activeApp is not "VLC" then
    tell application activeApp to activate
end if
EOF

echo "$NEW_STATE" > "$STATE_FILE"
