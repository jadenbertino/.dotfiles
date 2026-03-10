# Exit if not running in zsh
if [[ -z "$ZSH_VERSION" ]]; then
  echo "Warning: .zshrc is intended for zsh, but current shell is not zsh"
  return 0
fi

# Explicitly set XDG paths - https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Auto-update dotfiles once per day
source $ZSH_CONFIG_HOME/auto-update.zsh
auto_update_dotfiles

# Load config files
stow -d $HOME/.dotfiles -t $HOME --adopt .
source $ZSH_CONFIG_HOME/utils.sh
source $ZSH_CONFIG_HOME/plugins.zsh
source $ZSH_CONFIG_HOME/alias.zsh
source $ZSH_CONFIG_HOME/git-aliases-cached.zsh
source $ZSH_CONFIG_HOME/ssh-agent.sh > /dev/null # SSH Agent
source $ZSH_CONFIG_HOME/node.sh # NVM
source $ZSH_CONFIG_HOME/tmux.sh
source $ZSH_CONFIG_HOME/keybinds.zsh
source $ZSH_CONFIG_HOME/ai.zsh
source $ZSH_CONFIG_HOME/go.zsh
source $ZSH_CONFIG_HOME/clipboard.sh

# Synced files
source $HOME/.ssh/sync.zsh
# source $XDG_CONFIG_HOME/Code/User/sync.sh

# git config --global user.name "Jaden Bertino"
# git config --global --unset user.email

# Misc paths
(
  GCLOUD_CLI_DIR='/home/jaden/.google-cloud-sdk'
  if [ -f '$GCLOUD_CLI_DIR/path.bash.inc' ]; then . '$GCLOUD_CLI_DIR/path.bash.inc'; fi
  if [ -f '$GCLOUD_CLI_DIR/completion.bash.inc' ]; then . '$GCLOUD_CLI_DIR/completion.bash.inc'; fi
  add_to_path "$GCLOUD_CLI_DIR/bin"
)
[ -x "$(command -v brew)" ] && eval "$(brew shellenv)" # Make homebrew apps available in path
add_to_path "$HOME/.local/bin"

# Packages
verify_package zsh
verify_package zoxide
verify_package stow

# must define here, not in git-aliases cuz that is only occasionally sourced
git_pr_search() {
  local SEARCH_TERM="$1"
  local BASE_BRANCH="${2:-main}"
  local AUTHOR_NAME="$(git config user.name)"
  git log --author="${AUTHOR_NAME}" -p "${BASE_BRANCH}"...HEAD | grep -C 5 "${SEARCH_TERM}"
}
. "$HOME/.local/share/../bin/env"
export PATH="$HOME/bin:$PATH"
export CLAUDE_NTFY_TOPIC="377f6693-0c64-4cbc-8b9d-e122c3e98226"

y2mp3() {
  if ! command -v yt-dlp &>/dev/null; then
    echo "Error: yt-dlp is not installed. Install with: brew install yt-dlp" >&2
    return 1
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is not installed. Install with: brew install ffmpeg" >&2
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: y2mp3 <youtube-url> [start] [end]"
    echo "  y2mp3 https://youtube.com/watch?v=abc123"
    echo "  y2mp3 https://youtube.com/watch?v=abc123 54:20 57:37"
    return 1
  fi

  local url="$1"
  local tmpfile

  if [ -n "$2" ] && [ -n "$3" ]; then
    tmpfile="$(mktemp /tmp/y2mp3_XXXXXX.mp3)"
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$tmpfile" "$url" && \
    ffmpeg -i "$tmpfile" -ss "$2" -to "$3" -c copy "clip_${2//:/-}_to_${3//:/-}.mp3" && \
    rm "$tmpfile"
  else
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" "$url"
  fi
}