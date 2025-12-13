# Aliases
alias tm='tmux'
alias tml='tmux list-sessions'
alias tma='~/.local/bin/tmux-sessionizer.sh'
alias tmd='tmux detach'
alias tmc='tmux new-session -s'
alias tmka='tmux kill-server'
tmk() {
    # kill a session
    if [[ $# -eq 0 ]]; then
        tmux kill-session
    else
        tmux kill-session -t "$1"
    fi
}
tat() {
  # attach to or create a new session based on the current directory name
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}
zat() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  tat
}

setup_tmux() {
  source ~/.config/zsh/utils.sh

  if ! is_command_available "tmux"; then
    echo "Installing tmux..."
    detect_os

    if [[ "$OS" == "macos" ]]; then
      brew install tmux
    else
      # Build from source for latest version on Linux
      (
        set -e
        sudo apt-get update && sudo apt-get install -y libevent-dev ncurses-dev build-essential bison pkg-config
        cd /tmp
        TMUX_VERSION="3.6"
        curl -LO "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
        tar -xzf "tmux-${TMUX_VERSION}.tar.gz"
        cd "tmux-${TMUX_VERSION}"
        ./configure && make
        sudo make install
        cd /tmp && rm -rf "tmux-${TMUX_VERSION}"*
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

setup_tmux