#!/usr/bin/env bash
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

if [[ $# -eq 1 ]]; then
    # If a session name is provided, use it
    session=$1
else
    # Otherwise, use fzf to select a session

    # If no tmux is running, exit (no sessions to list)
    tmux_running=$(pgrep tmux)
    if [[ -z $tmux_running ]]; then
        echo "No tmux sessions are running"
        exit 1
    fi
    
    # List active tmux sessions and let user select with fzf
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf)
fi

if [[ -z $session ]]; then
    exit 0
fi

# If we're inside tmux, switch client to the selected session
if [[ -n $TMUX ]]; then
    tmux switch-client -t $session
else
    # If we're outside tmux, attach to the selected session
    tmux attach-session -t $session
fi