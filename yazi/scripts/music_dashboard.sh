#!/bin/bash

PY="$HOME/.config/yazi/scripts/music_queue.py"

selected=0
lines=()

# ---------- LOAD QUEUE ----------
load_queue() {
    lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done < <($PY list 2>/dev/null)
}

# ---------- DRAW ----------
draw() {
    clear

    echo "🎵 Now Playing"
    echo "--------------------------------"
    $PY status 2>/dev/null
    echo ""

    echo "📜 Queue"
    echo "--------------------------------"

    for i in "${!lines[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo "> ${lines[$i]}"
        else
            echo "  ${lines[$i]}"
        fi
    done

    echo ""
    echo "[↑/↓] Move  [ENTER] Play/Pause"
    echo "[d] Delete  [j/k] Move"
    echo "[s] Shuffle  [r] Refresh"
    echo "[Ctrl+S] Save  [Ctrl+L] Load"
    echo "[q] Quit"
}

# ---------- INIT ----------
load_queue
draw

# ---------- LOOP ----------
while true; do
    read -rsn1 key

    case "$key" in
        q)
            clear
            exit
            ;;

        # Arrow keys
        $'\x1b')
            read -rsn2 key2
            case "$key2" in
                "[A") ((selected--)) ;;
                "[B") ((selected++)) ;;
            esac
            ;;

        # ENTER
        "")
            current=$($PY current_index 2>/dev/null)

            if [ "$selected" == "$current" ]; then
                $PY toggle
            else
                $PY play_index "$selected"
            fi
            ;;

        d)
            $PY remove "$selected"
            load_queue
            ;;

        j)
            $PY move "$selected" 1
            ((selected++))
            load_queue
            ;;

        k)
            $PY move "$selected" -1
            ((selected--))
            load_queue
            ;;

        s)
            $PY shuffle
            load_queue
            ;;

        r)
            # manual refresh only
            load_queue
            ;;

        # Ctrl+S
        $'\x13')
            echo ""
            read -p "Save as: " name
            $PY save "$name"
            ;;

        # Ctrl+L
        $'\x0c')
            selected_pl=$(ls ~/.config/mpv/playlists | fzf --prompt="Load Playlist > ")
            if [ -n "$selected_pl" ]; then
                $PY load "$selected_pl"
                selected=0
                load_queue
            fi
            ;;
    esac

    # ---------- SAFE BOUNDS ----------
    count=${#lines[@]}
    ((count <= 0)) && selected=0
    ((selected < 0)) && selected=0
    ((selected >= count)) && selected=$((count - 1))

    draw
done
