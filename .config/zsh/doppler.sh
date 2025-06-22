function load_doppler_env() {
    # Validate that doppler CLI is installed
    if ! command -v doppler &> /dev/null; then
        echo "doppler could not be found. Please install it'"
        return 1
    fi

    # Validate that .env file exists
    ENV_FILE="$XDG_CONFIG_HOME/.env"
    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ Error: $ENV_FILE file not found"
        return 1
    fi
    source "$ENV_FILE"

    # Validate that DOPPLER_TOKEN is set in .env file
    if [ -z "$DOPPLER_TOKEN" ]; then
        echo "DOPPLER_TOKEN is not set in $ENV_FILE."
        return 1
    fi
    export DOPPLER_TOKEN

    # Cache file for doppler secrets
    CACHE_FILE="$XDG_CACHE_HOME/doppler_secrets_cache"
    CACHE_DURATION=$((24 * 60 * 60)) # 24 hours

    # Check if cache exists and is fresh
    if [ -f "$CACHE_FILE" ]; then
        CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ "$CACHE_AGE" -lt "$CACHE_DURATION" ]; then
            # Use cached secrets
            source "$CACHE_FILE" 2>/dev/null
            return 0
        fi
    fi

    # Cache is stale or doesn't exist, fetch fresh secrets
    echo "🔄 Refreshing Doppler secrets cache..."
    
    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$CACHE_FILE")"
    
    # Download secrets to cache file
    if doppler secrets download --no-file --format env > "$CACHE_FILE.tmp" 2>/dev/null; then
        mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        source "$CACHE_FILE"
    else
        echo "❌ Failed to download Doppler secrets"
        # Clean up failed attempt
        rm -f "$CACHE_FILE.tmp"
        return 1
    fi
}

# Load doppler environment with caching
if ! load_doppler_env; then
    echo "⚠️  Warning: Failed to load Doppler environment"
fi