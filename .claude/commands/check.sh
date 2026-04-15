#!/usr/bin/env bash
#
# Check workspaces with changed .ts/.tsx files
# Runs the current required workspace checks: lint and typecheck
# Usage: check.sh [--branch] [--debug]

# Parse arguments
BRANCH_MODE=false
DEBUG_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      BRANCH_MODE=true
      shift
      ;;
    --debug)
      DEBUG_MODE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: check.sh [--branch] [--debug]"
      exit 1
      ;;
  esac
done

# Verify required tools are available
missing=()
for cmd in git yarn; do
  if ! command -v "$cmd" &>/dev/null; then
    missing+=("$cmd")
  fi
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Error: missing required tools: ${missing[*]}"
  exit 1
fi

# Get repo directory dynamically (supports running from worktrees)
REPO_DIR="$(git rev-parse --show-toplevel)"
cd "$REPO_DIR"

# Capture overall start time
OVERALL_START=$(date +%s)

# Determine diff target
if [ "$BRANCH_MODE" = true ]; then
  # Find base branch
  if git rev-parse --verify main >/dev/null 2>&1; then
    BASE_BRANCH="main"
  elif git rev-parse --verify origin/main >/dev/null 2>&1; then
    BASE_BRANCH="origin/main"
  elif git rev-parse --verify master >/dev/null 2>&1; then
    BASE_BRANCH="master"
  elif git rev-parse --verify origin/master >/dev/null 2>&1; then
    BASE_BRANCH="origin/master"
  else
    echo "Error: Could not find main or master branch"
    exit 1
  fi
  DIFF_BASE="$BASE_BRANCH...HEAD"
else
  DIFF_BASE="HEAD"
fi

# Get changed .ts and .tsx files from git (exclude deleted files)
CHANGED_FILES=$(git diff --name-only --diff-filter=d $DIFF_BASE 2>/dev/null | grep -E '\.(ts|tsx)$' || true)
UNTRACKED_FILES=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E '\.(ts|tsx)$' || true)

ALL_CHANGES=$(echo -e "$CHANGED_FILES\n$UNTRACKED_FILES" | grep -v '^$' || true)

if [ -z "$ALL_CHANGES" ]; then
  echo "No TypeScript file changes detected"
  exit 0
fi

# Determine affected workspaces
declare -A WORKSPACE_MAP
declare -A WORKSPACE_FILES

while IFS= read -r file; do
  if [[ "$file" =~ ^apps/([^/]+)/ ]]; then
    workspace="${BASH_REMATCH[1]}"
    WORKSPACE_MAP["$workspace"]=1
    if [ -z "${WORKSPACE_FILES[$workspace]}" ]; then
      WORKSPACE_FILES["$workspace"]="$file"
    else
      WORKSPACE_FILES["$workspace"]="${WORKSPACE_FILES[$workspace]}"$'\n'"$file"
    fi
  elif [[ "$file" =~ ^packages/([^/]+)/ ]]; then
    workspace="${BASH_REMATCH[1]}"
    WORKSPACE_MAP["$workspace"]=1
    if [ -z "${WORKSPACE_FILES[$workspace]}" ]; then
      WORKSPACE_FILES["$workspace"]="$file"
    else
      WORKSPACE_FILES["$workspace"]="${WORKSPACE_FILES[$workspace]}"$'\n'"$file"
    fi
  fi
done <<< "$ALL_CHANGES"

if [ ${#WORKSPACE_MAP[@]} -eq 0 ]; then
  echo "No workspace changes detected"
  exit 0
fi

WORKSPACES=("${!WORKSPACE_MAP[@]}")
if [ "$BRANCH_MODE" = true ]; then
  echo "🔍 Checking workspaces (diff from $BASE_BRANCH): ${WORKSPACES[*]}"
else
  echo "🔍 Checking workspaces: ${WORKSPACES[*]}"
fi
echo ""

# Run a command with timing, showing output only on failure
timed_check() {
  local name="$1"
  shift
  local start=$(date +%s)
  local out=$(mktemp) err=$(mktemp)

  "$@" >"$out" 2>"$err"
  local code=$?

  local end=$(date +%s)
  local duration=$((end - start))

  if [ $code -ne 0 ]; then
    cat "$out"
    cat "$err"
    echo "  ✗ $name failed (${duration}s)"
  elif [ "$DEBUG_MODE" = true ]; then
    echo "  ✓ $name (${duration}s)"
  fi

  rm -f "$out" "$err"
  return $code
}

has_script() {
  local script_name="$1"
  grep -q "\"$script_name\"[[:space:]]*:" package.json 2>/dev/null
}

# Check a single workspace (runs in a subshell via &)
check_workspace() {
  local workspace="$1"
  local start_time=$(date +%s)

  if [ "$DEBUG_MODE" = true ]; then
    echo "Checking $workspace..."
  fi

  # Determine workspace path first (needed for temp file tracking)
  local workspace_path
  if [ -d "$REPO_DIR/apps/$workspace" ]; then
    workspace_path="apps/$workspace"
  else
    workspace_path="packages/$workspace"
  fi

  cd "$REPO_DIR/$workspace_path"

  # Get files for this workspace relative to workspace root
  local workspace_files="${WORKSPACE_FILES[$workspace]}"
  readarray -t files_array <<< "$workspace_files"

  # Convert absolute repo paths to relative workspace paths
  local relative_files=()
  local repo_relative_files=()
  for file in "${files_array[@]}"; do
    if [[ "$file" =~ ^apps/$workspace/(.+)$ ]] || [[ "$file" =~ ^packages/$workspace/(.+)$ ]]; then
      relative_files+=("${BASH_REMATCH[1]}")
      repo_relative_files+=("$file")
    fi
  done

  cd "$REPO_DIR/$workspace_path"

  # Track if we had files before filtering
  local had_files_before_filter=false
  if [ ${#relative_files[@]} -gt 0 ]; then
    had_files_before_filter=true
  fi

  # Filter out files matching .eslintignore patterns
  if [ -f .eslintignore ] && [ ${#relative_files[@]} -gt 0 ]; then
    local filtered_files=()
    local filtered_repo_files=()
    local ignore_patterns=()
    while IFS= read -r pattern; do
      # Skip empty lines and comments
      [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
      # Remove leading/trailing whitespace
      pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [[ -z "$pattern" ]] && continue
      # Store patterns for filtering
      ignore_patterns+=("$pattern")
    done < .eslintignore

    # Filter files that don't match any ignore pattern
    for i in "${!relative_files[@]}"; do
      local file="${relative_files[$i]}"
      local should_ignore=false
      for pattern in "${ignore_patterns[@]}"; do
        # Use bash pattern matching (supports *, ?, etc.)
        if [[ "$file" == $pattern ]]; then
          should_ignore=true
          break
        fi
      done
      if [ "$should_ignore" = false ]; then
        filtered_files+=("$file")
        filtered_repo_files+=("${repo_relative_files[$i]}")
      fi
    done
    relative_files=("${filtered_files[@]}")
    repo_relative_files=("${filtered_repo_files[@]}")
  fi

  # Run checks in parallel
  local pids=()

  # Use Turbo so typechecking runs with the repo's dependency graph and build prerequisites.
  if has_script "typecheck"; then
    timed_check "typecheck" yarn --cwd "$REPO_DIR" turbo run typecheck --filter="./$workspace_path" &
    pids+=($!)
  fi

  if has_script "lint"; then
    if [ ${#relative_files[@]} -gt 0 ]; then
      timed_check "lint" yarn eslint --max-warnings 0 -- "${relative_files[@]}" &
    elif [ "$had_files_before_filter" = false ]; then
      # Only run workspace-wide lint if we never had files to begin with
      # (not if files were just filtered out)
      timed_check "lint" yarn lint &
    fi
    pids+=($!)
  fi

  # Wait for first failure or all success
  local failed=false
  local count=${#pids[@]}
  while [ $count -gt 0 ]; do
    if ! wait -n "${pids[@]}" 2>/dev/null; then
      failed=true
      break
    fi
    ((count--))
  done

  if [ "$failed" = true ]; then
    for p in "${pids[@]}"; do
      kill "$p" 2>/dev/null || true
    done
  fi
  wait 2>/dev/null

  if [ "$failed" = true ]; then
    echo "✗ $workspace failed"
    return 1
  fi

  if [ "$DEBUG_MODE" = true ]; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo "✓ $workspace passed (${duration}s)"
  fi

  return 0
}

# Run all workspace checks in parallel
declare -A ws_pids
declare -A ws_outputs

for workspace in "${WORKSPACES[@]}"; do
  ws_output=$(mktemp)
  ws_outputs["$workspace"]="$ws_output"
  check_workspace "$workspace" &>"$ws_output" &
  ws_pids["$workspace"]=$!
done

# Collect PIDs into an indexed array for wait -n
all_ws_pids=()
for workspace in "${WORKSPACES[@]}"; do
  all_ws_pids+=("${ws_pids[$workspace]}")
done

# Wait for workspaces, fail fast on first error
any_failed=false
count=${#all_ws_pids[@]}
while [ $count -gt 0 ]; do
  if ! wait -n "${all_ws_pids[@]}" 2>/dev/null; then
    any_failed=true
    break
  fi
  ((count--))
done

if [ "$any_failed" = true ]; then
  for pid in "${all_ws_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
fi
wait 2>/dev/null

# Display output from completed workspaces
for workspace in "${WORKSPACES[@]}"; do
  if [ -f "${ws_outputs[$workspace]}" ]; then
    cat "${ws_outputs[$workspace]}"
    rm -f "${ws_outputs[$workspace]}"
  fi
done

if [ "$any_failed" = true ]; then
  echo "✗ Check failed"
  exit 1
fi

OVERALL_END=$(date +%s)
OVERALL_DURATION=$((OVERALL_END - OVERALL_START))
echo "✓ All checks passed (${OVERALL_DURATION}s)"
exit 0
