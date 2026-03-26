#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 1. Start mpv - ensure we use the full path if brew is weird
/opt/homebrew/bin/mpv --no-terminal "$1" &

# 2. Wait for mpv to actually create a window and for yabai to see it
# We look for the window ID specifically belonging to mpv
for i in {1..30}; do
    MPV_WIN_ID=$(yabai -m query --windows | jq '.[] | select(.app == "mpv") | .id' | head -n 1)
    if [ -n "$MPV_WIN_ID" ]; then
        break
    fi
    sleep 0.1
done

# 3. Adjust the ratio. 
# We target the window that was there BEFORE (the terminal) 
# to take up 25%, leaving 75% for mpv.
yabai -m window --toggle split # Optional: forces a vertical split if needed
yabai -m window --ratio abs:0.75

# 4. Instead of waiting on a potentially unstable PID, 
# we loop until the mpv window is gone.
while [ -n "$(yabai -m query --windows | jq '.[] | select(.app == "mpv") | .id')" ]; do
    sleep 2
done

# 5. Reset the layout
yabai -m window --ratio abs:0.50
