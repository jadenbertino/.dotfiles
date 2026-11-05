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

### What Datadog captures

- **Traces** cover the full request path: client → Vercel's edge network → the Next.js server → Neon's server → external dependencies. Use them to find where a request got slow or where it errored.
- **Request logs** include every header and the request body, with redaction:
  - Headers: Datadog shows only allowlisted headers in full and redacts the rest.
  - Body: the logger redacts individual fields from a blocklist, not whole routes. For fields that are only sometimes sensitive (e.g. `number`), it redacts only values that match a pattern, so a card number is hidden but a phone number or counter isn't.
- **Frontend errors** have source-mapped stack traces, so they point at our source code rather than minified bundles, and the trace for a given bug stays the same across new deploys.
- **Next.js server logs** go through the same logger as the server, so their attributes are formatted the same way and you can search on them.

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
