# =============================================================================
# ~/.config/shell/functions.sh
# Shared shell functions — sourced by both .zshrc and .bashrc
# Compatible with: bash & zsh
# Note: kb() has shell-specific history capture; each shell defines its own.
#       The base version here handles everything except 'kb add'.
# =============================================================================

# --- Yazi wrapper: opens yazi and cds to the last directory on exit ---
fv() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# --- Edit a script in ~/.local/bin interactively ---
es() {
    local script
    script=$(command ls ~/.local/bin | grep '\.sh$' | fzf \
        --header="Edit Local Script" \
        --preview-window=wrap \
        --preview 'bat --color=always ~/.local/bin/{}')
    if [[ -n "$script" ]]; then
        nvim "$HOME/.local/bin/$script"
    else
        echo "No script selected."
    fi
}

# --- Search and run a script from ~/.local/bin or Physics-KB/scripts ---
rss() {
    local folder1="$HOME/.local/bin"
    local folder2="$HOME/Documents/Physics-KB/scripts"
    local file

    if [ ! -d "$folder1" ]; then
        echo "Error: $folder1 not found"
        return 1
    fi

    file=$(find "$folder1" "$folder2" -type f 2>/dev/null | fzf --header="Select a Script")
    if [[ -n "$file" ]]; then
        echo "Running $file..."
        bash "$file"
    fi
}

# --- Search a file line-by-line with bat + fzf ---
srch() {
    bat --plain --color=always --style=numbers "$(pwd)/$1" | fzf --no-sort --tiebreak=index \
        --layout=reverse --header="📄 $1 | ↑↓ Tab Enter" --height=80% --border --ansi
}

# --- Cheatsheet viewers ---
alias chfv='bat ~/Documents/Cheat-Codes/YAZI_CHEATSHEET.md | fzf --no-sort --tiebreak=index \
  --layout=reverse --header="📁 Yazi Keymap | ↑↓ navigate | Tab multi‑select | Enter=jump" \
  --height=80% --border --ansi'

alias chsk='bat ~/Documents/Cheat-Codes/SKHD_CHEATSHEET.md | fzf --no-sort --tiebreak=index \
  --layout=reverse --header="⌨️ SKHD Cheatsheet | ↑↓ navigate | Tab multi‑select | Enter=jump" \
  --height=80% --border --ansi'

alias chtm='bat ~/Documents/Cheat-Codes/TMUX_CHEATSHEET.md 2>/dev/null || bat ~/.config/tmux/cheatsheet.md | fzf --no-sort --tiebreak=index \
  --layout=reverse --header="🖥️ Tmux Cheatsheet | ↑↓ navigate | Tab multi‑select | Enter=jump" \
  --height=80% --border --ansi'

# --- Spicetify apply wrapper ---
spa() {
    spicetify apply
    spicetify backup apply
    spicetify upgrade
    spicetify restore backup
    spicetify apply
}

# --- WhatsApp & Ntfy Alert ---
alert() {
    local msg="${1:-Process finished.}"
    local secrets_file="$HOME/.local/share/alert-secrets.sh"

    if [ -f "$secrets_file" ]; then
        # shellcheck source=/dev/null
        . "$secrets_file"
    fi

    if [ -z "$ALERT_WHATSAPP_TO" ] || [ -z "$ALERT_NTFY_TOPIC" ]; then
        echo "alert: missing ALERT_WHATSAPP_TO or ALERT_NTFY_TOPIC in $secrets_file" >&2
        return 1
    fi

    # 1. Send via WhatsApp (silently syncs to linked devices)
    wacli send text --to "$ALERT_WHATSAPP_TO" --message "$msg" --pick 1

    # 2. Send via ntfy.sh (triggers push notification on phone)
    curl -s -d "$msg" "https://ntfy.sh/$ALERT_NTFY_TOPIC" >/dev/null
}

# --- Wacli Smart Wrapper ---
wa() {
    if [ $# -eq 0 ]; then
        echo "Usage:"
        echo "  wa --to <name> --msg <text>"
        echo "  wa --to <name> --file <path> [--caption <text>]"
        echo "  wa chats | groups | sync | messages <chat>"
        return 1
    fi

    local TO=""
    local MSG=""
    local FILE=""
    local CAPTION=""
    local COMMAND=()
    local IS_SEND=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --to)
            TO="$2"
            shift 2
            IS_SEND=1
            ;;
        --msg)
            MSG="$2"
            shift 2
            IS_SEND=1
            ;;
        --file)
            FILE="$2"
            shift 2
            IS_SEND=1
            ;;
        --caption)
            CAPTION="$2"
            shift 2
            IS_SEND=1
            ;;
        *)
            COMMAND+=("$1")
            shift
            ;;
        esac
    done

    # Handle Sending Operations
    if [ $IS_SEND -eq 1 ]; then
        if [ -z "$TO" ]; then
            echo "❌ Error: --to is required for sending."
            return 1
        fi

        if [ -n "$FILE" ]; then
            if [ -n "$CAPTION" ]; then
                wacli send file --to "$TO" --file "$FILE" --caption "$CAPTION" --pick 1
            else
                wacli send file --to "$TO" --file "$FILE" --pick 1
            fi
        elif [ -n "$MSG" ]; then
            wacli send text --to "$TO" --message "$MSG" --pick 1
        else
            echo "❌ Error: Must provide --msg or --file."
            return 1
        fi
    else
        # Handle regular commands (chats, groups, doctor, etc.)
        wacli "${COMMAND[@]}"
    fi
}

# --- Tailscale Ntfy Toggles ---
tailon() {
    local secrets_file="$HOME/.local/share/alert-secrets.sh"
    if [ -f "$secrets_file" ]; then
        . "$secrets_file"
    fi
    if [ -z "$ALERT_NTFY_TOPIC" ]; then
        echo "tailon: missing ALERT_NTFY_TOPIC in $secrets_file" >&2
        return 1
    fi
    curl -d "Tailscale On" "https://ntfy.sh/$ALERT_NTFY_TOPIC"
}

tailoff() {
    local secrets_file="$HOME/.local/share/alert-secrets.sh"
    if [ -f "$secrets_file" ]; then
        . "$secrets_file"
    fi
    if [ -z "$ALERT_NTFY_TOPIC" ]; then
        echo "tailoff: missing ALERT_NTFY_TOPIC in $secrets_file" >&2
        return 1
    fi
    curl -d "Tailscale Off" "https://ntfy.sh/$ALERT_NTFY_TOPIC"
}

# --- Scrcpy over Tailscale Workflow ---
phonedis() {
    local secrets_file="$HOME/.local/share/alert-secrets.sh"
    if [ -f "$secrets_file" ]; then
        . "$secrets_file"
    fi

    if [ -z "$ALERT_PHONE_TS_IP" ]; then
        echo "❌ phonedis: missing ALERT_PHONE_TS_IP in $secrets_file." >&2
        echo "Please add 'export ALERT_PHONE_TS_IP=\"100.x.x.x\"' to that file!" >&2
        return 1
    fi

    # Use port from secrets file, or default to 5555
    local port="${ALERT_PHONE_TS_PORT:-5555}"

    echo "🌐 Ensuring Tailscale is running on Mac..."
    # Launch the app hidden in the background to ensure the daemon is alive
    open -j -a Tailscale 2>/dev/null
    sleep 1
    # Try standard CLI path, fallback to Mac App Store CLI path
    tailscale up 2>/dev/null || /Applications/Tailscale.app/Contents/MacOS/Tailscale up 2>/dev/null

    echo "📱 Sending 'Tailscale On' trigger to Pixel..."
    tailon

    echo "⏳ Waiting 4 seconds for phone to establish VPN connection..."
    sleep 4

    echo "🔗 Connecting ADB on port $port..."
    adb connect "$ALERT_PHONE_TS_IP:$port"

    # Check if device is actually connected and online
    if ! adb devices | grep -q "$ALERT_PHONE_TS_IP:$port.*device"; then
        echo "⚠️ ADB wireless connection failed or device is offline."

        # Check for locally attached USB device (ignores network devices with ':')
        local usb_dev
        usb_dev=$(adb devices | awk 'NR>1 && $2=="device" && $1 !~ /:/ {print $1}' | head -n 1)

        if [ -n "$usb_dev" ]; then
            echo "🔌 USB device ($usb_dev) detected. Setting up wireless ADB..."
            adb -s "$usb_dev" tcpip "$port"
            echo "⏳ Waiting for ADB daemon to restart..."
            sleep 4
            echo "🔗 Retrying ADB connection..."
            adb connect "$ALERT_PHONE_TS_IP:$port"
        fi

        # Verify connection again
        if ! adb devices | grep -q "$ALERT_PHONE_TS_IP:$port.*device"; then
            echo "❌ Wireless connection could not be established."
            echo ""
            echo "If your phone was recently restarted, wireless ADB has been disabled."
            echo "Please follow these steps to reconnect:"
            echo "  1. Connect your Android phone to this Mac via a USB cable."
            echo "  2. Ensure your phone is unlocked and 'USB debugging' is authorized."
            echo "  3. Open your terminal and run:"
            echo "       adb tcpip $port"
            echo "  4. Disconnect the USB cable."
            echo "  5. Run 'phonedis' again."
            echo ""
            echo "🧹 Cleaning up connections..."
            adb disconnect "$ALERT_PHONE_TS_IP:$port" >/dev/null 2>&1
            echo "📱 Sending 'Tailscale Off' trigger to Pixel..."
            tailoff
            return 1
        fi
    fi

    echo "📺 Launching scrcpy..."
    scrcpy

    echo "🧹 Scrcpy closed. Cleaning up connections..."
    adb disconnect "$ALERT_PHONE_TS_IP:$port"

    echo "📱 Sending 'Tailscale Off' trigger to Pixel..."
    tailoff

    echo "✅ Done."
}

# --- Tmux Command Center (unified, prefix-free control) ---
# Replaces both ts() and t() — attach, split, manage, everything.
# Usage: t [-h] [subcommand] [args]
t() {
    local cmd="${1:-}"
    case "$cmd" in
    # ── Help ──────────────────────────────────────────
    -h | --help)
        echo "Tmux Command Center  (prefix: Ctrl+b)"
        echo ""
        echo "  Sessions:"
        echo "    t                   attach to last session (or create new)"
        echo "    t <name>            attach to <name> (create if missing)"
        echo "    t ls                list all sessions"
        echo "    t new [name]        create new session"
        echo "    t kill <name>       kill a session"
        echo "    t kill-all          kill ALL sessions"
        echo "    t todo              open Tuxedo TUI in dedicated auto-kill session"
        echo ""
        echo "  Panes:"
        echo "    t vs                split vertically (left/right)"
        echo "    t hs                split horizontally (top/bottom)"
        echo "    t float             floating popup shell"
        echo ""
        echo "  Windows:"
        echo "    t win [name]        new window"
        echo "    t wins              list windows"
        echo "    t next / t prev     switch windows"
        echo ""
        echo "  Persistence:"
        echo "    t save              save layout (resurrect)"
        echo "    t restore           restore last layout"
        echo ""
        echo "  Reference:"
        echo "    t docs              full cheatsheet (bat)"
        echo "    t cheat [--edit]    fuzzy searchable command runner"
        echo "    t guide             tmux guide & concepts"
        echo "    t -h                this help message"
        ;;

    # ── Sessions ──────────────────────────────────────
    "") tmux attach 2>/dev/null || tmux new-session ;;
    ls) tmux list-sessions ;;
    new) tmux new-session ${2:+-s "$2"} ;;
    kill) [[ -n "$2" ]] && tmux kill-session -t "$2" || echo "Usage: t kill <session>" ;;
    kill-all) tmux kill-server ;;
    todo | tux) todo ;;

    # ── Panes ─────────────────────────────────────────
    vs) tmux split-window -h ;;
    hs) tmux split-window -v ;;
    float) tmux display-popup -E "$SHELL" ;;

    # ── Windows ───────────────────────────────────────
    win) tmux new-window ${2:+-n "$2"} ;;
    wins) tmux list-windows ;;
    next) tmux next-window ;;
    prev) tmux previous-window ;;

    # ── Persistence ───────────────────────────────────
    save) tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh ;;
    restore) tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh ;;

    # ── Reference ─────────────────────────────────────
    docs) bat --style=plain --paging=never ~/.config/tmux/cheatsheet.md ;;
    cheat)
        shift
        cheat_generate_json "$HOME/.config/tmux/cheatsheet.md" "$HOME/.config/tmux/cheatsheet.json" && cheat_run "$HOME/.config/tmux/cheatsheet.json" "$@"
        ;;
    help) bat --style=plain --paging=never ~/.config/tmux/cheatsheet.md ;;
    guide) bat --style=plain --paging=never ~/.config/tmux/guide.md ;;

    # ── Fallback: treat as session name ───────────────
    *) tmux attach -t "$cmd" 2>/dev/null || tmux new-session -s "$cmd" ;;
    esac
}

# Keep 'ts' as a short alias for backwards compat — just calls t
ts() { t "$@"; }

# --- Tuxedo Todo Workspace in Dedicated Tmux Session ---
# Attaches to session 'Tuxedo' in ~/.tuxedo-todo running tuxedo.
# Upon closing tuxedo in it, the tmux session is killed.
todo() {
    local session="Tuxedo"
    local todo_dir="${TODO_DIR:-$HOME/.tuxedo-todo}"
    mkdir -p "$todo_dir"

    if [ -n "$TMUX" ]; then
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux switch-client -t "$session"
        else
            tmux new-session -d -s "$session" -c "$todo_dir" "tuxedo; tmux kill-session -t $session"
            tmux switch-client -t "$session"
        fi
    else
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux attach-session -t "$session"
        else
            tmux new-session -s "$session" -c "$todo_dir" "tuxedo; tmux kill-session -t $session"
        fi
    fi
}

# Backwards compatibility alias for todo
tux() { todo "$@"; }

# --- Reusable Markdown -> JSON Cheatsheet Generator ---
# Converts simple Markdown tables to the JSON shape consumed by cheat_run.
cheat_generate_json() {
    local md_file="$1"
    local json_file="${2:-${md_file%.*}.json}"
    local generator="$HOME/.config/tmux/cheatsheet_md_to_json.py"

    if [ -z "$md_file" ] || [ ! -r "$md_file" ]; then
        echo "cheat_generate_json: cannot read markdown file: $md_file" >&2
        return 1
    fi

    if [ ! -x "$generator" ]; then
        echo "cheat_generate_json: missing executable generator: $generator" >&2
        return 1
    fi

    "$generator" "$md_file" "$json_file"
}

# --- Reusable JSON Cheatsheet Runner ---
# Selects a command from a JSON cheatsheet and executes it. Expected JSON shape:
# { "commands": [{ "name": "...", "command": "...", "description": "...", "tags": [] }] }
cheat_run() {
    local json_file="$HOME/.config/tmux/cheatsheet.json"
    local edit_before_run=0

    while [ $# -gt 0 ]; do
        case "$1" in
        --edit | -e) edit_before_run=1 ;;
        *) json_file="$1" ;;
        esac
        shift
    done

    if [ ! -r "$json_file" ]; then
        echo "cheat_run: cannot read $json_file" >&2
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "cheat_run: jq is required" >&2
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "cheat_run: fzf is required" >&2
        return 1
    fi

    local jq_filter selected command selection_file
    jq_filter='.commands[] | [
        (.name // "untitled"),
        (.command // ""),
        (.description // ""),
        ((.tags // []) | join(","))
    ] | @tsv'

    if [ -n "$TMUX" ]; then
        selection_file="$(mktemp -t cheat-run.XXXXXX)"
        jq -r "$jq_filter" "$json_file" | tmux display-popup -E -w 85% -h 75% \
            "fzf --with-nth=1,3,4 --delimiter=\$'\\t' --header='Enter runs command | Esc cancels' --preview='printf \"%s\\n\" {2}; printf \"\\n%s\\n\" {3}' > '$selection_file'"
        selected="$(cat "$selection_file" 2>/dev/null)"
        rm -f "$selection_file"
    else
        selected=$(jq -r "$jq_filter" "$json_file" | fzf \
            --with-nth=1,3,4 \
            --delimiter=$'\t' \
            --height=80% \
            --border \
            --header="Enter runs command | Esc cancels" \
            --preview='printf "%s\n" {2}; printf "\n%s\n" {3}')
    fi

    [ -n "$selected" ] || return 0
    command=$(printf "%s" "$selected" | cut -f2)

    if [ -z "$command" ]; then
        echo "cheat_run: selected entry has no command" >&2
        return 1
    fi

    if [ "$edit_before_run" -eq 1 ] || printf "%s" "$command" | grep -Eq ' $|<$|\[.*\]$|<[^>]+>|\[[^]]+\]'; then
        printf "edit command [%s]: " "$command"
        IFS= read -r edited_command
        if [ -n "$edited_command" ]; then
            command="$edited_command"
        fi
    fi

    printf "running: %s\n" "$command"
    eval "$command"
}

# --- Cosmere UI Theme Switcher ---
# Updates Ghostty and Yazi together. Pick the matching Neovim theme via :Themery
# or <leader>uT; the Sylphrena entry is registered there.
cosmere_theme() {
    local theme="${1:-sylphrena}"
    local ghostty_config="$HOME/.config/ghostty/config"
    local ghostty_theme="$HOME/.config/ghostty/themes/$theme.conf"
    local yazi_theme="$HOME/.config/yazi/theme.toml"
    local yazi_flavor="$theme"
    local tmp

    case "$theme" in
    sylphrena | cosmere) ;;
    *)
        echo "Usage: cosmere_theme [sylphrena|cosmere]" >&2
        return 2
        ;;
    esac

    if [ ! -r "$ghostty_theme" ]; then
        echo "cosmere_theme: missing Ghostty theme $ghostty_theme" >&2
        return 1
    fi

    tmp="$(mktemp -t ghostty-theme.XXXXXX)"
    awk '
        /^# -- BEGIN managed ghostty theme --$/ { skip = 1; next }
        /^# -- END managed ghostty theme --$/ { skip = 0; next }
        skip != 1 { print }
    ' "$ghostty_config" >"$tmp"
    printf "\n" >>"$tmp"
    cat "$ghostty_theme" >>"$tmp"
    mv "$tmp" "$ghostty_config"

    if [ "$theme" = "cosmere" ]; then
        yazi_flavor="cosmere"
    fi

    if [ -w "$yazi_theme" ]; then
        tmp="$(mktemp -t yazi-theme.XXXXXX)"
        sed -E "s/^(dark[[:space:]]*=[[:space:]]*)\"[^\"]+\"/\\1\"$yazi_flavor\"/; s/^(light[[:space:]]*=[[:space:]]*)\"[^\"]+\"/\\1\"$yazi_flavor\"/" "$yazi_theme" >"$tmp"
        mv "$tmp" "$yazi_theme"
    fi

    echo "Applied $theme to Ghostty and Yazi. Restart Ghostty windows and Yazi sessions to see it."
}

alias ctc='cosmere_theme cosmere'
alias cts='cosmere_theme sylphrena'
