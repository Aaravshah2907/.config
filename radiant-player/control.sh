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
        python3 "$PY" toggle
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        # Call status_json once to get both state and title
        status_json=$(python3 "$PY" status_json 2>/dev/null)
        is_paused=$(echo "$status_json" | jq -r '.paused')
        title=$(echo "$status_json" | jq -r '.title // ""')
        bash "$NOTIFY" "$([ "$is_paused" == "true" ] && echo Paused || echo Playing)" "$title"
        ;;
    next)
        python3 "$PY" next
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        notify_syl "Playing"
        ;;
    prev)
        python3 "$PY" prev
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        notify_syl "Playing"
        ;;
    seekf)
        python3 "$PY" seek 5
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        ;;
    seekb)
        python3 "$PY" seek -5
        [ -n "$YAZI_ID" ] && ya emit redraw >/dev/null 2>&1
        ;;
esac

exit 0
