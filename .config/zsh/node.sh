# NVM - Lazy Loading Configuration
# This file contains NVM setup with lazy loading to improve shell startup performance

export NVM_DIR="$HOME/.nvm"

# Function to lazy load NVM - only runs once (on first call of whichever comes first: nvm, node, npm, or npx)
load_nvm() {
    # Remove lazy loading functions
    unset -f nvm node npm pnpm npx 2>/dev/null

    # Install nvm if it doesn't exist
    if [ ! -d "$NVM_DIR" ]; then
        echo "Installing nvm..."
        git clone -q https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        (cd "$NVM_DIR" && git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`)
        echo "Installed nvm"
    fi

    # Install node version if none exists + set default
    if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
        # Install a Node version if none exist
        if [ ! -d "$NVM_DIR/versions/node" ] || [ ! "$(ls -A $NVM_DIR/versions/node 2>/dev/null)" ]; then
            echo "No Node.js versions found. Installing latest LTS..."
            load_nvm
            nvm install --lts
        fi
        
        # Set default if none is set (versions should exist at this point)
        if [ ! -f "$NVM_DIR/alias/default" ]; then
            load_nvm
            local latest_version=$(ls -1 "$NVM_DIR/versions/node" | tail -1)
            nvm alias default "$latest_version" --silent 2>/dev/null
            nvm use default --silent 2>/dev/null
        fi
    fi

    # Load nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Function to create a .npmrc with the NPM_TOKEN in current directory
# .npmrc with the auth token should be out of version control
# .npmrc files are detected at multiple levels
create_npmrc() {
    printf "\n//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc
    echo "Created .npmrc with auth token"
}

# Lazy load npx, nvm, node, npm
npx() {
    load_nvm
    npx "$@"
}

nvm() {
    load_nvm
    nvm "$@"
}

node() {
    load_nvm
    node "$@"
}

npm() {
    load_nvm
    npm "$@"
}

# PNPM - Lazy Loading Configuration
# must set this up after nvm is loaded
# This file contains PNPM setup with lazy loading to improve shell startup performance

# Function to lazy load PNPM - only runs once (on first call of pnpm)
pnpm() {
    load_nvm
    
    # Install pnpm if it doesn't exist
    PNPM_HOME="$(npm config get prefix)/lib/node_modules/pnpm"
    if [ ! -d "$PNPM_HOME" ]; then
        echo "Installing pnpm into $PNPM_HOME"
        npm install -g pnpm
        echo "Installed pnpm"
    fi
    pnpm "$@"
}

alias pm="pnpm"
alias pmx="pnpm dlx"