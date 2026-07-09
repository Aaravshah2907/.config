# =============================================================================
# ~/.config/shell/tools.sh
# Shared tool configuration — sourced by both .zshrc and .bashrc
# Compatible with: bash & zsh
# Note: Tool *init* commands (zoxide init, atuin init) are shell-specific
#       and live in .zshrc / .bashrc respectively.
# =============================================================================

# --- Neovim as default editor ---
export EDITOR='nvim'
export VISUAL='nvim'

# --- C include path ---
export CPATH="$HOME/.local/include:$CPATH"

# --- Ollama ---
export OLLAMA_API_BASE='http://127.0.0.1:11434'

# --- Dracula dircolors (eza / ls colors) ---
if command -v dircolors > /dev/null 2>&1; then
    eval "$(dircolors ~/.config/dracula/dircolors)"
else
    # macOS fallback (no dircolors)
    export LS_COLORS
    LS_COLORS="$(grep 'LS_COLORS' ~/.config/dracula/dircolors 2>/dev/null | cut -d'=' -f2 | tr -d '"')"
fi

# --- FZF options ---
export FZF_DEFAULT_OPTS='--extended'
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# --- bat / man pager ---
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'
export TLDR_PAGER='bat --style=plain'

# --- fzf comprun (zsh-specific function, but harmless to define in bash too) ---
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"                         "$@" ;;
    ssh)          fzf --preview 'dig {}'                                    "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}
