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

# The next line updates PATH for the Google Cloud SDK.
GCLOUD_CLI_DIR='/home/jaden/.google-cloud-sdk'
if [ -f '$GCLOUD_CLI_DIR/path.bash.inc' ]; then . '$GCLOUD_CLI_DIR/path.bash.inc'; fi
if [ -f '$GCLOUD_CLI_DIR/completion.bash.inc' ]; then . '$GCLOUD_CLI_DIR/completion.bash.inc'; fi
add_to_path "$GCLOUD_CLI_DIR/bin"

# added this so that "code" still opens vs code
# Intention was so I can use github pull requests (its broken in cursor)
# but I think i will just use github.dev to review prs
# VS Code
# if [[ "$OS" == "wsl" ]]; then
#     CURSOR_PATH="/mnt/c/Users/jaden/AppData/Local/Programs/cursor/resources/app/bin"
#     add_to_path "$CURSOR_PATH"
#     rm -f "$CURSOR_PATH/code"
#     rm -f "$CURSOR_PATH/code.cmd"
#     add_to_path "/mnt/c/Users/jaden/AppData/Local/Programs/Microsoft VS Code/bin"
# fi

# Make homebrew apps available in path
[ -x "$(command -v brew)" ] && eval "$(brew shellenv)"