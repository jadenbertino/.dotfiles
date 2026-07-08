# Define completion styles
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' file-patterns '*(/):directories'

# Add tool completion paths to fpath before compinit
if [ -x "$(command -v asdf)" ]; then
  source "$(dirname "$0")/utils.sh"
  add_to_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  _ts "asdf completion zsh" asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
  fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
fi

# eza completions
if [ -x "$(command -v eza)" ]; then
  if type brew &>/dev/null; then
    local _brew_prefix
    _ts "brew --prefix" _brew_prefix="$(brew --prefix)"
    fpath=("$_brew_prefix/share/zsh/site-functions" $fpath)
  elif [[ -d "/usr/share/zsh/vendor-completions" ]]; then
    fpath=(/usr/share/zsh/vendor-completions $fpath)
  fi
fi

# Initialize completions (optimized with -C flag to skip security checks)
# Must run before any tool that emits compdef calls (uv, asdf, etc.)
autoload -Uz compinit
_ts "compinit" compinit -C
_ts "zinit cdreplay" zinit cdreplay -q

# Load tool completions (must be after compinit as they use compdef)
if [ -x "$(command -v asdf)" ]; then
  _ts "asdf completion source" . <(asdf completion zsh)
fi

if [ -x "$(command -v uv)" ]; then
  _ts "uv completion" eval "$(uv generate-shell-completion zsh)"
fi
