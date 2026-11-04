---
name: oncall
description: Investigates production issues using Datadog logs (ddl) and the production read-only database (psql). Use when the user invokes /oncall, shares a Datadog URL, or asks to investigate a production error, incident, or failure.
---

# Oncall

You're helping investigate a production issue. The user will provide context (e.g., Datadog URL, error details). Use the tools below to investigate and resolve the issue.

## Incident doc

Every investigation gets an Obsidian doc, including ones that end up as a Bug or "not an incident".

1. Read the Notion page "On-Call Incident Response Process" (https://app.notion.com/p/3a55db1b290f800c835beb0172cfcc31) with the Notion MCP fetch tool. Use its live priority criteria and P1/P2 Maker and country lists; don't rely on memory.
2. Copy `/workspaces/neon/_obsidian/neon/post mortems/_template.md` to `/workspaces/neon/_obsidian/neon/post mortems/YYYY-MM-DD - <short title>.md` and tell the user the path.
3. Fill the doc as you investigate, not at the end. Findings go in the doc; keep chat to short progress updates.
   - Mark the priority as suggested, with the evidence for it. The user confirms it.
   - Generate the response checklist from that priority's rules on the Notion page. Never tick a checklist box or fill a "(human)" field yourself.
   - Every timeline event and impact number needs a Datadog link, query, or SQL behind it.
4. Trim the doc to fit the outcome:
   - **Bug:** keep Triage, Summary, Root Cause, Follow-ups (with the Linear ticket) and Investigation notes.
   - **Not an incident:** keep Triage (with why it isn't one) and Investigation notes.
5. Once the priority is confirmed, add it to the doc title and file name.

## psql

Read access to production database via `psql service=prod-read`.

## ddl

CLI tool for fetching Datadog logs. Run `ddl -h` for usage.

**Key commands:**

- `ddl logs url "<datadog-url>"` - Paste a Datadog URL directly
- `ddl logs query "<query>" --from "1h ago"` - Search with query string (max 15 days old)
- `ddl logs detail <hash>` - View full log json (use hash from search results)

**Source:** `/home/node/.local/bin-dotfiles/ddl` (read with `Read` tool if needed)

## Investigation approach

Use all three tools together — they complement each other:
- **ddl**: surface what happened and when (errors, warnings, request IDs, context)
- **psql**: confirm state in the DB (what status did the record end up in, how many attempts, what HTTP codes)
- **codebase**: explain *why* (trace the code path to understand what an error code means, whether a failure is fatal or handled, what a given event type does)

When you encounter something unfamiliar (an event type, error code, service behaviour), **look in the codebase first** before asking the user. Use grep/find/Read to trace the code path — most questions about "what does X do?" can be answered by reading the source. Only ask the user if you've genuinely exhausted all three tools and still can't determine the answer.

## Tips

- Datadog URLs with `live=true` use sliding time windows — if `ddl logs url` returns 0 results, the literal timestamps may be stale. Fall back to `ddl logs query` with `--from "15m ago"`.
- `psql service=prod-read` requires Tailscale to be active. If the connection fails, ask the user to run `! sudo tailscale up --accept-routes`.
- DB table names are PascalCase (e.g. `"MakerWebhookEvent"`, `"WebhookEventResult"`). Use `\dt` to list tables if unsure.
