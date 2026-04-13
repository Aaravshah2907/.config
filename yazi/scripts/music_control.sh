#!/bin/bash

PY="$HOME/.config/yazi/scripts/music_queue.py"
NOTIFY="$HOME/.config/yazi/scripts/music_notify.sh"

cmd="$1"

case "$cmd" in
    toggle)
        /opt/homebrew/bin/python3 "$PY" toggle
        ya emit redraw
        ;;
    next)
        /opt/homebrew/bin/python3 "$PY" next
        ya emit redraw
        ;;
    prev)
        /opt/homebrew/bin/python3 "$PY" prev
        ya emit redraw
        ;;
    seekf)
        /opt/homebrew/bin/python3 "$PY" seek 5
        ya emit redraw
        ;;
    seekb)
        /opt/homebrew/bin/python3 "$PY" seek -5
        ya emit redraw
        ;;
esac

exit 0
