# NVM - Lazy Loading Configuration
# This file contains NVM setup with lazy loading to improve shell startup performance

export NVM_DIR="$HOME/.nvm"

# Function to update a setting in .npmrc
update_setting() {
    local key=$1
    local value=$2
    local npmrc_file="$HOME/.npmrc"
    
    # Create .npmrc if it doesn't exist
    if [ ! -f "$npmrc_file" ]; then
        touch "$npmrc_file"
        echo "Created $npmrc_file"
    fi
    
    # Check if the setting exists and if the value is different
    if grep -q "^$key=" "$npmrc_file"; then
        # Get current value
        current_value=$(grep "^$key=" "$npmrc_file" | cut -d'=' -f2)
        # Only update if value is different
        if [ "$current_value" != "$value" ]; then
            sed -i "s/^$key=.*/$key=$value/" "$npmrc_file"
            updated_settings+=("$key")
        fi
    else
        # Add new setting
        echo "$key=$value" >> "$npmrc_file"
        updated_settings+=("$key")
    fi
}

# Function to lazy load NVM - only runs once (on first call of whichever comes first: nvm, node, npm, or npx)
load_nvm() {
    # Remove lazy loading functions
    unset -f nvm node npm pnpm 2>/dev/null

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

    # Update npmrc settings
    updated_settings=()
    update_setting "save-exact" "true"
    update_setting "auto-install-peers" "true"
    update_setting "package-lock" "true"
    update_setting "engine-strict" "true"
    update_setting "fund" "false"
    update_setting "update-notifier" "false"
    update_setting "loglevel" "warn"
    update_setting "progress" "true"
    update_setting "audit-level" "moderate"
    update_setting "audit" "true"
    update_setting "audit-signatures" "true"
    if [ ${#updated_settings[@]} -gt 0 ]; then
        echo "Updated npmrc settings for: ${updated_settings[*]}"
    fi
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