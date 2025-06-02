# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Make homebrew apps available in path
if command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

export XDG_CONFIG_HOME="$HOME/.config"

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
# can confirm installation by running "zinit zstatus"

# Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# zsh plugins via repo
zinit light zsh-users/zsh-syntax-highlighting # https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions # https://github.com/zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions # https://github.com/zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab # https://github.com/Aloxaf/fzf-tab | also cd tab completion

# zsh plugins via URL
# You can update all these with `zinit update --all`
# Reference: https://github.com/zdharma-continuum/zinit#plugins-and-snippets
# Find plugins at places like https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
zinit snippet OMZ::plugins/git # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# keybindings
bindkey -e # emacs keybindings
# ctrl f = accept autosuggestion (via emacs keybindings)
bindkey '^[[A' history-search-backward # up arrow
bindkey '^[[B' history-search-forward # down arrow
export FZF_CTRL_T_COMMAND="" # disable fzf ctrl + t
export FZF_ALT_C_COMMAND="" # disable fzf alt + c

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' file-patterns '*(/):directories'

# Aliases
alias ls='ls --color'
alias c='clear'
alias nv='nvim'

# Shell integrations
eval "$(fzf --zsh)" # ctrl + r -> fzf
eval $(zoxide init --cmd cd zsh) # cd -> zoxide

# Load powerlevel config
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  # Install nvm if it doesn't exist
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  echo "Installed nvm"
fi
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # load nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # load nvm bash_completion