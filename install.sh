source .config/zsh/utils.sh

if ! is_command_available stow; then
  install_package stow
fi

stow .