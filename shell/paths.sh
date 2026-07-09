# =============================================================================
# ~/.config/shell/paths.sh
# Shared PATH exports — sourced by both .zshrc and .bashrc
# Compatible with: bash & zsh
# =============================================================================

# Standard local bins
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Spicetify
export PATH="$PATH:$HOME/.spicetify"

# Antigravity CLI
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Knowledge Base scripts
export PATH="$HOME/.local/bin/cpkb:$PATH"

# Physics KB scripts
export PATH="$PATH:$HOME/Documents/Physics-KB/scripts"
