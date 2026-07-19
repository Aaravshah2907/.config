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
        nano "$HOME/.local/bin/$script"
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
    curl -s -d "$msg" "https://ntfy.sh/$ALERT_NTFY_TOPIC" > /dev/null
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
            --to) TO="$2"; shift 2; IS_SEND=1 ;;
            --msg) MSG="$2"; shift 2; IS_SEND=1 ;;
            --file) FILE="$2"; shift 2; IS_SEND=1 ;;
            --caption) CAPTION="$2"; shift 2; IS_SEND=1 ;;
            *) COMMAND+=("$1"); shift ;;
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
