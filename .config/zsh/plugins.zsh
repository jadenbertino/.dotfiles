# Zinit
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone -q https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh" && alias zi='zinit' # alias is necessary to prevent conflicts with zoxide
# can confirm installation by running "zinit zstatus"

# Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

# Load completions plugin
zinit light zsh-users/zsh-completions # https://github.com/zsh-users/zsh-completions

# Load completion configuration (must be done before fzf-tab and other widget-wrapping plugins)
source "$(dirname "$0")/completions.zsh"

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

# cd helpers
if [ -x "$(command -v zoxide)" ]; then
  unalias zi && eval "$(zoxide init zsh --cmd z)"
else
  echo "Please install zoxide, refer to the docs here https://github.com/ajeetdsouza/zoxide#installation"
fi
setopt AUTO_CD # cd without cd command

# History for completions
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