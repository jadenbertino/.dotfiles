#!/bin/bash

# Load NVM if it exists
# if [ -s "$HOME/.nvm/nvm.sh" ]; then
#     export NVM_DIR="$HOME/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
#     [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# fi

source ~/.config/zsh/node.sh
load_nvm

# Run the browser-tools MCP server
exec npx @agentdeskai/browser-tools-mcp@1.2.0 "$@" 