#!/bin/bash
# Exit on error
set -e

DOTFILES_REPO="https://github.com/LucasCoppola/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
NVM_VERSION="v0.40.3"
PACKAGES=("git" "zsh" "neovim" "tmux" "wget" "curl" "zoxide" "fzf" "ripgrep")

install_ubuntu_packages() {
    echo "Installing packages for Ubuntu..."
    # Install sudo first if not available (for Docker containers)
    if ! command -v sudo &> /dev/null; then
        echo "Installing sudo..."
        apt-get update
        apt-get install -y sudo
    fi
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}" build-essential
}

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh is already installed."
    fi

    echo "Installing Zsh plugins..."

    # Install zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo "zsh-autosuggestions already installed."
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo "zsh-syntax-highlighting already installed."
    fi
}

install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo "Installing nvm..."
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
        export NVM_DIR="$HOME/.nvm"
    else
        echo "nvm is already installed."
    fi
}

manage_dotfiles() {
    echo "Managing dotfiles..."
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        echo "dotfiles repository already exists."
    fi
    
    mkdir -p "$HOME/.config" "$HOME/.local/bin"
    
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    ln -sf "$DOTFILES_DIR/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
}

main() {
    echo "Starting Ubuntu setup..."
    install_ubuntu_packages
    install_oh_my_zsh
    install_nvm
    manage_dotfiles
    echo "Installation complete!"
}

main
