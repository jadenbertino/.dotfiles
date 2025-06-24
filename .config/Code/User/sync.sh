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
    cp -r "$CURSOR_SOURCE_DIR"/* "$TARGET_DIR/"

    # Install extensions
    source "$HOME/.config/Code/User/extensions.zsh" && install_extensions
}

sync_cursor_with_cache() {
    local cache_file="$XDG_CACHE_HOME/.cursor_config_synced"
    
    # If cursor is not installed, do nothing
    if ! command -v cursor &> /dev/null; then
        echo "Failed to sync cursor config: cursor not installed"
        return 1
    fi

    # If source dir does not exist, do nothing
    if [[ ! -d "$CURSOR_SOURCE_DIR" ]]; then
        echo "Error: Local cursor directory does not exist: $CURSOR_SOURCE_DIR" >&2
        return 1
    fi

    # Cache check: sync only if no cache file OR source has changed after last cache file update
    if [[ ! -f "$cache_file" ]] || find "$CURSOR_SOURCE_DIR" -newer "$cache_file" -print -quit | grep -q .; then
        sync_cursor
        touch "$cache_file"
        echo "🔁 Cursor config synced"
    fi
}

sync_cursor_with_cache