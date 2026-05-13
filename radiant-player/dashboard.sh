#!/bin/bash

# Configuration
PY="python3 $(dirname "$(realpath "$0")")/queue.py"
NOTIFY="$(dirname "$(realpath "$0")")/notify.sh"
selected=0
lines=()
sorted_mode=0
ORIG_STTY=""

# ---------- COLORS (Radiant / Stormlight) ----------
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[38;5;81m'     # Stormlight Glow
MAGENTA='\033[38;5;141m'  # Shardblade (Violet)
GREEN='\033[38;5;121m'    # Lifebound (Emerald)
YELLOW='\033[38;5;220m'   # Honor-Gold (Heliodor)
BLUE='\033[38;5;69m'      # Windrunner Blue
RED='\033[38;5;160m'      # Voidlight
GRAY='\033[38;5;240m'     # Rosharan Slate
NC='\033[0m'

# Gemstone Shades
RUBY='\033[38;5;196m'     # Infusion
EMERALD_G='\033[38;5;46m'   # Growth
SAPPHIRE_G='\033[38;5;27m'  # Translucence
AMETHYST_G='\033[38;5;129m' # Metal
DIAMOND_G='\033[38;5;231m'  # Glass
HELIODOR_G='\033[38;5;226m' # Air
DUN='\033[38;5;239m'      # Drained Sphere

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
    options=$(printf "%s" "$results" | jq -r '.tracks[]? | "\(.name) — \((.artists // [] | map(.name) | join(", ")))\t\(.id)"')
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
    options=$(printf "%s" "$results" | jq -r '.playlists[]? | "\(.id)\t\(.name) — by \((.owner // [] | join(", ")))"')
    [ -z "$options" ] && return

    picked=$(printf "%s\n" "$options" | fzf --prompt=" Pick Playlist > " --height 14 --reverse)
    [ -z "$picked" ] && return

    playlist_id=$(printf "%s" "$picked" | awk -F'\t' '{print $1}')
    playlist_name=$(printf "%s" "$picked" | awk -F'\t' '{print $2}')
    [ -z "$playlist_id" ] && return

    track_json=$($PY spotify_playlist_tracks "spotify:playlist:$playlist_id" 2>/dev/null)
    track_options=$(printf "%s" "$track_json" | jq -r '.[]? | "\(.title) — \(.artist)  [\(.album)]\t\(.spotify_id)"')
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

show_health_panel() {
    local hjson
    hjson=$($PY health 2>/dev/null)
    show_cursor
    clear
    echo -e "${MAGENTA}${BOLD}Radiant Health Report${NC}"
    echo -e "${GRAY}───────────────────────────────────────────────────────${NC}"
    if [ -z "$hjson" ]; then
        echo -e "${RED}Unable to read health status.${NC}"
    else
        printf "%s" "$hjson" | jq -r '
            "mpv_running      : \(.mpv_running)\n" +
            "socket_exists    : \(.socket_path_exists)\n" +
            "spotify_player   : \(.spotify_player)\n" +
            "librespot        : \(.librespot)\n" +
            "source_lock      : \(.source_lock)\n" +
            "active_source    : \(.active_source)\n" +
            "queue_size       : \(.queue_size)\n" +
            "current_index    : \(.current_index)\n" +
            "running          : \(.running)\n" +
            "source           : \(.source)\n" +
            "title            : \(.title)\n" +
            "artist           : \(.artist)\n" +
            "spotify_running  : \(.spotify_running)\n" +
            "spotify_title    : \(.spotify_title)\n" +
            "spotify_artist   : \(.spotify_artist)\n" +
            "spotify_track_id : \(.spotify_track_id)"
        '
    fi
    echo ""
    read -rsn1 -p "Press any key to return..."
    hide_cursor
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
    printf "\033[H" # Move cursor to top instead of clearing (reduces flicker)

    # ---------- STORMLIGHT DRAIN (Task 1) ----------
    local state_json=$(cat "$HOME/.config/radiant-player/queue_state.json" 2>/dev/null)
    local pos=$(echo "$state_json" | jq -r '(.last_status.position // 0) | floor')
    local dur=$(echo "$state_json" | jq -r '(.last_status.duration // 0) | floor')
    local percent=0
    if ((dur > 0)); then percent=$((pos * 100 / dur)); fi

    local C_MAIN=$BLUE
    local C_SEC=$CYAN
    local C_ACC=$YELLOW
    local C_BRAND=$MAGENTA
    local C_QUEUE=$GREEN

    local term_cols
    term_cols=$(tput cols 2>/dev/null || echo 80)
    local width=$((term_cols - 12))
    # Ensure minimum width covers the First Ideal quote (~91 chars + padding)
    if ((width < 96)); then width=96; fi

    # inner_width is the distance between the two vertical borders (│ ... │)
    local inner_width=$((width + 2))
    local hline=$(printf '─%.0s' $(seq 1 $width))

    # Header / Branding
    local header_text=" 󱐌 THE KNIGHTS RADIANT │${HELIODOR_G} Life Before Death. Strength Before Weakness. Journey before destination.${NC} "
    local header_len=${#header_text} # Visible length approx
    local header_padding=$((inner_width-header_len))
    ((header_padding < 0)) && header_padding=0
    
    echo -e "  ${C_BRAND}${BOLD}┌─${hline}─┐${NC}"
    echo -e "  ${C_BRAND}${BOLD}│${NC}${header_text}${C_BRAND}${BOLD}$(printf '%*s' "$header_padding" "")│${NC}"
    echo -e "  ${C_BRAND}${BOLD}└─${hline}─┘${NC}"
    echo ""

    # Box 1: Infused Record (Now Playing)
    local label1=" INFUSED RECORD "
    local label1_len=${#label1}
    # Top border: ┌── (2) label (len) hline1 (len) ──┐ (3) = total width inner_width+2
    local hline1_len=$((inner_width - label1_len - 4))
    local hline1=$(printf '─%.0s' $(seq 1 $hline1_len))
    echo -e "  ${C_MAIN}${BOLD}┌──${label1}${hline1}──┐${NC}"
    
    local status_raw
    local -a status_lines=()
    status_raw=$($PY status_fast 2>/dev/null)
    while IFS= read -r line; do
        [ -n "$line" ] && status_lines+=("$line")
    done < <(printf "%s\n" "$status_raw")
    
    for line in "${status_lines[@]}"; do
        local plain_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local visible_len=$(( ${#plain_line} + 2 )) # account for "  " prefix
        local padding=$((inner_width - visible_len))
        ((padding < 0)) && padding=0
        printf "  ${C_MAIN}${BOLD}│${NC}  %b%*s${C_MAIN}${BOLD}│${NC}\n" "$line" "$padding" ""
    done

    # Loop/Shuffle Indicator line (Task 11)
    local state_json=$(cat "$HOME/.config/radiant-player/queue_state.json" 2>/dev/null)
    local loop_mode=$(echo "$state_json" | jq -r '.loop_mode // "off"')
    local shuffle_on=$(echo "$state_json" | jq -r '.shuffle // false')
    local indicator=" [LOOP: ${loop_mode}] [SHUFFLE: $( [ "$shuffle_on" == "true" ] && echo ON || echo OFF )] "
    local indicator_len=${#indicator}
    local indicator_padding=$((inner_width-indicator_len-2))
    ((indicator_padding < 0)) && indicator_padding=0
    echo -e "  ${C_MAIN}${BOLD}│${NC}  ${DIAMOND_G}${indicator}${NC}$(printf '%*s' "$indicator_padding" "")${C_MAIN}${BOLD}│${NC}"

    echo -e "  ${C_MAIN}${BOLD}└─${hline}─┘${NC}"
    echo ""

    # Box 2: Highstorm Queue
    local label2=" THE HIGHSTORM SCHEDULE (${#lines[@]} spheres) "
    local label2_len=${#label2}
    local hline2_len=$((inner_width - label2_len - 4))
    local hline2=$(printf '─%.0s' $(seq 1 $hline2_len))
    echo -e "  ${C_QUEUE}${BOLD}┌──${label2}${hline2}──┐${NC}"
    
    local term_rows
    term_rows=$(tput lines 2>/dev/null || echo 40)
    local nowplaying_rows=${#status_lines[@]}
    local max_queue_rows=$((term_rows - nowplaying_rows - 16))
    ((max_queue_rows < 4)) && max_queue_rows=4
    ((max_queue_rows > 16)) && max_queue_rows=16

    local start=$((selected - (max_queue_rows / 2)))
    ((start < 0)) && start=0
    local end=$((start + max_queue_rows))
    if (( end > ${#lines[@]} )); then
        end=${#lines[@]}
        start=$((end - max_queue_rows))
        ((start < 0)) && start=0
    fi

    for ((i=start; i<end; i++)); do
        local line="${lines[$i]}"
        local idx=$(echo "$line" | cut -d'|' -f1 | xargs)
        local marker=$(echo "$line" | cut -d'|' -f2 | xargs)
        local name=$(echo "$line" | cut -d'|' -f3- | sed 's/^ //')
        
        local name_limit=$((inner_width - 10))
        local short_name="${name:0:$name_limit}"
        
        local display_line=""
        if [ "$i" -eq "$selected" ]; then
            display_line=$(printf " ${EMERALD_G}${BOLD}󱐋 %2d │ %s %-${name_limit}s${NC}" "$idx" "$marker" "$short_name")
        else
            display_line=$(printf "    %2d │ %s %-${name_limit}s" "$idx" "$marker" "$short_name")
        fi

        local plain_display=$(echo -e "$display_line" | sed 's/\x1b\[[0-9;]*m//g')
        local visible_len=${#plain_display}
        local padding=$((inner_width - visible_len))
        ((padding < 0)) && padding=0
        printf "  ${C_QUEUE}${BOLD}│${NC}%b%*s${C_QUEUE}${BOLD}│${NC}\n" "$display_line" "$padding" ""
    done

    # Fill empty space if queue is short
    local current_lines=$((end - start))
    for ((i=current_lines; i<max_queue_rows; i++)); do
        printf "  ${C_QUEUE}${BOLD}│${NC}%*s${C_QUEUE}${BOLD}│${NC}\n" "$inner_width" ""
    done
    echo -e "  ${C_QUEUE}${BOLD}└─${hline}─┘${NC}"
    
    if [ "$sorted_mode" -eq 1 ]; then
        echo -e "      ${YELLOW}${DIM}Sort Mode: Name (press [t] to restore original queue order)${NC}"
    fi
    echo ""

    # Box 3: Command Deck (Shortcuts)
    local label3=" SURGE DECK "
    local label3_len=${#label3}
    local hline3_len=$((inner_width - label3_len - 4))
    local hline3=$(printf '─%.0s' $(seq 1 $hline3_len))
    echo -e "  ${C_SEC}${BOLD}┌──${label3}${hline3}──┐${NC}"
    
    local -a cmd_rows=(
        " ${GREEN}󰌌${NC} ${BOLD}NAV${NC}   ${SAPPHIRE_G}[↑/↓]${NC} Move      ${SAPPHIRE_G}[ENTER]${NC} Play ${SAPPHIRE_G}[n/p]${NC} Next/Prev  ${SAPPHIRE_G}[l]${NC} Loop        ${SAPPHIRE_G}[s]${NC} Shuffle"
        " ${CYAN}󰀻${NC} ${BOLD}SYS${NC}   ${SAPPHIRE_G}[d]${NC} Del         ${SAPPHIRE_G}[c]${NC} Clear    ${SAPPHIRE_G}[H]${NC} Health       ${SAPPHIRE_G}[/]${NC} Find        ${RED}[q]${NC} Quit"
        " ${BLUE}󰓓${NC} ${BOLD}ADJ${NC}   ${SAPPHIRE_G}[+/-]${NC} Vol       ${SAPPHIRE_G}[←/→]${NC} Seek   ${SAPPHIRE_G}[[/]]${NC} Jump       ${SAPPHIRE_G}[j/k]${NC} Move Item"
        " ${MAGENTA}󰆓${NC} ${BOLD}FILE${NC}  ${SAPPHIRE_G}[^S]${NC} Save       ${SAPPHIRE_G}[^L]${NC} Load    ${SAPPHIRE_G}[r]${NC} Refresh      ${SAPPHIRE_G}[t]${NC} Sort Mode"
        " ${GREEN}${NC} ${BOLD}SPO${NC}   ${SAPPHIRE_G}[a]${NC} Search+Play ${SAPPHIRE_G}[P]${NC} Playlist ${SAPPHIRE_G}[o]${NC} Spotify App"
    )
    
    for row in "${cmd_rows[@]}"; do
        local plain_row=$(echo -e "$row" | sed 's/\x1b\[[0-9;]*m//g')
        local visible_len=${#plain_row}
        local padding=$((inner_width - visible_len))
        ((padding < 0)) && padding=0
        printf "  ${C_SEC}${BOLD}│${NC}%b%*s${C_SEC}${BOLD}│${NC}\n" "$row" "$padding" ""
    done
    echo -e "  ${C_SEC}${BOLD}└─${hline}─┘${NC}"
}



# ---------- INIT ----------
ORIG_STTY=$(stty -g 2>/dev/null || true)
stty -ixon 2>/dev/null || true
hide_cursor
load_queue
prev_current=$($PY current_index 2>/dev/null)
selected=$prev_current
((selected < 0)) && selected=0
last_draw_time=$(date +%s)
clear
draw

# ---------- LOOP ----------
while true; do
    needs_redraw=0
    # Silent status check to trigger auto-next and reconciliation in backend
    $PY status_fast > /dev/null 2>&1
    
    # Check for song change to snap pointer
    curr=$($PY current_index 2>/dev/null)
    if [ "$curr" != "$prev_current" ] && [ "$curr" -ge 0 ]; then
        load_queue
        selected=$curr
        prev_current=$curr
        needs_redraw=1
    fi
    
    # Periodic redraw every 10 seconds for progress sync
    now=$(date +%s)
    if (( now - last_draw_time >= 10 )); then
        needs_redraw=1
    fi

    if [ "$needs_redraw" -eq 1 ]; then
        draw
        last_draw_time=$now
    fi

    key=""
    if ! read -rsn1 -t 2 key; then
        continue
    fi
    
    # If a key was pressed, handle it and then redraw
    needs_redraw=1

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
        "+" | "=") $PY volume 5 ;;
        "-") $PY volume -5 ;;
        
        n)  $PY next;   load_queue; selected=$(jq -r '.current_index' "$HOME/.config/radiant-player/queue_state.json" 2>/dev/null || echo 0) ;;
        p)  $PY prev;   load_queue; selected=$(jq -r '.current_index' "$HOME/.config/radiant-player/queue_state.json" 2>/dev/null || echo 0) ;;
        d)
            target_idx=$(selected_queue_index)
            if [ "$target_idx" -ge 0 ] 2>/dev/null; then
                $PY remove "$target_idx"
                load_queue
            fi
            ;;
        c)
            read -rsn1 -p "  Clear queue? [y/N]: " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                $PY clear
                selected=0
                load_queue
                echo -e "\n  ${BLUE}󰃢 Queue cleared${NC}"
            else
                echo -e "\n  ${DIM}Cancelled${NC}"
            fi
            sleep 0.4
            ;;
        a)
            quick_spotify_pick
            ;;
        P)
            quick_spotify_playlist_pick
            ;;
        H)
            show_health_panel
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
            printf "\r\033[K" # Clear the line
            echo -ne "${NC}"
            load_queue
            clear # Full clear to ensure no artifacts before redraw
            ;;
        
        "/")
            choice=$(printf "%s\n" "${lines[@]}" | fzf --prompt="🔍 Search > " --height 10 --reverse --ansi)
            if [ -n "$choice" ]; then
                for i in "${!lines[@]}"; do
                    [[ "${lines[$i]}" == "$choice" ]] && selected=$i && break
                done
            fi
            clear
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
