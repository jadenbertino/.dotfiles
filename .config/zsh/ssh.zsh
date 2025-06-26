#!/bin/bash

# Source utility functions
source "$HOME/.config/zsh/utils.sh"

SSH_SOURCE_DIR="$HOME/.ssh"

detect_target_dir() {
    detect_os
    
    local ssh_dir=""
    case "$OS" in
        "wsl")
            ssh_dir="/mnt/c/Users/jaden/.ssh"
            ;;
        "windows")
            # Windows path for Git Bash/MSYS environments
            ssh_dir="/c/Users/$(whoami)/.ssh"
            ;;
        *)
            # For other OS types, don't sync (return empty)
            return 1
            ;;
    esac
    
    # Create the directory if it doesn't exist
    if [[ ! -d "$ssh_dir" ]]; then
        mkdir -p "$ssh_dir"
    fi
    
    echo "$ssh_dir"
}

# Copies the SSH config files to Windows home directory
sync_ssh() {
    detect_os
    # Verify target dir exists
    local TARGET_DIR
    TARGET_DIR=$(detect_target_dir)
    if [[ $? -ne 0 ]]; then
        # Not WSL or Windows, skip sync silently
        return 0
    fi
    
    # Verify source dir exists
    if [[ ! -d "$SSH_SOURCE_DIR" ]]; then
        echo "Error: SSH directory does not exist: $SSH_SOURCE_DIR" >&2
        return 1
    fi

    # Copy all files from dotfiles SSH directory to target directory
    cp -r "$SSH_SOURCE_DIR"/* "$TARGET_DIR/"
    
    # Set proper permissions on Windows SSH directory
    chmod 700 "$TARGET_DIR"
    find "$TARGET_DIR" -type f -name "*.pem" -exec chmod 600 {} \;
    find "$TARGET_DIR" -type f -name "*config" -exec chmod 600 {} \;
    find "$TARGET_DIR" -type f -name "*_rsa" -exec chmod 600 {} \;
    find "$TARGET_DIR" -type f -name "*_ed25519" -exec chmod 600 {} \;
}

sync_ssh_with_cache() {
    detect_os
    # Only sync on WSL or Windows
    if [[ "$OS" != "wsl" && "$OS" != "windows" ]]; then
        return 0
    fi
    
    sync_dir_with_caching "$SSH_SOURCE_DIR" "sync_ssh" ".ssh_config_synced" "🔑 SSH config synced to Windows"
}

sync_ssh_with_cache