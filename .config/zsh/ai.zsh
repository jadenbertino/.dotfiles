start_mcp_servers() {
  # 1. Serena (SSE or long-lived mode)
  if ! pgrep -f "serena start-mcp-server" >/dev/null 2>&1; then
    echo "Starting Serena MCP server..."
    uvx --from git+https://github.com/oraios/serena \
      serena start-mcp-server --transport sse --port 9121 \
      >/tmp/serena.log 2>&1 &
    disown
  fi
  
  sleep 2  # brief delay to let everything boot
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