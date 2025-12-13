#!/bin/bash

# Usage: Don't auto install into codespace
# Instead call: gh repo clone jadenbertino/.dotfiles to clone into home dir
# then stow - you may get conflicts, in which case delete the files then stow again

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/.config/zsh/utils.sh"

if ! is_command_available stow; then
  install_package stow
fi

stow --adopt -d "$DIR" -t "$HOME" .