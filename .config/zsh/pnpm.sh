# PNPM - Lazy Loading Configuration
# This file contains PNPM setup with lazy loading to improve shell startup performance

# Function to lazy load PNPM - only runs once (on first call of pnpm)
PNPM_HOME="$HOME/.local/share/pnpm"

# Install pnpm if it doesn't exist
if  [ ! -d "$PNPM_HOME" ]; then
    echo "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    echo "Installed pnpm"
fi

load_pnpm() {
    # Remove lazy loading functions
    unset -f pnpm pm 2>/dev/null

    # Load pnpm if it exists
    if [ -d "$PNPM_HOME" ]; then
        case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
        esac
    else
        echo "Could not find pnpm in $PNPM_HOME"
    fi
}

# Lazy load 'pnpm'
pnpm() {
    load_pnpm
    pnpm "$@"
}

# Lazy load 'pm' alias
pm() {
    load_pnpm
    pnpm "$@"
}