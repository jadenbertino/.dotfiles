# GVM - Lazy Loading Configuration
export GVM_DIR="$HOME/.gvm"

# Function to lazy load GVM and Go - only runs once (on first call of either gvm or go)
load_gvm() {
  unset -f gvm go 2>/dev/null
  if [ -s "$GVM_DIR/scripts/gvm" ]; then
    . "$GVM_DIR/scripts/gvm"
  fi
}

# Lazy wrappers
gvm() {
  load_gvm
  command gvm "$@"
}

go() {
  load_gvm
  command go "$@"
}

# Install GVM dependencies (required for gvm-check to pass)
install_gvm_dependencies() {
  source "$HOME/.config/zsh/utils.sh"
  detect_os

  # GVM requires: git, curl, bison, gcc, make, binutils (ar)
  local deps
  if [[ "$OS" == "macos" ]]; then
    # macOS: Xcode CLI tools provide most deps, just need bison
    deps=(bison)
  else
    # Linux: need build essentials
    deps=(git curl bison gcc make binutils)
  fi

  for dep in "${deps[@]}"; do
    if ! is_command_available "$dep" && ! is_command_available "${dep%utils}"; then
      echo "Installing GVM dependency: $dep..."
      install_package "$dep" || echo "Warning: Failed to install $dep"
    fi
  done
}

# Optional bootstrap: install GVM if missing (fast no-op when already installed)
setup_go() {
  install_gvm_dependencies
  if [ ! -d "$GVM_DIR" ]; then
    echo "Installing gvm dependencies..."

    echo "Installing gvm..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)" || {
      echo "Failed to install gvm"
      return 1
    }
    echo "Installed gvm"
  fi
}

setup_go
