source $ZSH_CONFIG_HOME/git-aliases.zsh

# Set aliases on hash change
update_on_hash_change() {
  local current_hash=$(git -C "$HOME/dotfiles" rev-parse HEAD 2>/dev/null)
  [[ -z "$current_hash" ]] && return
  local stored_hash=$(git config --global dotfiles.last-executed-hash 2>/dev/null)
  
  # Only setup aliases if hash has changed
  if [[ "$current_hash" != "$stored_hash" ]]; then
    update_git_aliases
    git config --global dotfiles.last-executed-hash "$current_hash"
  fi
}

update_on_hash_change