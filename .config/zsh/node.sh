# fnm instead of nvm: ~420ms → ~10ms startup
export FNM_DIR="$HOME/.fnm"

setup_fnm() {
  if ! command -v fnm >/dev/null 2>&1; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell
    export PATH="$FNM_DIR:$PATH"
    echo "Installed fnm"
  fi

  if ! fnm list 2>/dev/null | grep -q .; then
    echo "No Node.js versions found. Installing latest LTS..."
    fnm install --lts
    fnm default lts-latest
  fi
}

_ts "setup_fnm" setup_fnm
_ts "fnm env"   eval "$(fnm env --use-on-cd --shell zsh)"

alias pm="pnpm"
alias pmx="pnpm dlx"
