alias ls='ls --color'
alias la='ls -a'
alias cl='clear'
alias nv='nvim'
alias dr='doppler run --'
alias reload='source ~/.zshrc'
function c() {
  local TARGET_PATH="${1:-.}"
  
  # If file doesn't exist, try to create it
  if [ ! -e "$TARGET_PATH" ]; then
    if ! mkdir -p "$(dirname "$TARGET_PATH")" || ! touch "$TARGET_PATH"; then
      echo "c: Failed to create '$TARGET_PATH'" >&2
      return 1
    fi
  fi
  
  # Open file in cursor
  cursor "$TARGET_PATH"
}
alias mnt="cd /mnt/c/Users/jaden" # cd to windows drive
alias cc="npx claude" # claude code
alias ccs="cc /start"

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'