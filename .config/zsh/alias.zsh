alias ls='ls --color'
alias la='ls -a'
alias cl='clear'
alias dr='doppler run --'
alias reload='source ~/.zshrc'

# IDE aliases
alias v='nvim'
alias nv='nvim'
c() {
  local TARGET_PATH="${1:-.}"
  
  # If file doesn't exist, try to create it
  if [ ! -e "$TARGET_PATH" ]; then
    if ! mkdir -p "$(dirname "$TARGET_PATH")" || ! touch "$TARGET_PATH"; then
      echo "c: Failed to create '$TARGET_PATH'" >&2
      return 1
    fi
  fi
  
  # Open file in editor
  cursor "$TARGET_PATH"
}
zc() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  cursor .
}

alias mnt="cd /mnt/c/Users/jaden" # cd to windows drive
alias cc="npx claude" # claude code
alias ccs="cc /start"
alias ccp="cc /plan"
alias ccd="cc --dangerously-skip-permissions"
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
