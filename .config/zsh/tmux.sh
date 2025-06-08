# Honestly I don't think I'll really use tmux
# But it's here if I need it

source ~/.config/zsh/utils.sh

# Install tmux if it doesn't exist
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