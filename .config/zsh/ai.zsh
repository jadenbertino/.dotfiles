# claude code (anthropic)
# https://www.anthropic.com/claude-code
cc() {
  claude --dangerously-skip-permissions "$@"
}
ccs() { cc /start "$@"; }
ccp() { cc /plan "$@"; }
ccr() { cc /resume "$@"; }

# gemini cli
# npm install -g @google/gemini-cli
# https://github.com/google-gemini/gemini-cli
alias gm="npx gemini"