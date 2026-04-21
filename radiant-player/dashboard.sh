#!/bin/bash

# Configuration
PY="$(dirname "$(realpath "$0")")/queue.py"
NOTIFY="$(dirname "$(realpath "$0")")/notify.sh"
selected=0
lines=()
sorted_mode=0
ORIG_STTY=""

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
    local raw=()
    lines=()
    while IFS= read -r line; do
        raw+=("$line")
    done < <($PY list)

    if [ "$sorted_mode" -eq 1 ]; then
        while IFS= read -r sorted_line; do
            [ -n "$sorted_line" ] && lines+=("$sorted_line")
        done < <(
            printf "%s\n" "${raw[@]}" | awk -F'|' '
                BEGIN { OFS="|" }
                {
                    line=$0
                    name=$3
                    sub(/^ /, "", name)
                    print tolower(name) "\t" line
                }
            ' | sort -f -t $'\t' -k1,1 | cut -f2-
        )
    else
        lines=("${raw[@]}")
    fi
}

selected_queue_index() {
    local line="${lines[$selected]}"
    if [ -z "$line" ]; then
        echo "-1"
        return
    fi
    echo "$line" | cut -d'|' -f1 | xargs
}

quick_spotify_pick() {
    local query
    local results
    local options
    local picked
    local track_id
    local new_idx

    query=$(printf "" | fzf --prompt=" Search Spotify > " --print-query --height 10 --reverse | awk 'END{print}')
    [ -z "$query" ] && return

    results=$(spotify_player search "$query" 2>/dev/null)
    options=$(printf "%s" "$results" | /opt/homebrew/bin/jq -r '.tracks[]? | "\(.name) — \((.artists // [] | map(.name) | join(", ")))\t\(.id)"')
    [ -z "$options" ] && return

    picked=$(printf "%s\n" "$options" | fzf \
        --prompt=" Pick Track > " \
        --height 14 \
        --reverse \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview="$PY spotify_art {2}" \
        --preview-window=right:55%)
    [ -z "$picked" ] && return

    track_id=$(printf "%s" "$picked" | awk -F'\t' '{print $2}')
    [ -z "$track_id" ] && return

    $PY add_spotify "spotify:track:$track_id" >/dev/null 2>&1
    load_queue

    new_idx=$(( ${#lines[@]} - 1 ))
    if [ "$new_idx" -ge 0 ]; then
        selected=$new_idx
        $PY play_index "$selected" >/dev/null 2>&1
    fi
}

quick_spotify_playlist_pick() {
    local query
    local results
    local options
    local picked
    local track_json
    local track_options
    local picked_tracks
    local selected_ids
    local playlist_id
    local playlist_name
    local new_idx
    local before_count
    local after_count
    local add_out

    query=$(printf "" | fzf --prompt=" Search Playlist > " --print-query --height 10 --reverse | awk 'END{print}')
    [ -z "$query" ] && return

    results=$(spotify_player search "$query" 2>/dev/null)
    options=$(printf "%s" "$results" | /opt/homebrew/bin/jq -r '.playlists[]? | "\(.id)\t\(.name) — by \((.owner // [] | join(", ")))"')
    [ -z "$options" ] && return

    picked=$(printf "%s\n" "$options" | fzf --prompt=" Pick Playlist > " --height 14 --reverse)
    [ -z "$picked" ] && return

    playlist_id=$(printf "%s" "$picked" | awk -F'\t' '{print $1}')
    playlist_name=$(printf "%s" "$picked" | awk -F'\t' '{print $2}')
    [ -z "$playlist_id" ] && return

    track_json=$($PY spotify_playlist_tracks "spotify:playlist:$playlist_id" 2>/dev/null)
    track_options=$(printf "%s" "$track_json" | /opt/homebrew/bin/jq -r '.[]? | "\(.title) — \(.artist)  [\(.album)]\t\(.spotify_id)"')
    [ -z "$track_options" ] && {
        echo -e "\n  ${RED}󰔹 Could not fetch playlist tracks${NC}"
        sleep 0.8
        return
    }

    picked_tracks=$(printf "%s\n" "$track_options" | fzf \
        --prompt=" Select Tracks > " \
        --height 16 \
        --reverse \
        --multi \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview="$PY spotify_art {2}" \
        --preview-window=right:55%)
    [ -z "$picked_tracks" ] && return

    selected_ids=$(printf "%s\n" "$picked_tracks" | awk -F'\t' '{print $2}' | paste -sd, -)
    [ -z "$selected_ids" ] && return

    before_count=${#lines[@]}
    add_out=$($PY add_spotify_playlist_selected "spotify:playlist:$playlist_id" "$selected_ids" 2>&1)
    load_queue
    after_count=${#lines[@]}

    new_idx=$(( ${#lines[@]} - 1 ))
    if [ "$new_idx" -ge 0 ]; then
        selected=$new_idx
    fi

    if [ "$after_count" -gt "$before_count" ]; then
        echo -e "\n  ${GREEN}󰄬 Added selected tracks: ${playlist_name} ($((after_count-before_count)) tracks)${NC}"
    else
        echo -e "\n  ${RED}󰔹 Could not add playlist tracks${NC}"
        [ -n "$add_out" ] && echo -e "  ${DIM}${add_out}${NC}"
    fi
    sleep 0.8
}

hide_cursor() { printf "\033[?25l"; }
show_cursor() { printf "\033[?25h"; }
restore_tty() {
    show_cursor
    if [ -n "$ORIG_STTY" ]; then
        stty "$ORIG_STTY" 2>/dev/null || true
    fi
}
trap restore_tty EXIT

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
    $PY status_fast 2>/dev/null | sed 's/^/  /'
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
    echo -e "  ${GREEN}${NC} ${BOLD}SPO${NC} ${DIM}[a]${NC} Search+Play  ${DIM}[P]${NC} Pick Playlist Tracks  ${DIM}[o]${NC} Open spotify_player"
    echo -e "  ${CYAN}󰀻${NC} ${BOLD}SYS${NC} ${DIM}[d]${NC} Del  ${DIM}[c]${NC} ClearQ  ${DIM}[t]${NC} Sort  ${DIM}[r]${NC} Refresh  ${DIM}[/]${NC} Find  ${DIM}[C-s/l]${NC} Save/Load  ${RED}[q]${NC} Quit"
    if [ "$sorted_mode" -eq 1 ]; then
        echo -e "      ${YELLOW}${DIM}Sort Mode: Name (press [t] to restore original queue order)${NC}"
    fi
}

# ---------- INIT ----------
ORIG_STTY=$(stty -g 2>/dev/null || true)
stty -ixon 2>/dev/null || true
hide_cursor
load_queue
draw

# ---------- LOOP ----------
while true; do
    key=""
    if ! read -rsn1 -t 10 key; then
        draw
        continue
    fi

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
            ;;

        "") # ENTER
            target_idx=$(selected_queue_index)
            current=$($PY current_index 2>/dev/null)
            if [ "$target_idx" == "$current" ]; then
                $PY toggle
            else
                if [ "$target_idx" -ge 0 ] 2>/dev/null; then
                    $PY play_index "$target_idx"
                fi
            fi
            load_queue
            ;;

        "[") $PY seek -10 ;;
        "]") $PY seek 10 ;;
        "+") $PY volume 5 ;;
        "-") $PY volume -5 ;;
        
        n)  $PY next;   load_queue; selected=$($PY current_index 2>/dev/null) ;;
        p)  $PY prev;   load_queue; selected=$($PY current_index 2>/dev/null) ;;
        d)
            target_idx=$(selected_queue_index)
            if [ "$target_idx" -ge 0 ] 2>/dev/null; then
                $PY remove "$target_idx"
                load_queue
            fi
            ;;
        c)
            $PY clear
            selected=0
            load_queue
            echo -e "\n  ${BLUE}󰃢 Queue cleared${NC}"
            sleep 0.4
            ;;
        a)
            quick_spotify_pick
            ;;
        P)
            quick_spotify_playlist_pick
            ;;
        t)
            if [ "$sorted_mode" -eq 1 ]; then
                sorted_mode=0
                load_queue
                echo -e "\n  ${BLUE}󰑐 Restored queue order${NC}"
            else
                sorted_mode=1
                load_queue
                echo -e "\n  ${GREEN}󰑐 Sorted by name${NC}"
            fi
            sleep 0.4
            ;;
        o)
            show_cursor
            clear
            spotify_player
            hide_cursor
            load_queue
            ;;
        j)
            target_idx=$(selected_queue_index)
            if [ "$target_idx" -ge 0 ] 2>/dev/null; then
                $PY move "$target_idx" 1
            fi
            ((selected++))
            load_queue
            ;;
        k)
            target_idx=$(selected_queue_index)
            if [ "$target_idx" -ge 0 ] 2>/dev/null; then
                $PY move "$target_idx" -1
            fi
            ((selected--))
            load_queue
            ;;
        l)  $PY loop;   load_queue ;;
        s)  $PY shuffle; load_queue ;;
        r)
            # Highstorm Refresh Effect
            echo -ne "${CYAN}${BOLD}"
            for i in {1..4}; do
                printf "\r  󱐌  STORM GATHERING... %s" "$(printf ' %.0s' {1..20} | sed 's/ /·/g')"
                sleep 0.05
                printf "\r  󱐌  STORM GATHERING... %s" "$(printf ' %.0s' {1..20} | sed 's/ /󱐋/g')"
                sleep 0.05
            done
            echo -e "${NC}"
            load_queue
            ;;
        
        "/")
            choice=$(printf "%s\n" "${lines[@]}" | fzf --prompt="🔍 Search > " --height 10 --reverse)
            if [ -n "$choice" ]; then
                selected=$(echo "$choice" | awk '{print $1}')
            fi
            ;;

        $'\x13') # Ctrl+S (Save)
            mkdir -p ~/.config/mpv/playlists
            # Use fzf to either select an existing playlist to overwrite or type a new name
            name=$(command ls -1A ~/.config/mpv/playlists 2>/dev/null | fzf --prompt="󰆓 Save Playlist as > " --height 10 --reverse --print-query | awk 'END{print}')
            if [ -z "$name" ]; then
                # Handle Esc/empty
                :
            else
                $PY save "$name"
                # Flash success
                echo -e "\n  ${GREEN}󰄬 Saved as $name${NC}"
                sleep 0.5
            fi
            ;;

        $'\x0c') # Ctrl+L (Load)
            # Ensure directory exists for fzf to not error
            mkdir -p ~/.config/mpv/playlists
            selected_pl=$(command ls -1A ~/.config/mpv/playlists 2>/dev/null | fzf --prompt="📂 Load Playlist > " --height 10 --reverse)
            if [ -n "$selected_pl" ]; then
                $PY load "$selected_pl"
                selected=0
                load_queue
                # Flash success
                echo -e "\n  ${BLUE}󰄬 Loaded $selected_pl${NC}"
                sleep 0.5
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
