#!/bin/bash

# Clean up music temp log file if creation time is older than 24 hours
LOG_FILE="/tmp/sketchybar_music.log"
if [ -f "$LOG_FILE" ]; then
  find "$LOG_FILE" -type f -Bmin +1440 -delete 2>/dev/null
fi

YAZI_SCRIPT="/Users/aaravshah2975/.config/radiant-player/queue.py"

# Check if Radiant Player is running
MPV_STATUS=$(python3 "$YAZI_SCRIPT" status_json 2>/dev/null)
if [[ -n "$MPV_STATUS" && $(echo "$MPV_STATUS" | jq -r '.running') == "true" ]]; then
  # Launch dashboard in terminal
  osascript <<EOF
tell application "iTerm"
    set foundSession to false
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if (name of s) contains "radiant-player" then
                    tell t to select
                    set index of w to 1
                    set foundSession to true
                    exit repeat
                end if
            end repeat
            if foundSession is true then exit repeat
        end repeat
        if foundSession is true then exit repeat
    end repeat

    if foundSession is false then
        if (count of windows) > 0 then
            tell current window
                set newTab to (create tab with default profile)
                tell current session of newTab
                    write text "~/.config/radiant-player/dashboard.sh"
                end tell
            end tell
        else
            set newWindow to (create window with default profile)
            tell current session of newWindow
                write text "~/.config/radiant-player/dashboard.sh"
            end tell
        end if
    end if
    activate
end tell
EOF
else
  # Default to launching/focusing Spotify
  open -a Spotify
fi
