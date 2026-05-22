# Do not source this file in .zshrc, it takes 400ms to load
# Just source it manually if you want to update the aliases

# Define aliases here
typeset -A git_aliases=(
    # List all aliases
    ["aliases"]='!f() { git config --get-regexp "^alias\." | sed -e "s/^alias\.//" -e "s/ / = /" ; }; f'

    # Tracking
    ["a"]='!git add . && git status -sb'
    ["sl"]="status -sb"

    ["st"]="stash"
    ["sa"]="stash apply"
    ["sp"]="stash pop"

    # Commit
    ["cam"]="commit -a -m"
    ["cm"]="commit --no-verify -m"
    ["cp"]="cherry-pick"

    # Branches
    ["bc"]="branch --show-current"
    ["sync"]='!git fetch && git merge $(git rev-parse --abbrev-ref '"'"'@{upstream}'"'"')'
    ["recent"]="for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)'"
    ["p"]="pull"
    ["s"]='!f() { git switch "$@" && { BRANCH=$(git branch --show-current); HISTORY_FILE=".git/branch-history"; if [ -n "$BRANCH" ]; then touch "$HISTORY_FILE"; grep -v "^${BRANCH}|" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" 2>/dev/null || true; echo "${BRANCH}|$(date +%s)" | cat - "$HISTORY_FILE.tmp" > "$HISTORY_FILE"; rm -f "$HISTORY_FILE.tmp"; fi; }; }; f'
    ["sc"]='!f() { git switch -c "$@" && { BRANCH=$(git branch --show-current); HISTORY_FILE=".git/branch-history"; if [ -n "$BRANCH" ]; then touch "$HISTORY_FILE"; grep -v "^${BRANCH}|" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" 2>/dev/null || true; echo "${BRANCH}|$(date +%s)" | cat - "$HISTORY_FILE.tmp" > "$HISTORY_FILE"; rm -f "$HISTORY_FILE.tmp"; fi; }; }; f'
    ["bd"]="branch --delete"
    ["cb"]="rev-parse --abbrev-ref HEAD"
    ["su"]='!f() { if [ -n "$1" ] && [ -n "$2" ]; then git branch --set-upstream-to="$1" "$2"; elif [ -z "$1" ] && [ -z "$2" ]; then current_branch=$(git symbolic-ref --short HEAD); git branch --set-upstream-to="origin/$current_branch" "$current_branch"; else echo "Usage: git su [ <upstream> <local_branch> ]"; fi; }; f'
    ["mu"]='!git pull --quiet && git merge origin/$(git branch --show-current) $(git branch --show-current)'
    ["br"]='!f() { HISTORY_FILE=".git/branch-history"; if [ ! -f "$HISTORY_FILE" ]; then echo "No branch history found. Use '\''git s'\'' to switch branches first."; return; fi; head -10 "$HISTORY_FILE" | while IFS="|" read -r branch timestamp; do if [ -n "$timestamp" ]; then now=$(date +%s); diff=$((now - timestamp)); if [ $diff -lt 60 ]; then time_ago="${diff}s ago"; elif [ $diff -lt 3600 ]; then time_ago="$((diff / 60))m ago"; elif [ $diff -lt 86400 ]; then time_ago="$((diff / 3600))h ago"; elif [ $diff -lt 604800 ]; then time_ago="$((diff / 86400))d ago"; else time_ago="$((diff / 604800))w ago"; fi; printf "\033[36m%-40s\033[0m \033[33m(%s)\033[0m\n" "$branch" "$time_ago"; else printf "\033[36m%s\033[0m\n" "$branch"; fi; done; }; f'

    # Undo
    ["undo"]="reset HEAD~1 --soft"
    ["amend"]="commit --amend"

    # Logs
    ["l"]="!git log --color=always --pretty=format:'%Cred%h%Creset %Cgreen(%cr)%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit -50 | tac"
    ["last"]="log -1 HEAD"
    ["prs"]='!f() { SEARCH_TERM="$1"; BASE_BRANCH="${2:-main}"; AUTHOR_NAME="$(git config user.name)"; git log --author="${AUTHOR_NAME}" -p "${BASE_BRANCH}"...HEAD | grep -C 5 "${SEARCH_TERM}"; }; f'

    # Delete all branches except current
    ["clear"]='!f() { current_branch=$(git rev-parse --abbrev-ref HEAD); git branch --format="%(refname:short)" | grep -v "^${current_branch}$" | xargs -I {} git branch -D "{}"; }; f'
)

# Keep in a function, used by ./git-aliases-cached.zsh + ./alias.zsh
update_git_aliases() {
  for alias_name in ${(k)git_aliases}; do
    git config --global "alias.$alias_name" "${git_aliases[$alias_name]}"
  done
  echo "updated aliases"
}

# For inspo see: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
alias g="git"
alias gp="git pull"
alias ga="git add ."
alias gs="git switch"
alias gcm="git commit -m"
alias gst="git add . && git stash"
alias gsta="git stash apply"
