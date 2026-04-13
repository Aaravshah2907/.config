#!/bin/bash

PY="$HOME/.config/yazi/scripts/music_queue.py"

while true; do
    clear

    status=$($PY status 2>/dev/null | head -n 1)

    # shorten long titles
    title=$(echo "$status" | cut -d'|' -f2 | cut -c1-50)

    state=$(echo "$status" | cut -d'|' -f1)

    echo "🎵 $state | $title"
    echo ""
    echo "[Space] Play/Pause  [n] Next  [p] Prev  [q] Quit"

    read -rsn1 key

    case "$key" in
        " ")
            $PY toggle
            ;;
        n)
            $PY next
            ;;
        p)
            $PY prev
            ;;
        q)
            exit
            ;;
    esac
done
