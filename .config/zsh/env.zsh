ENV_FILE="$XDG_CONFIG_HOME/.env"

load_env() {
  if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE file not found"
    return 1
  fi

  source "$ENV_FILE"
  validate_env_var "NPM_TOKEN"
}

validate_env_var() {
  local var_name="$1"
  if [ -z "${(P)var_name}" ]; then
    echo "❌ Error: $var_name is not set in $ENV_FILE"
    return 1
  fi
}

if ! load_env; then
  echo "⚠️  Warning: Failed to load environment variables"
fi
