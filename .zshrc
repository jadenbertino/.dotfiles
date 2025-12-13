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
echo "[DEBUG .zshrc] Running stow..."
stow -d $HOME/.dotfiles -t $HOME --adopt . 2>&1 || echo "[DEBUG .zshrc] stow failed with exit code $?"
echo "[DEBUG .zshrc] Sourcing utils.sh..."
source $ZSH_CONFIG_HOME/utils.sh
echo "[DEBUG .zshrc] Sourcing plugins.zsh..."
source $ZSH_CONFIG_HOME/plugins.zsh
echo "[DEBUG .zshrc] Sourcing alias.zsh..."
source $ZSH_CONFIG_HOME/alias.zsh
echo "[DEBUG .zshrc] Sourcing git-aliases.zsh..."
source $ZSH_CONFIG_HOME/git-aliases.zsh
echo "[DEBUG .zshrc] Sourcing ssh-agent.sh..."
source $ZSH_CONFIG_HOME/ssh-agent.sh > /dev/null # SSH Agent
echo "[DEBUG .zshrc] Sourcing node.sh..."
source $ZSH_CONFIG_HOME/node.sh # NVM
echo "[DEBUG .zshrc] Sourcing tmux.sh..."
source $ZSH_CONFIG_HOME/tmux.sh
echo "[DEBUG .zshrc] Sourcing keybinds.zsh..."
source $ZSH_CONFIG_HOME/keybinds.zsh
echo "[DEBUG .zshrc] Sourcing nvim.sh..."
source $ZSH_CONFIG_HOME/nvim.sh
echo "[DEBUG .zshrc] Sourcing ai.zsh..."
source $ZSH_CONFIG_HOME/ai.zsh
echo "[DEBUG .zshrc] Sourcing go.zsh..."
source $ZSH_CONFIG_HOME/go.zsh
echo "[DEBUG .zshrc] Sourcing clipboard.sh..."
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
[[ -s "/Users/jaden/.gvm/scripts/gvm" ]] && source "/Users/jaden/.gvm/scripts/gvm" # go version manager

# must define here, not in git-aliases cuz that is only occasionally sourced
git_pr_search() {
  local SEARCH_TERM="$1"
  local BASE_BRANCH="${2:-main}"
  local AUTHOR_NAME="$(git config user.name)"
  git log --author="${AUTHOR_NAME}" -p "${BASE_BRANCH}"...HEAD | grep -C 5 "${SEARCH_TERM}"
}