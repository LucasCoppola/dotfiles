# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim

ZSH_THEME='robbyrussell'
# ZSH_THEME='random'
# ZSH_THEME="half-life"
# ZSH_THEME="norm"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

HIST_STAMPS="mm/dd/yyyy"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

bindkey -v  # Add this line to enable Vim-like key bindings

bindkey -s ^f "tmux-sessionizer\n"

alias gs='git status'
alias gl='git log --oneline'
alias c='clear'
alias zsh='n ~/.zshrc'
alias szsh='source ~/.zshrc'
alias win='cd /mnt/c/Users/lukic'

alias gitcommit='bat ~/gitcommit.txt'
alias zen="cd ~/.var/app/app.zen_browser.zen/.zen/'97oegn4r.Default (release)'/chrome"

alias y='yazi'
alias n='nvim'
alias d='cd dotfiles/nvim && nvim .'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Turso
export PATH="/home/lucas/.turso:$PATH"

# bun completions
[ -s "/home/lucas/.bun/_bun" ] && source "/home/lucas/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bat or batcat
export BAT_THEME=TwoDark
alias bat='batcat'

export PATH="$HOME/.local/bin:$PATH"

# Zoxide
eval "$(zoxide init zsh)"
alias cd='z'

# Go
export GOROOT=/usr/local/go-1.22.3
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# dpi <dpi-number>
function dpi() {
    sed -i -E "s/^Xft.dpi:.*/Xft.dpi:${1}/" ~/.Xresources
    xrdb ~/.Xresources

    polybar_config="$HOME/.config/polybar/chnvok/config.ini"  

    # Replace dpi-x and dpi-y lines with the new values
    sed -i -E "s/^(dpi-x = ).*/\1${1}/" "$polybar_config"
    sed -i -E "s/^(dpi-y = ).*/\1${1}/" "$polybar_config"

    i3-msg restart

    echo "DPI set to: ${1}"
}

# Cursor alias
function cursor() {
    /opt/cursor.appimage --no-sandbox "${@}" > /dev/null 2>&1 & disown
}
