#!/bin/bash

# Toggle Bitwarden visibility
/usr/bin/osascript <<'EOF'
tell application "System Events"
    if (exists process "Bitwarden") then
        tell process "Bitwarden"
            if frontmost then
                set visible to false
            else
                set frontmost to true
                set visible to true
            end if
        end tell
    else
        tell application "Bitwarden" to activate
    end if
end tell
EOF
