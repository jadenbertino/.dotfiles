# Explicitly set XDG paths - https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load config files
stow -d $HOME/.dotfiles -t $HOME .
ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"
source $ZSH_CONFIG_HOME/plugins.zsh
source $ZSH_CONFIG_HOME/misc-aliases.zsh
source $ZSH_CONFIG_HOME/git-aliases.zsh
source $ZSH_CONFIG_HOME/ssh-agent.sh > /dev/null # SSH Agent
source $ZSH_CONFIG_HOME/node.sh # NVM 
source $ZSH_CONFIG_HOME/tmux.sh
source $ZSH_CONFIG_HOME/path.sh
source $ZSH_CONFIG_HOME/keybinds.zsh
source $ZSH_CONFIG_HOME/doppler.sh
source $ZSH_CONFIG_HOME/nvim.sh && install_neovim
source $HOME/.ssh/sync.zsh
# source $XDG_CONFIG_HOME/Code/User/sync.sh

# Set email on a per repo basis!
git config --global --unset user.email