# NVM - Lazy Loading Configuration
# This file contains NVM setup with lazy loading to improve shell startup performance

export NVM_DIR="$HOME/.nvm"

# Install nvm if it doesn't exist
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing nvm..."
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    (cd "$NVM_DIR" && git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`)
    echo "Installed nvm"
fi

# Function to lazy load NVM
load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Lazy load NVM - only loads when needed
nvm() {
    load_nvm
    nvm "$@"
}

# Create lazy-loaded aliases for node, npm
node() {
    load_nvm
    node "$@"
}

npm() {
    load_nvm
    npm "$@"
}

npx() {
    load_nvm
    npx "@"
}

# Set a default node version if none is active and NVM is loaded
_set_default_node() {
    if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
        # Check if we have a default version set
        if [ -f "$NVM_DIR/alias/default" ]; then
            load_nvm
            nvm use default --silent 2>/dev/null
        elif [ -d "$NVM_DIR/versions/node" ] && [ "$(ls -A $NVM_DIR/versions/node 2>/dev/null)" ]; then
            # If no default is set but we have node versions, use the latest
            load_nvm
            local latest_version=$(ls -1 "$NVM_DIR/versions/node" | tail -1)
            nvm use "$latest_version" --silent 2>/dev/null
            nvm alias default "$latest_version" --silent 2>/dev/null
        fi
    fi
} 
