#!/bin/bash
# auto-spiral.sh: ensure first split is horizontal (left/right), then spiral subsequent windows

WID="${AEROSPACE_WINDOW_ID}"
if [ -z "$WID" ]; then
    exit 0
fi

# Find workspace of newly detected window
WS=$(/opt/homebrew/bin/aerospace list-windows --all --format '%{window-id} %{workspace}' | awk -v id="$WID" '$1 == id { print $2 }')
if [ -z "$WS" ]; then
    exit 0
fi

# Count windows on this workspace
COUNT=$(/opt/homebrew/bin/aerospace list-windows --workspace "$WS" --count)

if [ "$COUNT" -le 1 ]; then
    # First window on workspace: ensure container is horizontal
    /opt/homebrew/bin/aerospace layout --window-id "$WID" tiles horizontal
else
    # Subsequent windows: alternate split to form spiral
    /opt/homebrew/bin/aerospace split --window-id "$WID" opposite
fi
