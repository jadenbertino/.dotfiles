# Install tmux if it doesn't exist

source ~/.config/zsh/utils.sh

if ! is_command_available "tmux"; then
  echo "Installing tmux..."
  install_package "tmux"
  echo "tmux installed successfully"
fi