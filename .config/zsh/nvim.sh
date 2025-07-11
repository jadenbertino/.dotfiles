#!/bin/bash

# Source utils for detect_os function
source "$HOME/.config/zsh/utils.sh"

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

install_neovim