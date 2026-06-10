---
name: gh-ci-fix
description: Identify GitHub Actions PR CI failures for the current branch, fetch failed job logs, diagnose repo-local causes, reproduce verifiable failures locally, implement fixes, run focused validation, commit, and push changes. Use when the user asks Codex to investigate failing CI, fix a broken PR branch, inspect PR CI logs, make CI pass, or push fixes for GitHub Actions failures in this repository.
---

# GitHub CI Fix

## Overview

Use this skill to take a branch from failing GitHub Actions CI to a committed and pushed fix. The operating loop is: detect the failing CI job, reproduce or approximate it locally, fix the repo, validate locally, commit, push, rerun the bundled CI helper, and repeat until CI is passing/no longer reporting actionable repo failures or you are genuinely blocked. Committing and pushing is the default outcome whenever a repo-local fix is made; stop short only when the user explicitly says not to stage, commit, or push.

## Quick Start

Run the bundled helper from the repo root. Resolve the path relative to this skill directory, not relative to the target repository:

```bash
scripts/fetch-pr-ci-failures.sh
```

Interpret the status:

- `STATUS: passing` or `STATUS: no_runs`: report that no CI fix is currently needed.
- `STATUS: failed`: inspect the printed `OUT_DIR` and the per-job log files.
- `STATUS: timeout`: report that CI did not produce a failed local target in time.

## Workflow

1. Confirm the working tree and branch:
   - Run `git status --short --branch`.
   - Do not overwrite or revert user changes.
   - Because this skill normally pushes fixes, verify the branch has an upstream or plan to push with `git push -u origin HEAD`.

2. Fetch CI failures:
   - Run the bundled `scripts/fetch-pr-ci-failures.sh` from this skill directory. Do not assume the target repository contains a `.agents/skills/gh-ci-fix/` copy.
   - If the helper exits `1` with `STATUS: failed`, continue; this is the expected failure path.
   - Read every failed job log under the printed `OUT_DIR`.
   - Prefer the first deterministic command failure over trailing summary noise.

3. Classify failures:
   - `LOCAL: yes`: reproduce locally before editing whenever practical.
   - `LOCAL: no`: inspect the log, infer likely repo causes, and run the closest focused local checks available.
   - Treat Cypress checkout integration jobs as locally verifiable when the helper marks them `LOCAL: yes`.
   - Do not stop only because a non-local job failed if local unit/type/lint jobs are still running and no reproducible failure has appeared.

4. Reproduce and diagnose:
   - Extract the actual command from the log and run it locally if it is safe and scoped.
   - Use repo-native tools (`yarn`, workspace scripts, `turbo run`, test filters) rather than inventing new commands.
   - Search the codebase with `rg` for failing symbols, test names, snapshots, migrations, or error text.
   - Keep investigation anchored to the failing job output; avoid broad refactors.

5. Implement the fix:
   - Make the smallest code or test change that addresses the diagnosed cause.
   - Preserve existing repo patterns and ownership boundaries.
   - Avoid changing snapshots, generated files, lockfiles, or migrations unless the failure requires it and the repo workflow supports it.

6. Validate:
   - Re-run the exact failing local command for `LOCAL: yes` jobs.
   - Run adjacent checks when the fix touches shared code, types, or behavior.
   - If the original failure is not locally reproducible, run the closest meaningful check and state the limitation.
   - Re-run the helper if useful to see whether new CI has started or additional failures have appeared.

7. Commit and push by default:
   - Review `git diff` and `git status --short`.
   - Stage and commit only intentional changes; do not include unrelated user changes.
   - Use a concise message that names the failure class fixed.
   - Push with `git push` when an upstream exists; otherwise use `git push -u origin HEAD`.
   - Do not leave verified fixes unstaged, uncommitted, or unpushed unless the user explicitly asked not to stage, commit, or push.
   - Report the commit SHA, pushed branch, validations run, and any CI jobs that still require remote confirmation.

8. Repeat until resolved:
   - After every push, rerun the bundled `scripts/fetch-pr-ci-failures.sh` against the pushed HEAD.
   - If it reports another `STATUS: failed` job with a repo-local cause, go back to diagnosis and continue the fix/validate/commit/push loop.
   - Stop only when the helper reports `STATUS: passing`, `STATUS: no_runs` for the pushed HEAD, only non-actionable infrastructure failures remain, or progress is blocked by missing user/external input.

## Failure Log Heuristics

- For TypeScript or lint failures, fix the source of the type or rule violation, not the emitted build artifact.
- For test failures, identify whether the failure is assertion drift, missing setup, race/timing, fixture data, or real product behavior.
- For dependency or package resolution failures, inspect workspace manifests and lockfiles before reinstalling dependencies.
- For E2E failures, inspect screenshots/videos/log snippets if available, then map the visible failure to the closest component, route, fixture, or API behavior.
- For flaky infrastructure signals, do not make code changes unless there is a concrete repo-side cause in the log.

## Bundled Resource

- `scripts/fetch-pr-ci-failures.sh`: Finds the latest `PR CI` run for the current branch HEAD, polls in-progress runs, writes cleaned failed job logs to `.tmp/neon-ci/<run-id>/`, and prints a machine-readable summary.
