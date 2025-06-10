# Honestly I don't think I'll really use tmux
# But it's here if I need it

# Install tmux if it doesn't exist
source ~/.config/zsh/utils.sh
if ! is_command_available "tmux"; then
  echo "Installing tmux..."
  install_package "tmux"
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
function tat {
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