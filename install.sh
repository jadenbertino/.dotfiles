DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.config/zsh/utils.sh"

if ! is_command_available stow; then
  install_package stow
fi

stow -d "$DIR" -t "$HOME" .