alias ls='ls --color'
alias la='ls -a'
alias cc='clear'
alias nv='nvim'
alias dr='doppler run --'
alias reload='source ~/.zshrc'
function c() {
  TARGET_PATH="${1:-.}"
  if [ -d "$TARGET_PATH" ] || [ -f "$TARGET_PATH" ]; then
    cursor "$TARGET_PATH"
  else
    echo "Path '$TARGET_PATH' does not exist"
    return 1
  fi
}
alias mnt="cd /mnt/c/Users/jaden" # cd to windows drive
alias cl="claude"

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'