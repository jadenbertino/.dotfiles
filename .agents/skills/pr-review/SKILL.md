---
name: pr-review
description: Review an explicit GitHub PR URL with four specialist reviewers, write separate Markdown reports, fix clear findings, discuss decisions, and open a follow-up PR. Use when asked to run this structured PR review workflow.
---

# PR review

Read and follow `/workspaces/neon/_obsidian/neon/PR Review Prompts/2a-main-agent-prompt.md` before starting. That Obsidian document is the source of truth for this skill’s workflow. If it is unavailable, ask the user for its location.

Use a separate checkout for the entire review and implementation. For Neon, default to `/workspaces/neon-2` unless the user names another checkout; follow the source workflow’s checkout setup and reuse instructions.

Agents may fix clear findings during the review. If a fix requires a product, domain, API, or convention decision, stop that fix and ask the user through the main agent. Coordinate edits to shared files before parallel reviewers change them.
