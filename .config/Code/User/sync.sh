#!/bin/bash

# Source utility functions
source "$HOME/.config/zsh/utils.sh"

CURSOR_SOURCE_DIR="$HOME/.config/Code/User"

detect_target_dir() {
    detect_os
    
    local cursor_dir=""
    case "$OS" in
        "macos")
            cursor_dir="$HOME/Library/Application Support/Cursor/User"
            ;;
        "linux")
            cursor_dir="$HOME/.config/Cursor/User"
            ;;
        "wsl")
            # For WSL, use the Linux path
            cursor_dir="/mnt/c/Users/jaden/AppData/Roaming/Cursor/User"
            ;;
        "windows")
            # Windows path for Git Bash/MSYS environments
            cursor_dir="/c/Users/$(whoami)/AppData/Roaming/Cursor/User"
            ;;
        *)
            echo "Error: Unsupported operating system: $OS" >&2
            return 1
            ;;
    esac
    
    # Create the directory if it doesn't exist
    if [[ ! -d "$cursor_dir" ]]; then
        mkdir -p "$cursor_dir"
    fi
    
    echo "$cursor_dir"
}

# Copies the Cursor config files to the correct location based on the user's OS
sync_cursor() {
    detect_os
    # Verify target dir exists
    local TARGET_DIR
    TARGET_DIR=$(detect_target_dir)
    if [[ $? -ne 0 ]]; then
        echo "Error: Could not determine Cursor directory path" >&2
        return 1
    fi
    
    # Verify source dir exists
    if [[ ! -d "$CURSOR_SOURCE_DIR" ]]; then
        echo "Error: Local cursor directory does not exist: $CURSOR_SOURCE_DIR" >&2
        return 1
    fi

    # Copy all files from dotfiles Cursor directory to target directory
    rsync -aL --delete $CURSOR_SOURCE_DIR $TARGET_DIR

    # Install extensions
    source "$HOME/.config/Code/User/extensions.zsh" && install_extensions
}

sync_cursor_with_cache() {
    # If cursor is not installed, do nothing
    if ! command -v cursor &> /dev/null; then
        echo "Failed to sync cursor config: cursor not installed"
        return 1
    fi
    
    sync_dir_with_caching "$CURSOR_SOURCE_DIR" "sync_cursor" ".cursor_config_synced" "🔁 Cursor config synced"
}

sync_cursor_with_cache