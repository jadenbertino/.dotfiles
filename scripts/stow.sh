#!/bin/bash

# Stow all dotfiles
stow -v -R --adopt .

# Setup cursor
source "${BASH_SOURCE%/*}/stow-cursor.sh"
copy_cursor_config
