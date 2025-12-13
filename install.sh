#/bin/bash

# this file installs a bunch of programs

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

setup_tmux
install_claude