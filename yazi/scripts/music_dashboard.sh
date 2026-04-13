#!/bin/bash

# Configuration
PY="$HOME/.config/yazi/scripts/music_queue.py"
selected=0
lines=()

# ---------- COLORS (Radiant / Stormlight) ----------
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[38;5;81m'     # Stormlight Glow (Sapphire)
MAGENTA='\033[38;5;141m'  # Shardblade (Violet)
GREEN='\033[38;5;121m'    # Lifebound (Emerald)
YELLOW='\033[38;5;220m'   # Honor-Gold (Heliodor)
BLUE='\033[38;5;69m'      # Windrunner Blue
RED='\033[38;5;160m'      # Voidlight (Odium)
GRAY='\033[38;5;240m'     # Rosharan Slate
NC='\033[0m'

# ---------- HELPERS ----------
load_queue() {
    lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done < <($PY list 2>/dev/null)
}

hide_cursor() { printf "\033[?25l"; }
show_cursor() { printf "\033[?25h"; }
trap show_cursor EXIT

# ---------- DRAW ----------
draw() {
    tput civis # Hide cursor
    clear

    # Header / Branding
    echo -e "${MAGENTA}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}${BOLD}│${NC}  ${CYAN}󱐌 ${BOLD}THE KNIGHTS RADIANT${NC} ${DIM}│ Journey before destination...${NC}   ${MAGENTA}${BOLD}│${NC}"
    echo -e "${MAGENTA}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""

    # Now Playing Card
    echo -e "  ${BLUE}${BOLD}󰊠 INFUSED RECORD${NC}"
    echo -e "  ${GRAY}───────────────────────────────────────────────────────${NC}"
    # Indent the status output
    $PY status 2>/dev/null | sed 's/^/  /'
    echo ""

    # Queue List
    echo -e "  ${GREEN}${BOLD}󰒺 THE HIGHSTORM QUEUE${NC} ${DIM}(${#lines[@]} spheres)${NC}"
    echo -e "  ${GRAY}───────────────────────────────────────────────────────${NC}"

    local start=$((selected - 5))
    ((start < 0)) && start=0
    local end=$((start + 12))
    ((end > ${#lines[@]})) && end=${#lines[@]}

    for ((i=start; i<end; i++)); do
        local line="${lines[$i]}"
        # Format: i | marker | name
        local idx=$(echo "$line" | cut -d'|' -f1 | xargs)
        local marker=$(echo "$line" | cut -d'|' -f2 | xargs)
        local name=$(echo "$line" | cut -d'|' -f3- | sed 's/^ //')

        if [ "$i" -eq "$selected" ]; then
            printf "  ${YELLOW}${BOLD}󱐋 %2d │ %s %-50s${NC}\n" "$idx" "$marker" "$name"
        else
            printf "    ${DIM}%2d │${NC} %s %-50s\n" "$idx" "$marker" "$name"
        fi
    done

    # Fill empty space if queue is short
    local current_lines=$((end - start))
    for ((i=current_lines; i<12; i++)); do echo ""; done

    # Legend / Shortcuts
    echo -e "  ${GRAY}───────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}󰌌${NC} ${BOLD}NAV${NC} ${DIM}[↑/↓]${NC} Move  ${DIM}[ENTER]${NC} Play  ${DIM}[n/p]${NC} Skip  ${DIM}[l]${NC} Loop"
    echo -e "  ${BLUE}󰓓${NC} ${BOLD}ADJ${NC} ${DIM}[+/-]${NC} Vol   ${DIM}[←/→]${NC} Seek  ${DIM}[j/k]${NC} Move  ${DIM}[s]${NC} Shuf"
    echo -e "  ${CYAN}󰀻${NC} ${BOLD}SYS${NC} ${DIM}[d]${NC} Del    ${DIM}[r]${NC} Refresh ${DIM}[/]${NC} Find  ${RED}[q]${NC} Quit"
}

# ---------- INIT ----------
hide_cursor
load_queue
draw

# ---------- LOOP ----------
while true; do
    read -rsn1 key

    case "$key" in
        q)  clear; exit ;;

        # Escape sequences
        $'\x1b')
            read -rsn2 key2
            case "$key2" in
                "[A") ((selected--)) ;;         # up
                "[B") ((selected++)) ;;         # down
                "[C") $PY seek 5 ;;             # right →
                "[D") $PY seek -5 ;;            # left ←
            esac
            load_queue
            ;;

        "") # ENTER
            current=$($PY current_index 2>/dev/null)
            if [ "$selected" == "$current" ]; then
                $PY toggle
            else
                $PY play_index "$selected"
                selected=$($PY current_index 2>/dev/null)
            fi
            load_queue
            selected=$($PY current_index 2>/dev/null)
            ;;

        "[") $PY seek -10 ;;
        "]") $PY seek 10 ;;
        "+") $PY volume 5 ;;
        "-") $PY volume -5 ;;
        
        n)  $PY next;   load_queue; selected=$($PY current_index 2>/dev/null) ;;
        p)  $PY prev;   load_queue; selected=$($PY current_index 2>/dev/null) ;;
        d)  $PY remove "$selected"; load_queue ;;
        j)  $PY move "$selected" 1; ((selected++)); load_queue ;;
        k)  $PY move "$selected" -1; ((selected--)); load_queue ;;
        l)  $PY loop;   load_queue ;;
        s)  $PY shuffle; load_queue ;;
        r)  load_queue ;;
        
        "/")
            choice=$(printf "%s\n" "${lines[@]}" | fzf --prompt="🔍 Search > " --height 10 --reverse)
            if [ -n "$choice" ]; then
                selected=$(echo "$choice" | awk '{print $1}')
            fi
            ;;

        $'\x13') # Ctrl+S
            echo -e "\n  ${YELLOW}󰆓 Save Playlist as:${NC} "
            read -p "  > " name
            $PY save "$name"
            ;;

        $'\x0c') # Ctrl+L
            selected_pl=$(ls ~/.config/mpv/playlists | fzf --prompt="📂 Load Playlist > " --height 10 --reverse)
            if [ -n "$selected_pl" ]; then
                $PY load "$selected_pl"
                selected=0
                load_queue
            fi
            ;;
    esac

    # Safe bounds
    count=${#lines[@]}
    ((count <= 0)) && selected=0
    ((selected < 0)) && selected=0
    ((selected >= count)) && selected=$((count - 1))

    draw
done
