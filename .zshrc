# === Oh My Zsh Configuration ===
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
ZSH_THEME='robbyrussell'
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
alias gl='git --no-pager log --oneline --decorate -n 10'
alias c='clear'
alias zsh='n ~/.zshrc'
alias szsh='source ~/.zshrc'
alias n='nvim'
alias oc='opencode'
alias p='pnpm'
alias lsa="ls -alh"

# === Development Tools ===

# OpenCode
export OPENCODE_CONFIG_DIR=$HOME/.config/opencode/
export OPENCODE_EXPERIMENTAL_LSP_TOOL=1
export OPENCODE_EXPERIMENTAL_PLAN_MODE=1
export OPENCODE_ENABLE_EXA=1

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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

# Zoxide
eval "$(zoxide init zsh)"
alias cd='z'

# FZF
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
fi

# === PATH Configuration ===
export PATH="$HOME/.local/bin:$PATH"
typeset -U path

export DOT_REPO="$HOME/code/dotfiles"

# === Machine-Specific Configuration ===
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
