# === Homebrew (must come first: everything below needs its PATH) ===
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# === Oh My Zsh Configuration ===
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
ZSH_THEME='robbyrussell'
DISABLE_MAGIC_FUNCTIONS="true"
HIST_STAMPS="mm/dd/yyyy"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
zstyle ':omz:update' mode auto
source $ZSH/oh-my-zsh.sh

# === Vim Mode ===
bindkey -v
export KEYTIMEOUT=1

# === Aliases ===
alias gs='git status'
alias gl='git --no-pager log --oneline --decorate -n 10'
alias c='clear'
alias zsh='n ~/.zshrc'
alias szsh='source ~/.zshrc'
alias n='nvim'
alias p='pnpm'
alias lsa="ls -alh"

# === Development Tools ===

# Envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Mise
command -v mise >/dev/null && eval "$(mise activate zsh)"

# Go
[ -d /usr/local/go-1.22.3 ] && export GOROOT=/usr/local/go-1.22.3
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# === Tools & Utilities ===

# Pi
export PI_SKIP_VERSION_CHECK=1
# Public, keyless search (rate-limited); machine-local config can override it.
export PI_WEB_TOOLS_EXA_ENDPOINT="${PI_WEB_TOOLS_EXA_ENDPOINT:-https://mcp.exa.ai/mcp}"
# Disable Context7 CLI usage telemetry.
export CTX7_TELEMETRY_DISABLED=1
# Keep Impeccable live edits in this chat; opt out of CLI usage telemetry.
export IMPECCABLE_LIVE_COPY_AGENT="${IMPECCABLE_LIVE_COPY_AGENT:-chat}"
export DO_NOT_TRACK="${DO_NOT_TRACK:-1}"
# Playwright defaults to Google Chrome; use installed Chromium when available.
if command -v chromium >/dev/null 2>&1; then
    export PLAYWRIGHT_MCP_EXECUTABLE_PATH="${PLAYWRIGHT_MCP_EXECUTABLE_PATH:-$(command -v chromium)}"
fi

# Turso
export PATH="$HOME/.turso:$PATH"

# Bat
export BAT_THEME=TwoDark

# Zoxide
eval "$(zoxide init zsh)"
alias cd='z'
chpwd() { ls }

# FZF
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
fi

# === PATH Configuration ===
export PATH="$HOME/.local/bin:$PATH"
typeset -U path

# === Machine-Specific Configuration ===
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
