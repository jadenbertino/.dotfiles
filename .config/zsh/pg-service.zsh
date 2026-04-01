# PostgreSQL Service File Auto-Sync
export PG_SERVICE_FILE="$HOME/.pg_service.conf"

_pg_service_maybe_sync() {
  # Cross-platform stat
  if [[ "$(uname)" == "Darwin" ]]; then
    _stat_mtime() { stat -f %m "$1"; }
  else
    _stat_mtime() { stat -c %Y "$1"; }
  fi

  # Sync if file is missing or older than 7 days
  if [[ ! -f "$PG_SERVICE_FILE" ]] || \
     [[ $(( $(date +%s) - $(_stat_mtime "$PG_SERVICE_FILE") )) -gt 604800 ]]; then
    echo "[pg-service] config stale or missing, syncing from Doppler..."
    if ! ~/.local/bin-dotfiles/pg-service-sync; then
      echo "[pg-service] ⚠️  sync failed"
      return 1
    fi
  fi
}

# Auto-sync on shell startup
_pg_service_maybe_sync

# Aliases for manual sync
alias pg-service-sync="~/.local/bin-dotfiles/pg-service-sync"
alias pgs="pg-service-sync"

# Helper to list available services
alias pg-services="grep '^\[' ~/.pg_service.conf | tr -d '[]' | sort"
