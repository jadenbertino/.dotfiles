function shf() {
  emulate -L zsh
  setopt localoptions no_aliases

  if ! command -v shfmt >/dev/null 2>&1; then
    echo "Error: 'shfmt' is not installed or not in PATH." >&2
    return 127
  fi

  local path_arg

  if [[ -n "$1" ]]; then
    path_arg="$1"
    if [[ ! -e "$path_arg" ]]; then
      echo "Error: Path '$path_arg' does not exist." >&2
      return 1
    fi
  else
    while true; do
      if ! read -r "path_arg?Enter path to format (file or directory): "; then
        echo "" >&2
        echo "Cancelled." >&2
        return 130
      fi
      if [[ -z "$path_arg" ]]; then
        echo "Path cannot be empty. Try again." >&2
        continue
      fi
      if [[ -e "$path_arg" ]]; then
        break
      else
        echo "Path '$path_arg' does not exist. Try again." >&2
      fi
    done
  fi

  shfmt -i 2 -l -w -- "$path_arg"
}
