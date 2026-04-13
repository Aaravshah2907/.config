#!/bin/bash

PY="$(dirname "$(realpath "$0")")/queue.py"

while true; do
    HEADER=$($PY status)

    LIST=$($PY list)

    choice=$(echo "$LIST" | fzf \
        --ansi \
        --delimiter=" | " \
        --height=100% --border=rounded \
        --header="$HEADER"$'\n'"[ENT] Play | [C-D] Del | [C-J/K] Move | [C-R] Rand | [C-U] Sort"$'\n'"[C-S] Save | [C-O] Load | [Q] Quit" \
        --prompt="🎵 Queue > " \
        --bind "enter:execute-silent($PY play_index {1})+reload($PY list)" \
        --bind "ctrl-d:execute-silent($PY remove {1})+reload($PY list)" \
        --bind "ctrl-j:execute-silent($PY move {1} 1)+reload($PY list)+down" \
        --bind "ctrl-k:execute-silent($PY move {1} -1)+reload($PY list)+up" \
        --bind "ctrl-r:execute-silent($PY shuffle)+reload($PY list)" \
        --bind "ctrl-u:execute-silent($PY sort)+reload($PY list)" \
        --bind "ctrl-s:execute-silent(echo -n 'Save as: ' && read n && $PY save \"$n\")+reload($PY list)" \
        --bind "ctrl-o:execute-silent(f=$(ls ~/.config/mpv/playlists | fzf) && $PY load \"$f\")+reload($PY list)" \
        --bind "ctrl-f:reload($PY list)" \
        --color='hl:green:underline,pointer:red:bold')

    [ -z "$choice" ] && break
done
