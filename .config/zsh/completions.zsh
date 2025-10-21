# Define completion styles
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' file-patterns '*(/):directories'

# Load asdf completions
if [ -x "$(command -v asdf)" ]; then
  source "$(dirname "$0")/utils.sh"
  add_to_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
  . <(asdf completion zsh)
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
  fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
fi

# Load uv completions
if [ -x "$(command -v uv)" ]; then
  eval "$(uv generate-shell-completion zsh)"
fi

# Initialize completions (optimized with -C flag to skip security checks)
autoload -Uz compinit && compinit -C
zinit cdreplay -q
