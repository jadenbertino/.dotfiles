alias lz="eza --icons --grid --group-directories-first"
alias lza="eza --tree --git-ignore --level=3 --no-permissions --no-user --no-time --all"
alias la="eza -lah --git"
alias ll="eza -lh --git"
alias l="eza -lh --git"
alias lt="eza --tree"
alias cl='clear'
alias dr='doppler run --'
alias reload='source ~/.zshrc && source $ZSH_CONFIG_HOME/git-aliases.zsh && update_git_aliases'
alias rmf='rm -rf'

ch() {
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --remote-debugging-port=9222 \
    --user-data-dir=/tmp/chrome-cdp
}

# IDE aliases
alias b='bash'
alias v='nvim'
alias nv='nvim'

# yarn
alias y='yarn'
alias yw='yarn workspace'
alias yd='yarn dev'
alias yf='yarn workspaces foreach --all run'
alias yt='yarn turbo'
unalias yr 2>/dev/null
yr() {
  setopt localoptions pipefail

  (
    export FORCE_COLOR=1
    yarn install --immutable &&
      yarn docker:up &&
      yarn openapi &&
      yarn db:generate &&
      yarn db:reset -f "$@" &&
      yarn dev
  ) 2>&1 | tee /tmp/neon-dev.log
}

nd() {
  setopt localoptions pipefail
  FORCE_COLOR=1 yarn dev 2>&1 | tee /tmp/neon-dev.log
}

# toggle claude notifications
alias cn='test -f ~/.claude-ntfy && rm -f ~/.claude-ntfy && echo "Claude notifications OFF" || (touch ~/.claude-ntfy && echo "Claude notifications ON")'

# youtube downloader
alias ytd="yt-dlp -f bestaudio -x --audio-format mp3 --audio-quality 0"

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

unfunction c 2>/dev/null
alias c='codex'

co() {
  edit code "${1:-.}"
}

zc() {
  local TARGET_PATH="${1:-.}"
  z "$TARGET_PATH"
  edit "."
}

zipf() {
  local name="${1%/}"
  local out="${name}.zip"
  local i=2
  while [[ -e "$out" ]]; do
    out="${name}-${i}.zip"
    (( i++ ))
  done
  zip -r "$out" "$name"
}

alias mnt="cd /mnt/c/Users/jaden" # cd to windows drive
alias sb="supabase"
alias d="docker"

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
