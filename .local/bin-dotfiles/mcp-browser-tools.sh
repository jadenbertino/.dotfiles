#!/bin/bash

eval "$(fnm env --shell bash)"

# Run the browser-tools MCP server
exec npx @agentdeskai/browser-tools-mcp@1.2.0 "$@"
