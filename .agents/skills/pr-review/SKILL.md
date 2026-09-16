---
name: pr-review
description: Review an explicit GitHub PR URL with five specialist reviewers, write separate Markdown reports, discuss and record decisions, then implement approved changes in a follow-up PR. Use when asked to run this structured PR review workflow.
---

# PR review

Require an explicit GitHub PR URL. If absent, ask for it; do not infer a PR from the current branch. This workflow has four phases. Finish the full discussion and obtain explicit approval before implementation.

## Guidance

The human-maintained reviewer prompts live in Obsidian, under `/workspaces/neon/_obsidian/neon/PR Review/`. Read `Review Guide.md` and resolve its links. If that vault location is unavailable, locate the same documents or ask for their location rather than inventing replacements.

Each reviewer reads its own prompt and referenced guidance. The main agent reads all five prompts. Preserve the original `/workspaces/neon/_obsidian/PR Review.md`; it is source material awaiting manual consolidation, not a replacement for the reviewer prompts.

## Phase 0: establish context and create reports

Resolve the supplied URL using GitHub metadata. Record repository owner/name, PR number/title/URL, head repository/branch/SHA, base repository/branch/SHA, and merge-base SHA. Review the pinned merge-base-to-head diff, not unrelated local changes. Use an isolated checkout when needed to inspect the pinned revision without disturbing user work.

Create a fresh run directory at `/tmp/pr-review/<owner>/<repo>/<pr-number>/<UTC-timestamp>/`; add a unique suffix on collision. Create all these files before starting reviewers:

```text
1-context.md
2-summary.md
2a-decisions.md
3a-data-model-and-api.md
3b-bugs.md
3c-tests.md
3d-consistency.md
3e-code-design.md
```

Write the resolved metadata, diff scope, checkout location, guidance paths, and review status to `1-context.md`. Initialize the summary and decision log with headings, and each reviewer report with its angle and pending status. Never confuse a pending/failed review with a completed review containing no findings. Use these exact paths throughout the run and show the user the run directory.

## Phase 1: independent specialist reviews

Launch all five reviewers by default, in parallel up to the available agent limit; queue remaining reviewers as slots become available. Each receives the entire pinned diff, surrounding-code access, context file, its own Obsidian prompt, and its assigned report path. Do not communicate the main agent's angle ranking to reviewers. Give each a narrowly scoped assignment; do not fork unrelated review discussions or other reviewers' conclusions into its context.

| Reviewer prompt | Report |
| --- | --- |
| Data Model and API.md | 3a-data-model-and-api.md |
| Bugs.md | 3b-bugs.md |
| Tests.md | 3c-tests.md |
| Consistency and Best Practices.md | 3d-consistency.md |
| Code Design.md | 3e-code-design.md |

Review is read-only except for assigned report files. Do not edit application code, guidance, or tests; run tests; commit; or publish GitHub comments during review. Reviewers may read necessary surrounding files and use read-only inspection tools. Follow applicable repository and skill instructions.

Require each report to contain:

- Completion status and scope examined, including limitations.
- Findings with local IDs, proposed severity, code path/line, evidence, consequence, and recommended action. Bugs require a plausible trigger and incorrect observable behavior. Convention findings cite the relevant guideline or existing pattern.
- Unresolved questions distinguished from established findings.
- Existing unrelated issues and broader refactors in a separate follow-up section.
- An explicit statement when there are no relevant findings; never manufacture feedback.

The tests reviewer performs two passes in the same `3c-tests.md`:

1. Independently inspect coverage and test quality without reading the bugs report. Save the first pass and report its completion.
2. After the bugs report is complete, resume the tests reviewer with that report. Append prioritized regression-test recommendations referencing bug finding IDs; preserve the first pass and avoid duplicate recommendations. Treat uncertain bug claims as uncertain, not proven.

Wait for all five reviews and the tests second pass before final triage. Retry failed reviews where feasible; disclose unresolved missing coverage before discussion.

## Phase 2: verify, prioritize, and discuss

Read every report and verify findings against the pinned code. Consolidate duplicates while retaining source IDs. Assign stable consolidated IDs such as `R001`; do not renumber existing IDs as priorities change. Record dismissed findings and reasons rather than silently dropping them.

Group actionable findings by severity in `2-summary.md`, separating questions and follow-up work. Severity comes first. Within comparable severity, the main agent's angle preference is data model/API, bugs, tests, consistency, then code design. This ranking is not part of specialist prompts.

Use the following embedded discussion workflow; do not depend on an installed grilling skill:

- Map decisions and their dependencies. In each round, ask the questions whose prerequisites are settled; defer dependent questions to later rounds. Group related findings into manageable rounds and work through higher priorities first.
- Number each question, explain the decision and tradeoffs, and give a recommended answer. Use `❓ **Q1 — Title:** ...` followed by `➡️ Recommendation`.
- Investigate facts yourself using code/docs or a bounded research subagent; ask the user for decisions, not facts available in the environment. Continue independent questions while research is pending.
- Wait for user answers, then update the remaining decision tree. Do not infer approval from silence.
- Record every decision in `2a-decisions.md`, including its question, related finding IDs, user answer, agreed action/rationale, and unresolved dependencies. Keep `2-summary.md` dispositions synchronized: pending, accepted, rejected, deferred, or implemented.
- Treat proposed changes to the coding guide or reviewer prompts like code changes: discuss, record, and require explicit approval. Distinguish approval of a local code fix from approval of a reusable convention.

Finish the entire discussion before implementing any subset. Once no decisions remain unresolved, present the concrete agreed implementation scope, deferred work, and guide/prompt updates, then obtain explicit approval to enter phase 3.

## Phase 3: implement approved decisions

Recheck the original PR head before implementation. If it changed since review, assess the intervening diff and resolve affected decisions before applying the plan; do not silently use stale conclusions.

Create a new branch from the reviewed PR head. Implement only the fully discussed, explicitly approved changes, including any approved guide/prompt updates. Keep broader refactors deferred unless separately agreed.

Verify changes using the repository's applicable checks and testing instructions. Make small commits ideally tied to consolidated finding IDs; avoid unrelated work. Push the new branch and open a follow-up PR targeting the original PR's **head branch**, not its base. For forks, resolve the correct target repository and permissions from phase-0 metadata rather than guessing. If that target is no longer usable, discuss the new target with the user.

Reference resolved finding IDs and validation in commit messages/PR description where useful. Record commit SHAs, verification outcomes, the new PR URL, and any guidance changes in the run artifacts. Follow repository-specific commit requirements for separately stored guidance. Do not claim completion while agreed implementation remains unfinished.
