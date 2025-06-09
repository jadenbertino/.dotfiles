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
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" > /dev/null
  echo "TPM installed successfully"
fi

# Aliases
alias tm='tmux'
alias tml='tmux list-sessions'
alias tma='~/.local/bin/tmux-sessionizer.sh'
alias tmd='tmux detach'
alias tmc='tmux new-session -s'
tmk() {
    if [[ $# -eq 0 ]]; then
        tmux kill-session
    else
        tmux kill-session -t "$1"
    fi
}