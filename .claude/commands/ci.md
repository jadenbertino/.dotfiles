Continuously fetch, fix, and push until CI is fully green on the current branch.

## Outer loop

Repeat until done (max 5 push cycles before stopping):

1. Run `bash ~/.claude/commands/ci.sh` **in the background** (`run_in_background: true`) — it blocks and polls for up to 15 minutes. Running it in the background prevents context timeout and lets you be notified when it completes. You will receive a task notification with the output file path — read that file to get the `STATUS:` line and any failure details.
2. Check the `STATUS:` line:
   - `passing` / `no_runs` → stop, CI is green
   - `timeout` → stop with error: "CI timed out after 15 minutes"
   - `failed` → fix (see Fix steps below), then go back to step 1
3. After 5 push cycles with no green result, stop and report what's still failing.

## Fix steps (when STATUS is `failed`)

1. For each job in the output, read its `LOG:` file to understand the errors.
2. Classify each failing job by its `LOCAL:` flag and error type:
   - **Lint / typecheck / format** failures (`LOCAL: yes`) → fix using the appropriate lint/typecheck commands for the workspace
   - **Test** failures (`LOCAL: yes`) → fix using the job's local command (see table below)
   - **Any** failure with `LOCAL: no` → attempt fixes based on log content only; skip local verification for that job
3. Fix all errors across all jobs in one pass before re-verifying anything.
4. Verify fixes for `LOCAL: yes` jobs by running commands and redirecting output to a temp file, then read/grep the file for results — never rely on scrollback:
   ```
   yarn workspace storefront test > .tmp/test-out.txt 2>&1 || true
   # then Read or grep .tmp/test-out.txt for failures
   ```
   - Lint/typecheck/format: run the appropriate lint/typecheck commands for the workspace (same redirect pattern)
   - Tests: the job's local command
5. Once all `LOCAL: yes` commands pass, run lint/typecheck for all affected workspaces as a final gate — fixes can introduce lint/type regressions.
6. Once everything passes:
   - Stage only changed source files
   - Commit with a message describing what was fixed (e.g. `fix: mock next/font in storefront vitest setup`)
   - `git push`
7. Return to the outer loop.

## Test job → local command

| Job name pattern | Local command |
|---|---|
| `Unit Tests (storefront)` | `yarn workspace storefront test` |
| `Unit Tests (console)` | `yarn workspace console test` |
| `Unit Tests (neon-dash)` | `yarn workspace neon-dash test` |
| `Unit Tests (neon-js)` | `yarn workspace neon-js test` |
| `Unit Tests (checkout)` | `yarn workspace checkout test` |
| `Server Unit Tests` | `yarn workspace server test` |
| `Cypress integration tests (checkout, ...)` | `cd apps/checkout && npx cypress run --browser chrome-for-testing --spec 'cypress/integration/<failing-spec>.cy.ts'` |

If a job doesn't match a pattern, derive the workspace from the job title.

### Running Cypress integration tests locally

The checkout Cypress integration tests run against the local Next.js dev server on port 3001 (already running in this environment). Read the failing log to identify which spec file failed, then run it directly:

```bash
cd apps/checkout && npx cypress run --browser chrome-for-testing --spec 'cypress/integration/wechat-pay-qr.cy.ts'
```

**Important:** The dev server at `http://localhost:8080` (backend) will return 404 for fixture checkout IDs that don't exist in the local DB, causing Next.js SSR to return `notFound: true` and the page to 404. If you hit this, insert a minimal checkout row into the local DB:

```sql
-- Run in psql service=local
INSERT INTO "Checkout" (id, "createdAt", "updatedAt", "makerId", currency, status,
  "subtotalAmount", "taxAmount", "totalAmount", "cancelUrl", "successUrl", "isSandbox",
  "propertyAccountId", "languageLocale", "playerCountry", "taxRate", "storeUrl",
  "displayConfigId", "environmentId", "shouldCreateAccount", "returnUrl",
  "userId", "shouldSubscribeToMarketing", "initialCurrency", "initialPlayerCountry", "isFallback"
) VALUES (
  '<checkout-id-from-fixture>', NOW(), NOW(),
  'aaaaaaaa-7d85-42de-9e51-990bce67b2f4', 'USD', 'open',
  500, 0, 500, 'http://localhost:3010/checkout.html', 'http://localhost:3010/checkout.html', true,
  'account ID', 'en-US', 'US', 0, 'http://localhost:3010',
  '2b10571e-3e74-4a36-b8c5-8d5ed2a23acb', 'eeeeeeee-7d85-42de-9e51-990bce67b2f4',
  false, 'http://localhost:3010/checkout.html',
  '9a7e1839-a6cb-47fe-ab13-1ca8fd5bd9de', false, 'USD', 'US', false
) ON CONFLICT (id) DO NOTHING;
```

The backend returning a 500 (e.g. missing related data) is fine — SSR falls through to an empty-props response and Cypress intercepts do the rest.

## Fix rules and safety

If the same root cause appears across multiple jobs, fix it once — don't duplicate.
