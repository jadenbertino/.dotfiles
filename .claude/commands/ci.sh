#!/usr/bin/env bash
#
# Fetch GitHub Actions failures for the current branch.
# Writes per-job logs to /tmp/neon-ci/{run-id}/ and prints a summary to stdout.
# If CI is in progress, polls every 60s (up to 15m) and returns as soon as
# at least one job has failed.
#
# Exit codes:
#   0 — STATUS: passing or no_runs
#   1 — STATUS: failed, timeout, or no_reproducible_failures

set -euo pipefail

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
BRANCH=$(git branch --show-current)
REPO_DIR=$(git rev-parse --show-toplevel)

# Find the latest PR CI run for the current HEAD commit on this branch
HEAD_SHA=$(git rev-parse HEAD)
LATEST=$(gh run list --branch "$BRANCH" --workflow "PR CI" --limit 10 \
  --json databaseId,status,conclusion,headSha \
  --jq "[.[] | select(.headSha == \"$HEAD_SHA\")] | .[0]" 2>/dev/null)

if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  echo "STATUS: no_runs"
  exit 0
fi

RUN_STATUS=$(echo "$LATEST" | jq -r '.status')
CONCLUSION=$(echo "$LATEST" | jq -r '.conclusion')
RUN_ID=$(echo "$LATEST" | jq -r '.databaseId')

# Poll if in progress — break as soon as >=1 job has failed or run completes
if [ "$RUN_STATUS" = "in_progress" ] || [ "$RUN_STATUS" = "queued" ] || [ "$RUN_STATUS" = "waiting" ] || [ "$RUN_STATUS" = "pending" ]; then
  echo "CI is running on branch: $BRANCH — polling every 60s (timeout 15m)" >&2

  DEADLINE=$(($(date +%s) + 900))

  while true; do
    if [ "$(date +%s)" -gt "$DEADLINE" ]; then
      echo "STATUS: timeout"
      echo "CI still running after 15 minutes"
      exit 1
    fi

    POLL=$(gh run view "$RUN_ID" --json jobs,status,conclusion \
      --jq '{status: .status, conclusion: .conclusion, failed: [.jobs[] | select(.conclusion == "failure")]}')

    RUN_STATUS=$(echo "$POLL" | jq -r '.status')
    CONCLUSION=$(echo "$POLL" | jq -r '.conclusion')
    FAILED_NOW=$(echo "$POLL" | jq '.failed')

    # Only break early if a reproducible job has failed — don't bail out just
    # because Cypress/E2E jobs failed while unit tests are still running
    REPRO_FAILED=$(echo "$FAILED_NOW" | jq '[.[] | select(.name | test("cypress|e2e|docker|gatekeeper"; "i") | not)]')
    REPRO_FAILED_COUNT=$(echo "$REPRO_FAILED" | jq 'length')

    if [ "$REPRO_FAILED_COUNT" -gt 0 ]; then
      FAILED="$FAILED_NOW"
      break
    fi

    if [ "$RUN_STATUS" = "completed" ]; then
      if [ "$CONCLUSION" = "success" ] || [ "$CONCLUSION" = "skipped" ]; then
        echo "STATUS: passing"
        echo "All checks passed on branch: $BRANCH"
        exit 0
      else
        # Run completed with failures — collect all failed jobs and break
        FAILED="$FAILED_NOW"
        break
      fi
    fi

    echo "  still running... ($(date '+%H:%M:%S'))" >&2
    sleep 60
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
  # Checkout Cypress integration tests can be run locally against the dev server (port 3001)
  echo "$1" | grep -qiE "cypress integration tests \(checkout" && echo "yes" && return
  echo "$1" | grep -qiE "cypress|e2e|docker|gatekeeper" && echo "no" || echo "yes"
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
  echo ""

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
done

echo "Logs written to: $OUT_DIR"
exit 1
