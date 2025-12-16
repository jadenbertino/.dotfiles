alias ls='ls --color'
alias la='ls -a'
alias cl='clear'
alias dr='doppler run --'
alias reload='source ~/.zshrc && source $ZSH_CONFIG_HOME/git-aliases.zsh && update_git_aliases'
alias rmf='rm -rf'

# IDE aliases
alias b='bash'
alias v='nvim'
alias nv='nvim'

edit() {
  local EDITOR_CMD="$1"
  local TARGET_PATH="${2:-.}"

  # Ensure path exists
  if [ ! -e "$TARGET_PATH" ]; then
    if ! mkdir -p "$(dirname "$TARGET_PATH")" || ! touch "$TARGET_PATH"; then
      echo "c: Failed to create '$TARGET_PATH'" >&2
      return 1
    fi
  fi

  # Open (non blocking)
  { "$EDITOR_CMD" "$TARGET_PATH" > /dev/null 2>&1 & } 2>/dev/null # don't block the shell, suppress job control
  disown # don't kill the process if shell exits
}

c() {
  edit code "${1:-.}"
}

co() {
  edit code "${1:-.}"
}

zc() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  edit "."
}

alias mnt="cd /mnt/c/Users/jaden" # cd to windows drive
alias lz="eza"
alias lza="eza --tree --git-ignore --level=3 --no-permissions --no-user --no-time --all"
alias sb="supabase"
alias d="docker"

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
