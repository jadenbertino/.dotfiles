alias ls='ls --color'
alias la='ls -a'
alias cl='clear'
alias dr='doppler run --'
alias reload='source ~/.zshrc'
alias rmf='rm -rf'

# IDE aliases
alias v='nvim'
alias nv='nvim'
edit_file() {
  local TARGET_PATH="${1:-.}"
  { cursor "$TARGET_PATH" > /dev/null 2>&1 & } 2>/dev/null # don't block the shell, suppress job control
  disown # don't kill the process if shell exits
}
c() {
  local TARGET_PATH="${1:-.}"
  
  # If file doesn't exist, try to create it
  if [ ! -e "$TARGET_PATH" ]; then
    if ! mkdir -p "$(dirname "$TARGET_PATH")" || ! touch "$TARGET_PATH"; then
      echo "c: Failed to create '$TARGET_PATH'" >&2
      return 1
    fi
  fi
  edit_file "$TARGET_PATH"
}
zc() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  edit_file "."
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
