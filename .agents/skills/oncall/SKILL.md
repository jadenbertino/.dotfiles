---
name: oncall
description: Investigates production issues using Datadog logs (ddl) and the production read-only database (psql). Use when the user invokes /oncall, shares a Datadog URL, or asks to investigate a production error, incident, or failure.
---

# Oncall

You're helping investigate a production issue. The user will provide context (e.g., Datadog URL, error details). Use the tools below to investigate and resolve the issue.

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

When you encounter something unfamiliar (an event type, error code, service behaviour), **look in the codebase first** before asking the user. Use grep/find/Read to trace the code path — most questions about "what does X do?" can be answered by reading the source. Only ask the user if you've genuinely exhausted the code and still can't determine the answer.

## Tips

- Datadog URLs with `live=true` use sliding time windows — if `ddl logs url` returns 0 results, the literal timestamps may be stale. Fall back to `ddl logs query` with `--from "15m ago"`.
- `psql service=prod-read` requires Tailscale to be active. If the connection fails, ask the user to run `! sudo tailscale up --accept-routes`.
- DB table names are PascalCase (e.g. `"MakerWebhookEvent"`, `"WebhookEventResult"`). Use `\dt` to list tables if unsure.
