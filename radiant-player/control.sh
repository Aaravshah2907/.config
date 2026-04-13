#!/bin/bash

PY="$(dirname "$(realpath "$0")")/queue.py"
NOTIFY="$(dirname "$(realpath "$0")")/notify.sh"

cmd="$1"

# ---------- CONTROLS ----------
notify_syl() {
    local event="$1"
    local title=$($PY status 2>/dev/null | sed -n '1p' | cut -d'│' -f2- | xargs)
    bash "$NOTIFY" "$event" "$title"
}

case "$cmd" in
    toggle)
        /opt/homebrew/bin/python3 "$PY" toggle
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        # Check if now playing or paused
        is_paused=$($PY status_json 2>/dev/null | /opt/homebrew/bin/jq -r '.paused')
        if [ "$is_paused" == "true" ]; then
            notify_syl "Paused"
        else
            notify_syl "Playing"
        fi
        ;;
    next)
        /opt/homebrew/bin/python3 "$PY" next
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        notify_syl "Playing"
        ;;
    prev)
        /opt/homebrew/bin/python3 "$PY" prev
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        notify_syl "Playing"
        ;;
    seekf)
        /opt/homebrew/bin/python3 "$PY" seek 5
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        ;;
    seekb)
        /opt/homebrew/bin/python3 "$PY" seek -5
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        ;;
esac

exit 0
