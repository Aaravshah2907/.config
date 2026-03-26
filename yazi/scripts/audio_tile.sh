#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 1. Start mpv with a forced window so yabai can tile it
# Use a specific title so we can track it reliably
/opt/homebrew/bin/mpv --no-video --force-window=immediate --title="mpv-audio" --no-terminal "$1" &

# 2. Wait for the window to appear
for i in {1..30}; do
    if yabai -m query --windows --space | jq -e '.[] | select(.title == "mpv-audio")' > /dev/null; then
        break
    fi
    sleep 0.1
done

# 3. Apply the 3/4 tiling ratio
yabai -m window --ratio abs:0.75

# 4. NEW WAIT LOGIC: Stay alive while the window exists
# This replaces 'wait $MPV_PID'
while yabai -m query --windows --space | jq -e '.[] | select(.title == "mpv-audio")' > /dev/null; do
    sleep 1
done

# 5. Reset the layout once the window is closed manually or file ends
yabai -m window --ratio abs:1.0
