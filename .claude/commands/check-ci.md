Continuously fetch, fix, and push until CI is fully green on the current branch.

Uses `~/ci.sh`, which fetches the latest PR CI run for the current branch, polls
until it completes (or a failure is detected early), downloads per-job logs, and
classifies each failure as locally verifiable or not.

## Outer loop

Repeat until done (max 5 push cycles before stopping):

1. Run `bash ~/ci.sh` **in the background** (`run_in_background: true`) — it blocks
   and polls for up to 30 minutes. You will be notified when it finishes; read its
   output to get the `STATUS:` line and failure details.
2. Check the `STATUS:` line:
   - `passing` / `no_runs` → stop, CI is green
   - `timeout` → stop with error: "CI timed out after 30 minutes"
   - `failed` → fix (see Fix steps below), then return to step 1
3. After 5 push cycles with no green result, stop and report what's still failing.

## Script output format (when STATUS is `failed`)

```
STATUS: failed
RUN_ID: <id>
OUT_DIR: /workspaces/neon/.tmp/neon-ci/<run-id>/

=== FAILED JOBS ===

JOB: web-ci / Server Unit Tests (3)
LOCAL: yes
LOG: /workspaces/neon/.tmp/neon-ci/<run-id>/server-unit-tests-3-.txt

JOB: shared / check-translations
LOCAL: yes
LOG: /workspaces/neon/.tmp/neon-ci/<run-id>/check-translations.txt

JOB: merge-gatekeeper
LOCAL: no
LOG: /workspaces/neon/.tmp/neon-ci/<run-id>/merge-gatekeeper.txt
```

`LOCAL: yes` means the failure can be reproduced and verified locally.
`LOCAL: no` means you can read the log and attempt a fix, but cannot verify it runs green before pushing.

## Why certain jobs are LOCAL: no

- **Staging E2E** — runs against a deployed staging environment; no local equivalent.
- **Console Cypress** — needs a separately seeded dataset and the console dev server
  on port 3003; not straightforward to set up locally.
- **Docker** — builds and pushes images; requires a Docker daemon and registry credentials.
- **Gatekeeper** — a GitHub-side merge guard, not a runnable test.

## Fix steps (when STATUS is `failed`)

1. Read each job's `LOG:` file to understand the error.
2. Fix all failing jobs in one pass before re-verifying anything.
3. For `LOCAL: yes` jobs, verify fixes by running the local command and redirecting
   output to a temp file — never rely on scrollback:
   ```bash
   yarn workspace server test > .tmp/test-out.txt 2>&1 || true
   # then Read or grep .tmp/test-out.txt for failures
   ```
4. For `LOCAL: no` jobs, fix based on log content only; skip local verification.
5. After all `LOCAL: yes` commands pass, run lint/typecheck for every affected
   workspace — fixes can introduce type or lint regressions.
6. Stage only changed source files, commit, and `git push`.
7. Return to the outer loop.

## Local command by job type

| Job name pattern | Local command |
|---|---|
| `Unit Tests (storefront)` | `yarn workspace storefront test` |
| `Unit Tests (console)` | `yarn workspace console test` |
| `Unit Tests (neon-dash)` | `yarn workspace neon-dash test` |
| `Unit Tests (neon-js)` | `yarn workspace neon-js test` |
| `Unit Tests (checkout)` | `yarn workspace checkout test` |
| `Server Unit Tests` | `yarn workspace server test` |
| `check-translations` | `yarn workspace <app> run check-translations` |
| `Cypress integration tests (checkout, ...)` | see below |
| `Cypress integration tests (neon-js, ...)` | see below |

If a job doesn't match, derive the workspace from the job title.

## Running Cypress integration tests locally

**Prerequisite:** The test checkout session must exist in the local DB. If the
backend returns 404 for the fixture URL, run the seed first:
```bash
yarn run db:setup
```
This is idempotent (upserts) and safe to re-run against the existing local DB.

Both the API server (port 8080) and the relevant app dev server must be running.
Checkout and neon-js dev servers are already up in this environment (ports 3001 and 3010).

Read the failing log to identify which spec file failed, then run it directly —
omit `--record` since Cypress Cloud credentials are not available locally:

```bash
# checkout
cd apps/checkout && npx cypress run --spec 'cypress/integration/<failing-spec>.cy.ts'

# neon-js
cd apps/neon-js && npx cypress run --spec 'cypress/integration/<failing-spec>.cy.ts'
```

## Fix rules

- If the same root cause appears across multiple jobs, fix it once — don't duplicate.
- Never commit files that look like secrets or generated artifacts.
