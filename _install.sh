#/bin/bash

# File is prefixed with an underscore so that github codespaces doesn't run it (this file isn't intended to be used by it.)

# this file installs a bunch of programs

DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$DIR/.config/zsh/utils.sh"
detect_os

setup_tmux() {

  if ! is_command_available "tmux"; then
    echo "Installing tmux..."

    if [[ "$OS" == "macos" ]]; then
      # may get some issues if tmux < 3.4
      brew install tmux
    else
      # Build from source for latest version on Linux
      (
        sudo apt update && sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config && wget https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz && tar -zxf tmux-3.4.tar.gz && cd tmux-3.4 && ./configure && make && sudo make install
      )
    fi
    echo "tmux installed successfully"
  fi
  

  # Install TPM (tmux plugin manager)
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM..."
    git clone -q https://github.com/tmux-plugins/tpm "$TPM_DIR" > /dev/null
    echo "TPM installed successfully"
  fi

  # Install Catpuccin theme
  CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
  if [ ! -d "$CATPUCCIN_DIR" ]; then
    echo "Installing Catpuccin theme..."
    mkdir -p "$CATPUCCIN_DIR"
    git clone -q -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPUCCIN_DIR" > /dev/null
    echo "Catpuccin theme installed successfully"
  fi
}

install_claude() {
  if ! is_command_available "claude"; then
    echo "Installing claude"
    curl -fsSL https://claude.ai/install.sh | bash
    echo "Installed claude"
  fi
}

install_neovim() {
    detect_os

    case "$OS" in
        "linux"|"wsl")
            # Add to PATH if not already there
            add_to_path "/opt/nvim-linux-x86_64/bin"

            if is_command_available "nvim"; then
                return 0
            fi

            echo "Installing Neovim for Linux/WSL..."
            if [ -d /opt/nvim ]; then
                sudo rm -rf /opt/nvim
            fi

            # Download and extract Neovim
            (
                cd /tmp
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
                sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
                rm nvim-linux-x86_64.tar.gz
            )


            
            echo "Neovim installed successfully"
            ;;
        "macos")
            if is_command_available "nvim"; then
                return 0
            fi
        
            echo "Installing Neovim for macOS..."
            if ! command -v brew &> /dev/null; then
                echo "Homebrew is not installed. Please install Homebrew first."
                return 1
            fi
            brew install neovim
            echo "Neovim installed successfully"
            ;;
        *)
            echo "Unsupported OS: $OS"
            return 1
            ;;
    esac
}

install_stow() {
  if is_command_available "stow"; then
    return 0
  fi

  echo "Installing stow..."

  case "$OS" in
    "macos")
      brew install stow
      ;;
    "linux"|"wsl")
      sudo apt update && sudo apt install -y stow
      ;;
    *)
      echo "Unsupported OS: $OS"
      return 1
      ;;
  esac

  echo "stow installed successfully"
}

install_neovim

setup_tmux
install_claude