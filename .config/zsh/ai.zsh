start_mcp_servers() {
  local starting=false

  # 1. Serena (SSE or long-lived mode)
  if ! curl -fsS http://127.0.0.1:9121/health >/dev/null 2>&1; then
    echo "Starting Serena MCP server..."
    uvx --from git+https://github.com/oraios/serena \
      serena start-mcp-server --transport sse --port 9121 \
      >/tmp/serena.log 2>&1 &
    disown
    starting=true
  fi

  if $starting; then
    sleep 2
  fi
}

# claude code (anthropic)
# https://www.anthropic.com/claude-code
cc() {
  start_mcp_servers
  claude --dangerously-skip-permissions "$@"
}
ccs() { cc /start "$@"; }
ccp() { cc /plan "$@"; }
ccr() { cc /resume "$@"; }

# gemini cli
# npm install -g @google/gemini-cli
# https://github.com/google-gemini/gemini-cli
alias gm="npx gemini"