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
