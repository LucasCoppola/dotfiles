# === Oh My Zsh Configuration ===
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim

ZSH_THEME='robbyrussell'

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

HIST_STAMPS="mm/dd/yyyy"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# === Vim Mode ===
bindkey -v
export KEYTIMEOUT=1

bindkey -s ^f "tmux-sessionizer\n"

# === Aliases ===
alias gs='git status'
alias gl='git log --oneline'
alias c='clear'
alias zsh='n ~/.zshrc'
alias szsh='source ~/.zshrc'

alias n='nvim'

# === Development Tools ===

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Go
export GOROOT=/usr/local/go-1.22.3
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# === Tools & Utilities ===

# Turso
export PATH="$HOME/.turso:$PATH"

# Bat
export BAT_THEME=TwoDark
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias bat='bat'
else
    alias bat='batcat'
fi

# Zoxide
eval "$(zoxide init zsh)"
alias cd='z'

# === PATH Configuration ===
export PATH="$HOME/.local/bin:$PATH"
typeset -U path

# FZF - fuzzy finder
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    # Use bat for preview if available
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
fi

mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}
