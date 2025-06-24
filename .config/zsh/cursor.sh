#!/bin/bash

# Source utility functions
source "$HOME/.config/zsh/utils.sh"

# Get the directory of this script, go one directory up, then to .config/Code/User
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")/.config/Code/User"

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

# copy_cursor_config
# Copies the Cursor config files to the correct location based on the user's OS
copy_cursor_config() {
    detect_os
    # Verify target dir exists
    local TARGET_DIR
    TARGET_DIR=$(detect_target_dir)
    if [[ $? -ne 0 ]]; then
        echo "Error: Could not determine Cursor directory path" >&2
        return 1
    fi
    
    # Verify source dir exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Error: Local cursor directory does not exist: $SOURCE_DIR" >&2
        return 1
    fi

    # Copy all files from dotfiles Cursor directory to target directory
    cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"
}

copy_cursor_config