#!/bin/bash
# ~/.config/yazi/scripts/edit_music_queue.sh
PYTHON_SCRIPT="/Users/aaravshah2975/.config/yazi/scripts/music_queue.py"

while true; do
    # Get current queue
    list=$($PYTHON_SCRIPT list)
    if [ -z "$list" ]; then
        echo "Musical silence... (Queue is empty)"
        echo "Press any key to exit."
        read -n 1
        break
    fi
    
    # Selection format: " 0 | * | Song Title"
    # Using fzf for interactive selection and deletion
    # {1} is the index
    choice=$(echo "$list" | fzf \
        --ansi \
    --header="[ENTER] Switch to track | [DEL] Remove from queue | [ESC] Exit" \
        --prompt="🎵 Music Queue > " \
        --reverse --height=100% \
        --bind "del:execute-silent($PYTHON_SCRIPT remove {1})+reload($PYTHON_SCRIPT list)" \
        --bind "enter:accept")
    
    # If no choice made (ESC)
    if [ -z "$choice" ]; then
        break
    fi
    
    # Switch to the selected song
    index=$(echo "$choice" | awk '{print $1}')
    $PYTHON_SCRIPT play_index "$index"
done
