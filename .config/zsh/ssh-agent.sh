# SSH Agent configuration
SSH_AGENT_ENV="$HOME/.ssh/agent-env"

validate_ssh_agent_env() {
  [[ -f "$SSH_AGENT_ENV" ]] || return 1
  # shellcheck disable=SC1090
  source "$SSH_AGENT_ENV"
  [[ -S "$SSH_AUTH_SOCK" ]] && kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1
}

needs_ssh_agent() {
  [[ -z "${SSH_AUTH_SOCK:-}" || ! -S "${SSH_AUTH_SOCK:-}" ]]
}

if needs_ssh_agent; then
  if validate_ssh_agent_env; then
    source "$SSH_AGENT_ENV" > /dev/null
  fi
  if needs_ssh_agent; then
    rm -f "$SSH_AGENT_ENV"
    eval "$(ssh-agent -s | tee "$SSH_AGENT_ENV" >/dev/null)"
    chmod 600 "$SSH_AGENT_ENV"
    source "$SSH_AGENT_ENV" > /dev/null
  fi
fi

unset -f validate_ssh_agent_env needs_ssh_agent