#!/usr/bin/env bash
#
# Fetch GitHub Actions failures for the current branch.
# Writes per-job logs to /tmp/neon-ci/{run-id}/ and prints a summary to stdout.
# If CI is in progress, polls every 30s (up to 15m) and returns as soon as
# at least one locally reproducible job has failed.
#
# Exit codes:
#   0 — STATUS: passing or no_runs
#   1 — STATUS: failed or timeout

set -euo pipefail

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
BRANCH=$(git branch --show-current)
REPO_DIR=$(git rev-parse --show-toplevel)

# Find the latest PR CI run for the current HEAD commit on this branch
# Use the upstream remote SHA so we match what GitHub Actions sees
HEAD_SHA=$(git ls-remote origin "refs/heads/$BRANCH" 2>/dev/null | cut -f1 || true)
if [ -z "$HEAD_SHA" ]; then
  HEAD_SHA=$(git rev-parse HEAD)
fi
LATEST=$(gh run list --branch "$BRANCH" --workflow "PR CI" --limit 10 \
  --json databaseId,status,conclusion,headSha \
  --jq "[.[] | select(.headSha == \"$HEAD_SHA\")] | .[0]" 2>/dev/null)

if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  # CI may not have started yet — retry for up to 2 minutes before giving up
  NO_RUN_DEADLINE=$(($(date +%s) + 120))
  while [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; do
    if [ "$(date +%s)" -gt "$NO_RUN_DEADLINE" ]; then
      echo "STATUS: no_runs"
      exit 0
    fi
    echo "  waiting for CI run to start... ($(date '+%H:%M:%S'))" >&2
    sleep 10
    LATEST=$(gh run list --branch "$BRANCH" --workflow "PR CI" --limit 10 \
      --json databaseId,status,conclusion,headSha \
      --jq "[.[] | select(.headSha == \"$HEAD_SHA\")] | .[0]" 2>/dev/null)
  done
fi

RUN_STATUS=$(echo "$LATEST" | jq -r '.status')
CONCLUSION=$(echo "$LATEST" | jq -r '.conclusion')
RUN_ID=$(echo "$LATEST" | jq -r '.databaseId')

# Poll if in progress — break early only on reproducible (non-cypress/e2e/docker) failures
if [ "$RUN_STATUS" = "in_progress" ] || [ "$RUN_STATUS" = "queued" ] || [ "$RUN_STATUS" = "waiting" ] || [ "$RUN_STATUS" = "pending" ]; then
  echo "CI is running on branch: $BRANCH — polling every 30s (timeout 30m)" >&2

  DEADLINE=$(($(date +%s) + 1800))

  while true; do
    if [ "$(date +%s)" -gt "$DEADLINE" ]; then
      # At timeout, report any failures that exist rather than just giving up
      FAILED=$(gh run view "$RUN_ID" --json jobs \
        --jq '[.jobs[] | select(.conclusion == "failure")]')
      if [ "$(echo "$FAILED" | jq 'length')" -gt 0 ]; then
        break
      fi
      echo "STATUS: timeout"
      echo "CI still running after 30 minutes"
      exit 1
    fi

    POLL=$(gh run view "$RUN_ID" --json jobs,status,conclusion \
      --jq '{status: .status, conclusion: .conclusion, failed: [.jobs[] | select(.conclusion == "failure")]}')

    RUN_STATUS=$(echo "$POLL" | jq -r '.status')
    CONCLUSION=$(echo "$POLL" | jq -r '.conclusion')
    FAILED_NOW=$(echo "$POLL" | jq '.failed')

    # Only break early for reproducible failures — don't interrupt for cypress/e2e/docker/gatekeeper
    REPRO_FAILED=$(echo "$FAILED_NOW" | jq '[.[] | select(.name | test("cypress|e2e|docker|gatekeeper"; "i") | not)]')
    REPRO_FAILED_COUNT=$(echo "$REPRO_FAILED" | jq 'length')

    if [ "$REPRO_FAILED_COUNT" -gt 0 ]; then
      # Re-fetch all currently-failed jobs (more may have failed since last poll)
      FAILED=$(gh run view "$RUN_ID" --json jobs \
        --jq '[.jobs[] | select(.conclusion == "failure")]')
      break
    fi

    if [ "$RUN_STATUS" = "completed" ]; then
      if [ "$CONCLUSION" = "success" ] || [ "$CONCLUSION" = "skipped" ]; then
        echo "STATUS: passing"
        echo "All checks passed on branch: $BRANCH"
        exit 0
      else
        FAILED="$FAILED_NOW"
        break
      fi
    fi

    echo "  still running... ($(date '+%H:%M:%S'))" >&2
    sleep 30
  done
else
  # Run already completed
  if [ "$CONCLUSION" = "success" ] || [ "$CONCLUSION" = "skipped" ]; then
    echo "STATUS: passing"
    echo "All checks passed on branch: $BRANCH"
    exit 0
  fi

  FAILED=$(gh run view "$RUN_ID" --json jobs \
    --jq '[.jobs[] | select(.conclusion == "failure")]')
fi

OUT_DIR="$REPO_DIR/.tmp/neon-ci/$RUN_ID"
mkdir -p "$OUT_DIR"

echo "STATUS: failed"
echo "RUN_ID: $RUN_ID"
echo "OUT_DIR: $OUT_DIR"
echo ""

# Denylist: jobs that cannot be verified locally (but we still attempt fixes)
is_local_verifiable() {
  # Checkout and neon-js Cypress integration tests can be run locally
  echo "$1" | grep -qiE "cypress integration tests \((checkout|neon-js)" && echo "yes" && return
  echo "$1" | grep -qiE "cypress|e2e|docker|gatekeeper" && echo "no" || echo "yes"
}

# Derive the local reproduction command for a failing job.
# Prefers evidence from the log (turbo ERROR lines); falls back to job-name patterns.
local_cmd() {
  local job_name="$1"
  local log_file="$2"

  # Extract failing task from turbo error: "ERROR  pkg#task: command ..."
  local turbo_err
  turbo_err=$(grep -oE 'ERROR  [^[:space:]]+#[^:]+' "$log_file" 2>/dev/null | head -1)
  if [ -n "$turbo_err" ]; then
    local pkg task
    pkg=$(echo "$turbo_err" | sed 's/ERROR  //; s/#.*//')
    task=$(echo "$turbo_err" | sed 's/.*#//')
    echo "yarn workspace $pkg $task"
    return
  fi

  # Fall back to job-name pattern matching
  case "$job_name" in
    *"Unit Tests (storefront)"*)  echo "yarn workspace storefront test" ;;
    *"Unit Tests (console)"*)     echo "yarn workspace console test" ;;
    *"Unit Tests (neon-dash)"*)   echo "yarn workspace neon-dash test" ;;
    *"Unit Tests (neon-js)"*)     echo "yarn workspace neon-js test" ;;
    *"Unit Tests (checkout)"*)    echo "yarn workspace checkout test" ;;
    *"Server Unit Tests"*)        echo "yarn workspace server test" ;;
  esac
}

FAILED_COUNT=$(echo "$FAILED" | jq 'length')

# Slugify a job name: strip "web-ci / " prefix, lowercase, non-alphanumeric to dash
slugify() {
  echo "$1" \
    | sed 's/^[^/]*\/[[:space:]]*//' \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g; s/-\+/-/g; s/^-//; s/-$//'
}

# Strip timestamps and ANSI codes, then slice from the actual command invocation
clean_log() {
  sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9:.Z-]*[[:space:]]*//' \
  | sed 's/\x1b\[[0-9;]*[mKGHFJdlsurTABCDRSu]//g' \
  | sed 's/\x1b[()][AB012]//g' \
  | awk '/^##\[group\]Run (yarn turbo|yarn workspace|turbo |npx)/{found=1} /^Post job cleanup\./{found=0} found{print}' \
  | sed '/^##\[group\]/d; /^##\[endgroup\]/d; /^##\[error\]/d' \
  | grep -v '^[[:space:]]*$' \
  || true
}

echo "=== FAILED JOBS ==="
echo ""

for i in $(seq 0 $((FAILED_COUNT - 1))); do
  JOB_ID=$(echo "$FAILED" | jq -r ".[$i].databaseId")
  JOB_NAME=$(echo "$FAILED" | jq -r ".[$i].name")
  LOCAL=$(is_local_verifiable "$JOB_NAME")
  SLUG=$(slugify "$JOB_NAME")
  LOG_FILE="$OUT_DIR/${SLUG}.txt"

  echo "JOB: $JOB_NAME"
  echo "LOCAL: $LOCAL"
  echo "LOG: $LOG_FILE"

  RAW=$(mktemp)
  gh api "/repos/$REPO/actions/jobs/$JOB_ID/logs" 2>/dev/null > "$RAW" || true

  clean_log < "$RAW" > "$LOG_FILE" || true

  if [ ! -s "$LOG_FILE" ]; then
    # Section filter found nothing (e.g. Cypress jobs use a different invocation)
    # Fall back to full log with just timestamp/ANSI stripping
    sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9:.Z-]*[[:space:]]*//' "$RAW" \
      | sed 's/\x1b\[[0-9;]*[mKGHFJdlsurTABCDRSu]//g' \
      | sed 's/\x1b[()][AB012]//g' \
      | grep -v '^[[:space:]]*$' \
      > "$LOG_FILE" || true
  fi

  rm -f "$RAW"

  [ -s "$LOG_FILE" ] || echo "(failed to fetch logs for $JOB_NAME)" > "$LOG_FILE"

  CMD=$(local_cmd "$JOB_NAME" "$LOG_FILE")
  [ -n "$CMD" ] && echo "CMD: $CMD"

  # Emit a short inline snippet so LOCAL:no failures are immediately actionable.
  # For Cypress: show the failing spec + test name + first error line.
  # For everything else: show the first error/FAIL lines.
  SNIPPET=""
  if echo "$JOB_NAME" | grep -qi "cypress\|e2e"; then
    SPEC=$(awk '/[0-9]+ failing/{found=1} !found && /Running:/{spec=$0} found{print spec; exit}' "$LOG_FILE" 2>/dev/null \
      | grep -oP '(?<=Running:  )\S+' | head -1)
    DESCRIBE=$(awk '/[0-9]+ failing/{f=1;next} f && /^  [0-9]+\)/{sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/,""); print; exit}' "$LOG_FILE" 2>/dev/null)
    TEST=$(awk '/[0-9]+ failing/{f=1;next} f && /^  [0-9]+\)/{getline; sub(/^[[:space:]]*/,""); sub(/:$/,""); print; exit}' "$LOG_FILE" 2>/dev/null)
    ERR=$(grep -m1 "AssertionError" "$LOG_FILE" 2>/dev/null | sed 's/^[[:space:]]*//' | cut -c1-180)
    [ -z "$ERR" ] && ERR=$(grep -m1 "Error:" "$LOG_FILE" 2>/dev/null | sed 's/^[[:space:]]*//' | cut -c1-180)
    [ -n "$SPEC" ] && SNIPPET="spec: $SPEC"
    [ -n "$DESCRIBE" ] && [ -n "$TEST" ] && SNIPPET="$SNIPPET\n  test: $DESCRIBE > $TEST"
    [ -n "$ERR" ] && SNIPPET="$SNIPPET\n  error: $ERR"
  else
    SNIPPET=$(grep -m5 "error TS\|Error:\|FAIL\| × \| ✗ " "$LOG_FILE" 2>/dev/null \
      | sed 's/^[[:space:]]*//' | head -5 | tr '\n' '|' | sed 's/|$//' | sed 's/|/\n  /g')
  fi
  [ -n "$SNIPPET" ] && printf "SNIPPET:\n  %s\n" "$SNIPPET"
  echo ""
done

echo "Logs written to: $OUT_DIR"
exit 1
