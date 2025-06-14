# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Make homebrew apps available in path
[ -x "$(command -v brew)" ] && eval "$(brew shellenv)"

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone -q https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh" && alias zi='zinit' # alias is necessary to prevent conflicts with zoxide
# can confirm installation by running "zinit zstatus"

# Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load completions plugin
zinit light zsh-users/zsh-completions # https://github.com/zsh-users/zsh-completions

# Define completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' file-patterns '*(/):directories'

# Then initialize completions (optimized with -C flag to skip security checks)
autoload -Uz compinit && compinit -C
zinit cdreplay -q

# fzf (must be before fzf tab)
# install from github because the package manager version is outdated
if [ ! -d ~/.fzf ]; then
  echo "Installing fzf..."
  git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# github docs say to do it like below, but install script used the above method
# eval "$(fzf --zsh)"

# fzf-tab needs to be loaded after compinit, but before plugins which will wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting
zinit light Aloxaf/fzf-tab # https://github.com/Aloxaf/fzf-tab | also cd tab completion
zinit light zsh-users/zsh-syntax-highlighting # https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions # https://github.com/zsh-users/zsh-autosuggestions

# You can also load zsh plugins via URL
# You can update all these with `zinit update --all`
# Reference: https://github.com/zdharma-continuum/zinit#plugins-and-snippets
# Find plugins at places like https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins

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

# Keybinds
# bindkey -e # emacs keybindings
bindkey '^F' autosuggest-accept
# ctrl f = accept autosuggestion (via emacs keybindings)
bindkey '^[[A' history-search-backward # up arrow
bindkey '^[[B' history-search-forward # down arrow
export FZF_CTRL_T_COMMAND="" # disable fzf ctrl + t
export FZF_ALT_C_COMMAND="" # disable fzf alt + c
bindkey "^[[1;5C" forward-word # ctrl + right arrow
bindkey "^[[1;5D" backward-word # ctrl + left arrow

# Aliases
alias ls='ls --color'
alias la='ls -a'
alias cc='clear'
alias c='code'
alias nv='nvim'
alias dr='doppler run --'
alias reload='source ~/.zshrc'

# cd helpers
if [ -x "$(command -v zoxide)" ]; then
  unalias zi && eval "$(zoxide init zsh --cmd z)"
else
  echo "Please install zoxide, refer to the docs here https://github.com/ajeetdsouza/zoxide#installation"
fi
setopt AUTO_CD # cd without cd command
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

# Load powerlevel config
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

source ~/.config/zsh/git-aliases.zsh

# SSH Agent
source ~/.config/zsh/ssh-agent.sh > /dev/null

# NVM - Lazy Loading (saves ~0.58s on startup!)
source ~/.config/zsh/node.sh
source ~/.config/zsh/pnpm.sh

# tmux
source ~/.config/zsh/tmux.sh

# Path
export PATH="$HOME/.local/bin:$PATH"