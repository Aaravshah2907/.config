#!/bin/bash
# ~/.config/yazi/scripts/edit_music_queue.sh
PYTHON_SCRIPT="/Users/aaravshah2975/.config/yazi/scripts/music_queue.py"
JQ="/opt/homebrew/bin/jq"

while true; do
    # Get current playback status for the header
    status_json=$(/opt/homebrew/bin/python3 "$PYTHON_SCRIPT" status_json)
    is_running=$(echo "$status_json" | "$JQ" -r '.running')
    
    if [ "$is_running" == "true" ]; then
        title=$(echo "$status_json" | "$JQ" -r '.title')
        paused=$(echo "$status_json" | "$JQ" -r '.paused')
        if [ "$paused" == "true" ]; then
            indicator="󰏤 Paused"
        else
            indicator=" Playing"
        fi
        status_line="Current: $indicator - $title"
    else
        status_line="Status: 󰓛 Idle"
    fi

    # Get current queue
    list=$(/opt/homebrew/bin/python3 "$PYTHON_SCRIPT" list)
    
    # fzf with enhanced UI and Rearrange (Ctrl-j/k)
    # Using multiple delete bindings: del, backspace, ctrl-d, ctrl-x
    # If list is empty, fzf will show nothing but still allow Ctrl-O
    choice=$(echo "$list" | fzf \
        --ansi \
        --reverse --height=100% --border=rounded \
        --header-first --header=" $status_line"$'\n'" [ENT] Play | [C-D] Del | [C-J/K] Move | [C-R] Rand | [C-U] Sort"$'\n'" [C-S] Save | [C-O] Load | [C-F] Sync | [?] Toggle Info" \
        --prompt="󰎆 Music Queue > " \
        --preview="/opt/homebrew/bin/python3 $PYTHON_SCRIPT info {1}" \
        --preview-window="right:25%:wrap:border-left:hidden" \
        --bind "?:toggle-preview" \
        --bind "del:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT remove {1})+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "backspace:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT remove {1})+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-d:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT remove {1})+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-x:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT remove {1})+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-j:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT move {1} 1)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)+down" \
        --bind "ctrl-k:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT move {1} -1)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)+up" \
        --bind "ctrl-r:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT shuffle)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-u:execute-silent(/opt/homebrew/bin/python3 $PYTHON_SCRIPT sort)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-f:reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-s:execute(/Users/aaravshah2975/.config/yazi/scripts/save_playlist.sh)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "ctrl-o:execute(/Users/aaravshah2975/.config/yazi/scripts/load_playlist.sh)+reload(/opt/homebrew/bin/python3 $PYTHON_SCRIPT list)" \
        --bind "enter:accept" \
        --color='header:italic:yellow,prompt:bold:blue,pointer:bold:red,hl:bold:green')
    
    # If no choice made (ESC) or empty choice
    if [ -z "$choice" ]; then
        break
    fi
    
    # Switch to the selected song
    index=$(echo "$choice" | awk '{print $1}')
    # Only try to play if index is a number
    if [[ "$index" =~ ^[0-9]+$ ]]; then
        /opt/homebrew/bin/python3 "$PYTHON_SCRIPT" play_index "$index"
    fi
done
