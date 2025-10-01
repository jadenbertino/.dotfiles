# Auto-update dotfiles repository once per day
# Uses XDG cache directory to track last update time

INTERVAL_HOURS=24

# Auto-update dotfiles repository if interval has passed
auto_update_dotfiles() {
    local dotfiles_dir="$HOME/.dotfiles"
    local cache_file="$XDG_CACHE_HOME/dotfiles_last_pull"
    local current_time=$(date +%s)
    local interval_seconds=$((INTERVAL_HOURS * 3600))

    # Check if dotfiles directory exists
    if [[ ! -d "$dotfiles_dir" ]]; then
        return 0
    fi

    # Check if we need to update
    local should_update=false

    if [[ ! -f "$cache_file" ]]; then
        # No cache file exists, first run
        should_update=true
    else
        # Check if interval has passed
        local last_update=$(cat "$cache_file" 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_update))

        if [[ $time_diff -ge $interval_seconds ]]; then
            should_update=true
        fi
    fi

    # Perform update if needed
    if [[ "$should_update" == "true" ]]; then
        (
            cd "$dotfiles_dir" &&
            git pull --quiet 2>/dev/null &&
            echo "$current_time" > "$cache_file" &&
            echo "Dotfiles updated successfully"
        ) || {
            # If update fails, still update cache to avoid repeated attempts
            echo "$current_time" > "$cache_file"
        }
    fi
}