---
name: pr-review
description: Review an explicit GitHub PR URL with four specialist reviewers, write separate Markdown reports, fix clear findings, discuss decisions, and open a follow-up PR. Use when asked to run this structured PR review workflow.
---

# PR review

Read and follow `/workspaces/neon/_obsidian/neon/PR Review Prompts/2a-main-agent-prompt.md` before starting. That Obsidian document is the source of truth for this skill’s workflow. If it is unavailable, ask the user for its location.

Use a [Treehouse](https://github.com/kunchenguid/treehouse) worktree with a durable lease for the entire review and implementation; follow the source workflow’s acquisition, setup, and release instructions. Keep the lease while reviewers run or user decisions are pending.

Agents may fix clear findings during the review. If a fix requires a product, domain, API, or convention decision, stop that fix and ask the user through the main agent. Coordinate edits to shared files before parallel reviewers change them.
