start_mcp_servers() {
  local starting=false

  # 1. Serena (SSE or long-lived mode)
  SERENA_PORT="9121"
  if ! pgrep -f "serena start-mcp-server --transport sse --port $SERENA_PORT" >/dev/null 2>&1; then
    echo "Starting Serena MCP server..."
    uvx --from git+https://github.com/oraios/serena \
      serena start-mcp-server --transport sse --port $SERENA_PORT \
      >/tmp/serena.log 2>&1 &
    disown
    echo "Started Serena MCP server on port $SERENA_PORT"
    echo "(it may take a couple seconds to load)"
    echo ""
    echo "Stop it by running:"
    echo "stop_mcp_servers"
  fi
}

stop_mcp_servers() {
  pkill -f "serena start-mcp-server"
  echo "Killed MCP servers"
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