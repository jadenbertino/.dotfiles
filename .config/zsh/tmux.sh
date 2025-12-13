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

tat() {
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

zat() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  tat
}