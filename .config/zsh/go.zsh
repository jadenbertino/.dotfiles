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

# Optional bootstrap: install GVM if missing (fast no-op when already installed)
setup_go() {
  if [ ! -d "$GVM_DIR" ]; then
    echo "Installing gvm..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)" || {
      echo "Failed to install gvm"
      return 1
    }
    echo "Installed gvm"
  fi
}

setup_go
