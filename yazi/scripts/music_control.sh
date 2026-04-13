#!/bin/bash

PY="$HOME/.config/yazi/scripts/music_queue.py"
NOTIFY="$HOME/.config/yazi/scripts/music_notify.sh"

cmd="$1"

case "$cmd" in
    toggle)
        /opt/homebrew/bin/python3 "$PY" toggle
        sleep 0.1
        ya emit redraw
        ya pub music-update
        sleep 0.4
        ya emit redraw
        ya pub music-update
        ;;
    next)
        /opt/homebrew/bin/python3 "$PY" next
        sleep 0.5
        ya emit redraw
        ya pub music-update
        ;;
    prev)
        /opt/homebrew/bin/python3 "$PY" prev
        sleep 0.5
        ya emit redraw
        ya pub music-update
        ;;
    seekf)
        /opt/homebrew/bin/python3 "$PY" seek 5
        sleep 0.1
        ya emit redraw
        ya pub music-update
        ;;
    seekb)
        /opt/homebrew/bin/python3 "$PY" seek -5
        sleep 0.1
        ya emit redraw
        ya pub music-update
        ;;
esac

exit 0
