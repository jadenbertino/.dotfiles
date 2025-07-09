source ~/.config/zsh/utils.sh

add_to_path "$HOME/.local/bin"

# The next line updates PATH for the Google Cloud SDK.
GCLOUD_CLI_DIR='/home/jaden/.google-cloud-sdk'
if [ -f '$GCLOUD_CLI_DIR/path.bash.inc' ]; then . '$GCLOUD_CLI_DIR/path.bash.inc'; fi
if [ -f '$GCLOUD_CLI_DIR/completion.bash.inc' ]; then . '$GCLOUD_CLI_DIR/completion.bash.inc'; fi
add_to_path "$GCLOUD_CLI_DIR/bin"

# Make homebrew apps available in path
[ -x "$(command -v brew)" ] && eval "$(brew shellenv)"