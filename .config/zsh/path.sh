source ~/.config/zsh/utils.sh && detect_os

add_to_path() {
  local PATH_TO_ADD="$1"
  case ":$PATH:" in
    *":$PATH_TO_ADD:"*) :;; # already in PATH, do nothing
    *) export PATH="$PATH_TO_ADD:$PATH";;
  esac
}

remove_from_path() {
  local PATH_TO_REMOVE="$1"
  export PATH="$(echo "$PATH" | awk -v RS=: -v ORS=: -v p="$PATH_TO_REMOVE" '$0 != p' | sed 's/:$//')"
}

add_to_path "$HOME/.local/bin"

# VS Code
if [[ "$OS" == "wsl" ]]; then
    # go into cursor folder and delete "code" and "code.cmd" files. This is because cursor is broken in wsl
    add_to_path "/mnt/c/Users/jaden/AppData/Local/Programs/cursor/resources/app/bin"
    add_to_path "/mnt/c/Users/jaden/AppData/Local/Programs/Microsoft VS Code/bin"
fi
