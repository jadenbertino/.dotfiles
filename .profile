
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Source bashrc if available
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Add user's private bin to PATH if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# Add user's local bin to PATH if it exists
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Auto-switch to zsh if available
[ -n "$PS1" ] && [ "${SHELL##*/}" != "zsh" ] && command -v zsh > /dev/null 2>&1 && exec zsh

export XDG_CONFIG_HOME="$HOME/.config"