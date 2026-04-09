#/bin/bash

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
        cd /tmp && sudo apt update && sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config && wget https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz && tar -zxf tmux-3.4.tar.gz && cd tmux-3.4 && ./configure && make && sudo make install
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
  local npm_installed=false
  if npm list -g --depth=0 2>/dev/null | grep -q "@anthropic-ai/claude-code"; then
    npm_installed=true
  fi

  if [ "$npm_installed" = true ]; then
    echo "Replacing npm-installed claude with official installer"
    npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
    curl -fsSL https://claude.ai/install.sh | bash
    hash -r 2>/dev/null || true
    echo "Replaced claude"
  elif ! is_command_available "claude"; then
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

install_homebrew() {
  if [[ "$OS" != "macos" ]]; then
    return 0
  fi

  if is_command_available "brew"; then
    return 0
  fi

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed successfully"
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

install_eza() {
  if is_command_available "eza"; then
    return 0
  fi

  echo "Installing eza..."

  case "$OS" in
    "macos")
      brew install eza
      ;;
    "linux"|"wsl")
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt update && sudo apt install -y eza
      ;;
    *)
      echo "Unsupported OS: $OS"
      return 1
      ;;
  esac

  echo "eza installed successfully"
}

install_uv() {
  if is_command_available "uv"; then
    return 0
  fi

  echo "Installing uv..."
  wget -qO- https://astral.sh/uv/install.sh | sh
  echo "uv installed successfully"
}

install_doppler() {
  if is_command_available "doppler"; then
    return 0
  fi

  echo "Installing doppler..."

  case "$OS" in
    "macos")
      brew install gnupg
      brew install dopplerhq/cli/doppler
      ;;
    "linux"|"wsl")
      sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

      # Check for Ubuntu/Debian 22.04+ vs older
      local version_id
      version_id=$(. /etc/os-release && echo "$VERSION_ID")
      local major_version="${version_id%%.*}"

      if [[ "$major_version" -ge 22 ]]; then
        curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
      else
        curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -
        echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
      fi

      sudo apt-get update && sudo apt-get install doppler
      ;;
    *)
      echo "Unsupported OS: $OS"
      return 1
      ;;
  esac

  echo "doppler installed successfully"
  doppler --version
  doppler update
  doppler login
}

install_homebrew
install_neovim

setup_tmux
install_claude
install_eza
install_doppler

source "$DIR/setup-github-ssh.sh"
