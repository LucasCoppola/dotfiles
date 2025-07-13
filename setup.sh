#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting dotfiles setup...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Info function
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo -e "${RED}❌ Unsupported OS: $OSTYPE${NC}"
        exit 1
    fi
    echo -e "${BLUE}💻 Detected OS: $OS${NC}"
}

# Detect package manager
detect_package_manager() {
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            PKG_MANAGER="brew"
            INSTALL_CMD="brew install"
            UPDATE_CMD="brew update"
        else
            echo -e "${YELLOW}⚠️  Homebrew not found. Installing...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            PKG_MANAGER="brew"
            INSTALL_CMD="brew install"
            UPDATE_CMD="brew update"
        fi
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            PKG_MANAGER="apt"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
            UPDATE_CMD="sudo apt update"
        elif command_exists pacman; then
            PKG_MANAGER="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
            UPDATE_CMD="sudo pacman -Sy"
        else
            echo -e "${RED}❌ Unsupported package manager${NC}"
            exit 1
        fi
    fi
    echo -e "${BLUE}📦 Detected package manager: $PKG_MANAGER${NC}"
}

# Install essential packages
install_packages() {
    echo -e "${YELLOW}📥 Installing essential packages...${NC}"
    
    eval $UPDATE_CMD
    
    # Core packages
    PACKAGES="zsh tmux neovim git curl wget unzip fzf zoxide"
    
    # OS-specific packages
    if [[ "$OS" == "linux" ]]; then
        case $PKG_MANAGER in
            "apt")
                PACKAGES="$PACKAGES build-essential"
                ;;
            "pacman")
                PACKAGES="$PACKAGES base-devel"
                ;;
        esac
    fi
    
    eval "$INSTALL_CMD $PACKAGES"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Packages installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install some packages${NC}"
        exit 1
    fi
}

# Setup Zsh
setup_zsh() {
    info "Setting up Zsh..."
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        info "Oh My Zsh is already installed."
    fi

    info "Installing Zsh plugins..."
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    fi
    
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    fi

    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi
    
    # If we're not in zsh yet and this is the first run, restart in zsh
    if [ "$SHELL" != "$(which zsh)" ] && [ -z "$ZSH_CONTINUE" ]; then
        info "Switching to zsh and continuing setup..."
        export ZSH_CONTINUE=1
        exec zsh -c "source '$0'"
        exit 0
    fi
}

# Install development tools (zsh-dependent)
install_dev_tools() {
    info "Installing development tools..."

    # Install nvm
    export NVM_DIR="$HOME/.nvm"
    if [ ! -d "$NVM_DIR" ]; then
        info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        
        # Source nvm to use it immediately
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Install latest LTS Node.js
        if command_exists nvm; then
            info "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
        fi
    else
        info "nvm is already installed."
    fi
    
    # Install Go
    if ! command -v go &> /dev/null; then
        if [[ "$OS" == "linux" ]]; then
            info "Installing latest Go..."
            # Get latest version dynamically
            LATEST_GO=$(curl -s https://go.dev/VERSION?m=text)
            wget "https://go.dev/dl/${LATEST_GO}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf /tmp/go.tar.gz
            rm /tmp/go.tar.gz
            info "Go ${LATEST_GO} installed."
        elif [[ "$OS" == "macos" ]]; then
            info "Installing Go via Homebrew..."
            brew install go
        fi
    else
        info "Go is already installed."
    fi
}

# Install TPM
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo -e "${YELLOW}🔌 Installing TPM...${NC}"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        echo -e "${GREEN}✅ TPM installed${NC}"
    else
        echo -e "${GREEN}✅ TPM already installed${NC}"
    fi
}

# Create directories
create_directories() {
    echo -e "${YELLOW}📁 Creating directories...${NC}"
    
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.ssh"
    
    chmod 700 "$HOME/.ssh"
    
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Link dotfiles
link_dotfiles() {
    echo -e "${YELLOW}🔗 Linking dotfiles...${NC}"
    
    # Backup existing files
    backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Home files
    home_files=(".zshrc" ".tmux.conf")
    
    for file in "${home_files[@]}"; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            mv "$HOME/$file" "$backup_dir/"
        fi
        
        if [ -f "$PWD/$file" ]; then
            ln -sf "$PWD/$file" "$HOME/$file"
            echo -e "${GREEN}✅ Linked $file${NC}"
        fi
    done
    
    # tmux-sessionizer
    if [ -f "$PWD/tmux-sessionizer" ]; then
        ln -sf "$PWD/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
        chmod +x "$HOME/.local/bin/tmux-sessionizer"
        echo -e "${GREEN}✅ Linked tmux-sessionizer${NC}"
    fi
    
    # Config directories
    config_dirs=("nvim" "ghostty")
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
            mv "$HOME/.config/$dir" "$backup_dir/"
        fi
        
        if [ -d "$PWD/$dir" ]; then
            ln -sf "$PWD/$dir" "$HOME/.config/$dir"
            echo -e "${GREEN}✅ Linked $dir config${NC}"
        fi
    done
    
    if [ "$(ls -A $backup_dir)" ]; then
        echo -e "${BLUE}📦 Backups stored in: $backup_dir${NC}"
    else
        rmdir "$backup_dir"
    fi
}

# Install tmux plugins
install_tmux_plugins() {
    echo -e "${YELLOW}🔌 Installing tmux plugins...${NC}"
    
    tmux kill-server 2>/dev/null || true
    
    if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        echo -e "${GREEN}✅ Tmux plugins installed${NC}"
    else
        echo -e "${RED}❌ TPM not found, skipping plugin installation${NC}"
    fi
}

# Main function
main() {
    # Check if we're continuing in zsh
    if [ -n "$ZSH_CONTINUE" ]; then
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}    CONTINUING SETUP IN ZSH            ${NC}"
        echo -e "${BLUE}========================================${NC}"
        
        # Source zshrc to ensure environment is set up
        if [ -f "$HOME/.zshrc" ]; then
            source "$HOME/.zshrc"
        fi
        
        # Run zsh-dependent installations
        install_dev_tools
        
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}🎉 Zsh-dependent setup complete!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "${YELLOW}Next steps:${NC}"
        echo -e "${YELLOW}1. Open tmux and press 'prefix + I' to install plugins${NC}"
        echo -e "${GREEN}Enjoy your new setup! 🚀${NC}"
        return
    fi
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       DOTFILES SETUP SCRIPT           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    detect_os
    detect_package_manager
    install_packages
    create_directories
    setup_zsh
    install_tpm
    link_dotfiles
    install_tmux_plugins

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🎉 Basic setup complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${YELLOW}The script will now switch to zsh to complete the setup...${NC}"
}

main "$@"
