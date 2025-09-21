#!/bin/bash

set -e # Exit on any error

DOTFILES_REPO="git@github.com:LucasCoppola/dotfiles.git"
DOTFILES_DIR="$HOME/code/dotfiles"
PACKAGES=("git" "zsh" "tmux" "neovim" "wget" "zoxide" "fzf" "ripgrep" "bat")

# Detect OS for package installation
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
  else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
  fi
  echo "📱 Detected OS: $OS"
}

install_packages() {
  echo "📦 Installing required packages: ${PACKAGES[*]}"

  if [[ "$OS" == "macos" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "🍺 Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install "${PACKAGES[@]}"

  elif [[ "$OS" == "linux" ]]; then
    if command -v pacman &>/dev/null; then
      echo "📦 Installing packages via pacman (Arch)..."
      sudo pacman -S --needed "${PACKAGES[@]}"
    elif command -v apt &>/dev/null; then
      echo "📦 Installing packages via apt (Ubuntu/Debian)..."
      sudo apt update && sudo apt install -y "${PACKAGES[@]}"
    else
      echo "❌ Unsupported Linux distribution"
      exit 1
    fi
  fi
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    RUNZSH=no CHSH=no /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "✅ Oh My Zsh is already installed."
  fi

  echo "🔌 Installing Zsh plugins..."

  # Install zsh-autosuggestions
  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    echo "✅ zsh-autosuggestions already installed."
  fi

  # Install zsh-syntax-highlighting
  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  else
    echo "✅ zsh-syntax-highlighting already installed."
  fi
}

setup_core_dotfiles() {
  echo "📂 Setting up core dotfiles..."

  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles repository..."
    mkdir -p "$HOME/code"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  else
    echo "✅ Dotfiles repository already exists."
  fi

  echo "🔗 Creating symlinks..."
  mkdir -p "$HOME/.config" "$HOME/.local/bin"

  ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
  ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

  chmod +x "$DOTFILES_DIR/tmux-sessionizer"
  ln -sf "$DOTFILES_DIR/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"

  echo "✅ Core dotfiles installed!"
}

setup_shell() {
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "🐚 Setting zsh as default shell..."
    chsh -s $(which zsh)
    echo "⚠️  Please restart your terminal for shell changes to take effect"
  else
    echo "✅ Zsh is already the default shell"
  fi
}

main() {
  echo "🚀 Starting dotfiles installation..."
  echo ""

  detect_os
  install_packages
  install_oh_my_zsh
  setup_core_dotfiles
  setup_shell

  echo ""
  echo "🎉 Installation complete!"
  echo "📝 Next steps:"
  echo "   1. Restart your terminal"
  echo "   2. Run 'nvim' to setup plugins"
  echo "   3. Test tmux-sessionizer command"
  echo "   4. Customize configs as needed"
}

main
