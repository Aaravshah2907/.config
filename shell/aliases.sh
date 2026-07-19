# =============================================================================
# ~/.config/shell/aliases.sh
# Shared aliases — sourced by both .zshrc and .bashrc
# Compatible with: bash & zsh
# Note: zsh-specific global aliases (alias -g) stay in .zshrc
# =============================================================================

# --- Core shortcuts ---
alias e='exit'
alias c='clear'
alias ce='c && e'
alias rmp='rm -P'

# --- Python ---
alias python='python3'
alias pip='pip3'

# --- Editor: use Homebrew nano ---
alias nano='/opt/homebrew/bin/nano'

# --- Neovim ---
alias vi='nvim'
alias vim='nvim'

# --- eza replacements for ls ---
# Basic replacement (with tree, L2)
# Note: .zshrc overrides this with --tree -L 2; bash gets the flat version
alias ls='eza -a --no-time --long --git --icons=always --group-directories-first --no-user --no-permissions --no-filesize'
alias ll='eza -lh --icons --git --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons -a'

# --- bat as cat ---
alias cat='bat'

# --- stat wrapper ---
alias stat='~/.local/bin/pstat'

# --- skhd reload ---
alias skreload='pkill -USR1 skhd'

# --- mt-cli ---
alias mt='~/.local/bin/mt-cli'

# --- zoxide: cd replacement ---
alias cd='z'

# --- Wifi automation ---
alias bwifi='automator ~/Desktop/Wifi-Login.app/Contents/document.wflow'
alias bwifilink='cat ~/Desktop/Wifi-Login.app/Contents/lastlink.txt | pbcopy'

# --- Media / script tools ---
alias pyytdl='python ~/Documents/Code/My_code/Youtube\ \(Audio,Video\)\ Downloader/Songs.Downloader.Youtube.py'
alias photo_metadata_merger='~/.local/bin/photo_metadata_combiner.sh'
alias audiobook_merger='~/.local/bin/audiofilescombiner.sh'
alias m4b_merger='~/.local/bin/merge_m4b.sh'
alias resizeCoverArt='sh ~/.local/bin/resizeCoverArt.sh'
alias mp3_splitter='sh ~/.local/bin/mp3_time_splitter.sh'
alias m4b_split='sh ~/.local/bin/split_m4b.sh'
alias subs='python3 ~/.local/bin/subs_combiner.py'
alias anime_renamer='sh ~/.local/bin/anime_mkv_renamer.sh'

# --- Project shortcuts ---
alias mb='cd ~/Documents/Personal/Tracker/tracker-gui && npm run dev'
alias tracker='cd ~/Documents/Personal/Tracker/tracker-gui && node server.js'

# --- help ---
alias help='cht.sh'
alias h='cht.sh'

# --- cfdash ---
alias cfdash='/Users/aaravshah2975/.config/cfdash/.venv/bin/python /Users/aaravshah2975/.config/cfdash/main.py'


