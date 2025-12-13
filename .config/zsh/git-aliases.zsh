# Do not source this file in .zshrc, it takes 400ms to load
# Just source it manually if you want to update the aliases

# Define aliases here
typeset -A git_aliases=(
    # List all aliases
    ["aliases"]='!f() { git config --get-regexp "^alias\." | sed -e "s/^alias\.//" -e "s/ / = /" ; }; f'

    # Tracking
    ["a"]='!git add . && git status -sb'
    ["st"]="status -sb"
    ["sa"]="stash apply"

    # Commit
    ["cam"]="commit -a -m"
    ["cm"]="commit -m"
    ["cp"]="cherry-pick"

    # Branches
    ["p"]="pull"
    ["s"]="switch"
    ["sc"]="switch -c"
    ["bd"]="branch --delete"
    ["cb"]="rev-parse --abbrev-ref HEAD"
    ["su"]='!f() { if [ -n "$1" ] && [ -n "$2" ]; then git branch --set-upstream-to="$1" "$2"; elif [ -z "$1" ] && [ -z "$2" ]; then current_branch=$(git symbolic-ref --short HEAD); git branch --set-upstream-to="origin/$current_branch" "$current_branch"; else echo "Usage: git su [ <upstream> <local_branch> ]"; fi; }; f'
    ["mu"]='!git pull --quiet && git merge origin/$(git branch --show-current) $(git branch --show-current)'
    ["br"]="!git fetch origin --prune --quiet && git branch -r --sort=-committerdate --format='%(color:cyan)%(refname:lstrip=3)%(color:reset) @ %(color:yellow)%(committerdate:short)%(color:reset) by %(color:blue)%(authorname)%(color:reset)'"

    # Undo
    ["undo"]="reset HEAD~1 --soft"
    ["amend"]="commit --amend"

    # Logs
    ["l"]="log --oneline"
    ["ll"]="!git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    ["last"]="log -1 HEAD"
    ["prs"]='!f() { SEARCH_TERM="$1"; BASE_BRANCH="${2:-main}"; AUTHOR_NAME="$(git config user.name)"; git log --author="${AUTHOR_NAME}" -p "${BASE_BRANCH}"...HEAD | grep -C 5 "${SEARCH_TERM}"; }; f'
    
    # Delete all branches except current
    ["clear"]='!f() { current_branch=$(git rev-parse --abbrev-ref HEAD); git branch --format="%(refname:short)" | grep -v "^${current_branch}$" | xargs -I {} git branch -D "{}"; }; f'
)

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