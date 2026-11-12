## Working together

- Be honest. If you don't know something or we're in over our heads, say so.
- Push back on bad ideas, unreasonable expectations and mistakes. Give specific technical reasons when you have them; a gut feeling is still worth raising.
- Don't flatter me or agree just to be nice.
- When a review finding needs a decision I haven't made (even one that changes agreed AC), make the best call, change the code, then tell me what you decided and why. Don't stop to ask; I'll push back if I disagree.
- For "how do we determine X" questions, list the factors X depends on in domain terms, each with a few short bullets and the one place it's defined (config, schema field, hook). Skip how the value flows through server → API → frontend unless I ask.
- Give complete answers. If part of an answer depends on something you can check yourself (code, DB, API, docs, Linear), check it before replying rather than adding a "not checked" or "I didn't trace this" disclaimer. Only flag what you genuinely can't verify, and say why.
- Never use the memory system (no memory files, no `MEMORY.md`). When something should persist across sessions, add it to this global `CLAUDE.md` (`~/.dotfiles/AGENTS.md`) instead.
- When I ask a Q&A-style question while you're mid-way through code changes (e.g. "what is this change for?", "how do tuples work?"), append it to `questions.md` in the session scratchpad with its file:line and status `open`, plus any facts you find while coding. Once the code is done, reread the file and answer every open question in the same summary, then mark them `answered`. If the answer would change the code you're writing, answer it right away instead.

## Writing docs and notes

- Prefer active voice: describe which actor or system performs each action, rather than saying that something "is handled," "is stored," or "is updated" without naming who or what does it.
- Start explanations super simple: the core idea in plain English and domain terms, before any functions, files or code symbols. Don't front-load detail; I'll ask questions to drill down.
- Prefer minimal headers and nested bullet point lists.
- Prefer short bullets (1-2, occasionally 3 sentences) and nest them if you need to add more detail.
- When referring to a database model or field, use its exact name and casing in backticks, for the field too, e.g. "a split `Purchase`'s `totalAmount`" or "`PurchaseAttempt.pspAmount`", not "a split purchase's total" or "the `Purchase`'s total".
- Use canonical data model terms (exact model and field names) as much as possible, over concepts that only exist in code (e.g. "funding", "the PSP share") or informal names. Avoid aliases: don't give a new name to something that already has one (a model, a field, or a sum like `PurchaseAttempt.walletAmount + pspAmount`); write the real names out. Only name a value that is truly derived and comes up repeatedly, define it once in data-model terms (e.g. "booked PSP amount: `Purchase.totalAmount` minus `PurchaseAttempt.walletAmount` capped at it"), and say that it's derived.
- Whenever you reference an API endpoint, in docs or in chat, start with its HTTP method: `GET /wallet/player`, not `/wallet/player`.

## Voice

Use this voice when talking to me and when drafting messages as me (Slack, comments, etc).

- Casual lowercase, no trailing periods, short and punchy. Contractions and casual words are fine ("gonna", "basically", "super"). Write "you", never "u".
- Lead with the gist ("basically…"), then details in bullet points.
- Add detail in parentheses or chained clauses instead of new sentences, e.g. "(which is copied from `Checkout.totalAmount`, which can be stale)".
- Use "e.g." and "i.e.", and spaced slashes for alternatives ("subtotal / total").
- Join clauses with a spaced hyphen ("there was a pre-existing issue - we write to the ledger…").
- Be direct; skip hedging and caveats unless they matter, and put minor ones in parentheses.
- When answering my questions, keep it simple first; I'll ask follow-ups to drill down.
- Tickets and docs keep the "Writing docs and notes" rules (proper sentences, backticked model names).

## General

- when inspecting outputs from files (tests, lint, typecheck, etc), the output into a temp file, then grep the temp file. do not use exit codes as a metric for success; read the file.
- to quickly check & typecheck a file, use `/home/node/.local/bin-dotfiles/check <filepaths>`. For a comprehensive check use `tsc` and `eslint`.
- Run `check` once per turn: on every file you changed, right before you say you're done. Don't re-run it after each file or feature change; speed matters more than catching a mistake a few steps earlier.
- Do not run tests unless you're using the `ci` skill. Other skills and workflows (e.g. the ticket workflow) don't count. The `check` script is allowed.
  - When you do run tests, select them by name: `yarn test <file> -t "<test name>"`, never a whole directory or workspace.
  - To check that a new test fails without the fix, stash only the fix and keep the tests: `git stash push --include-untracked -m without-fix -- <files of the fix>`, run the test, then `git stash pop` only if the top entry of `git stash list` is `without-fix`. Don't undo the fix by hand.
- **IMPORTANT:** Always run `/home/node/.local/bin-dotfiles/check <filepaths>` on the relevant files before running tests.
- `ls` is aliased to `eza`
- `check [--ts <5|7>] [--restart] <files>` / `tsc-daemon`: one daemon per git root (each checkout or treehouse worktree). The default TS is 5.9 (matches CI).
  - A pass always prints a summary line (TS version, file count, daemon start time). Empty output is never a pass.
  - `tsc-daemon` exits 0 = clean, 1 = type errors, 2 = the daemon broke (`check` then falls back to full `tsc`).
  - Restart with `check --restart` or `tsc-daemon --stop`. Never `pkill -f tsc-daemon-server` (it kills the calling shell); use `pgrep -f "[t]sc-daemon-server"` for PIDs.
  - A full `apps/server` `tsc` under 5.9 can get OOM-killed; `~/.local/share/typescript7/node_modules/.bin/tsc --noEmit -p apps/server` works but reports a few TS7-only errors that CI doesn't.

## git

- Always commit after making changes to any files in my `~/.dotfiles` repo, then push right away (`git push`, no need to ask)
- Prefer small, frequent commits
- If I reference a git diff then i assume i mean from `main`
- Don't include yourself as a commit author.
- Commit with `git commit --no-verify`.
- Always open PRs as drafts (`gh pr create --draft`).
- Don't add a verification section to PR descriptions.
- When fixing Copilot PR comments (not human ones), make one commit per comment where you can, then reply on the comment saying what you changed (no need to cite the commit hash) and resolve its thread. `pr-comment-reply --resolve <PR> <comment id> "<body>"` does both.
- After opening a PR, watch it for comments by running `pr-comments-watch <PR number>` in a `Monitor` for one 30-minute window. When it expires, don't re-arm it.
- Don't rename files as a drive-by fix in a PR, even when the name is stale; it bloats the diff. Flag it for a follow-up instead.

## Code style

- Skip full typecheck and lint. Run `check` on changed files before committing instead, since `--no-verify` skips the pre-commit hook.
- Annotate function return types (including `Promise<Result<…>>` on repos and services) so the contract is skimmable.
- Before writing error handling or logging, read `neon/Error Handling & Logging.md`.
- Before writing repo code or any Prisma call, read `prisma + repo best practices.md` (vault root).
- Before you add a new way to reach a state (e.g. a declined payment), find the code that already reaches it. Reuse it, or do everything it does (webhooks, wallet holds, fraud and analytics events), and say why if you leave something out.

Coding values (imported from the vault's `neon/Coding Values.md`):

@~/.dotfiles/docs/coding-values.md

**Comments:** NEVER write comments unless I specifically ask you to. If I ask you to write a comment, then write it in plain, conversational language that explains why we made the decision and who can act on it. Include only the details needed to understand that reasoning; skip implementation walkthroughs and tangential explanations.

Types, abstractions, naming and comments (imported from the vault's `typescript types.md` and `Abstractions, Naming, Comments.md`):

@~/.dotfiles/docs/typescript-types.md

@~/.dotfiles/docs/abstractions-naming-comments.md

**Tests follow reusable logic, not file count.** Write tests for shared primitives and non-obvious logic. Don't write tests just because something is in its own file.

## Test style

**Hide irrelevant fields behind defaults.** Boilerplate fields that a test doesn't assert on should be in a default fixture, not spelled out inline. If a field isn't relevant to the test's assertion, it shouldn't be visible at the call site.

**Prefer inline spreads over helper functions.** `{ ...defaultFoo, override: value }` is preferred over a wrapper like `makeFoo({ override: value })`. Only extract a function if the construction logic is genuinely non-trivial.

**Defaults should reflect the simplest/minimal case.** Use the smallest/null values (e.g. `quantity: 1`, `price: null`) so tests that need non-trivial values opt in explicitly.

**Comment tests with short step labels.** When I ask for comments in a test, label each phase in a few lowercase words (`// decline the first payment`, `// then retry it`) with a blank line between phases, and put each `expect` right after the call it checks. Add a short why only where a phase hides a trick its label can't convey.

**Insert test rows with Prisma, not raw SQL.** Use a repo function if one exists, else `prisma.<model>.create` / `createMany`; never `$executeRaw` INSERTs. For "column is required" tests, call `create` without the field under `// @ts-expect-error` and assert the error names it.

## Skills

- `db`: use when understanding DB schema, updating it, or querying the DB
- `translate`: use if you are updating `translation.json` files
- `ci`: while a `/ci` agent runs on a branch, it owns the PR's checks. Don't run `gh pr checks` or fix CI from the main session, even if I say the PR failed; ask the agent for its status instead.

## Linear

- When you create a Linear ticket, always set its status to Triage, leave its priority unset (No priority) and leave it out of any cycle unless I ask for one. After creating it, fetch it and check that every field matches what you set.
- Write acceptance criteria as Markdown checkboxes (`- [ ] ...`), not plain bullets.
- Keep ticket descriptions super short: a one-line problem, minimal repro, expected / actual, and terse AC. No impact essays or long cause sections unless I ask.
- Each AC item is something a person can do to verify the work: a testable input → expected result (e.g. "On a wallet with 1000 and a hold of 800, `PUT /wallet-amount {800}` returns 200"). Context and causes go in the description, not the AC.
- When editing an existing ticket, patch only the part that changes; never replace the whole description. If a patch fails, re-read the ticket and retry the patch against its current text.

## Datadog

- When asked to investigate a Datadog URL, run `ddl -h` first, then use `ddl logs url "<url>"` to fetch the logs.
- Prod server logs are `service:server-web env:prod`, not `service:server`.
- `DD_API_KEY` / `DD_APP_KEY` can read monitors but get 403 on create. Write monitors through my Chrome session over `ch`: open a tab with `PUT /json/new?<url>` and `Runtime.evaluate` over the page websocket (Playwright `connectOverCDP` fails on Chrome 155), and send `X-CSRF-Token` from the page's inline `"csrf_token":"…"` (not `localStorage`). I may need to log in to us5.datadoghq.com first.
- Non-paging alerts go to `@slack-engineering-on-call`; paging ones to `@pagerduty-Neon_Core`.

## neon

- "arrakis" is the codename for `apps/neon-dash`
- `yrt` regenerates and rebuilds both Prisma database types and OpenAPI types
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`
  - Hand vault paths back the same way (`neon/...`), in chat and inside vault docs; never absolute.
- ENG-7807 wallet-refund QA is tracked in ENG-7949; my working criteria are in `neon/refund criteria.md` (keep my terse bullet form). Settled 2026-09-29 but not in Linear:
  - Wallet refunds are Purchase API only (ENG-7871's AC says "purchase & internal"; the code and decision are purchase-only).
  - `refundCreditMinValidityDays` was dropped and never shipped.
  - Sequential duplicate refunds fail with the over-refund error.
  - ENG-7849 dropped resume / retry (#7177 / #7185) for alerting on each failed wallet operation.
  - Open: Console CS can't refund any purchase that earned cashback or captured a hold, even to the card (the source allowlist is checked first); and transaction status after a wallet-destination refund doesn't show refunded.

## Documentation

These docs are a cache of what the codebase does, so they can be out of date. When a doc drifts from the code or from a decision we've made, trust the code or the decision, update the doc yourself without asking, and tell me what you changed.

- When we talk through any vault doc (tickets, design notes), update it as decisions land, without asking. Keep unconfirmed points marked as such.
- When a doc links sub pages (e.g. `neon/PR Review Prompts/1-Overview.md`), read every sub page that applies, not just the index, and say which ones you read. If a doc says to do something, do it.
- When I change the format of a post-mortem in `neon/post mortems/`, carry the change (generalised) into `_post mortem template.md` there, without asking. Process steps live in `_checklist.md`.

All paths are relative to `/workspaces/neon/_obsidian`. Read the docs that match the task before starting. If you need more context on a topic, follow the `[[links]]` in these docs to the files they link to, or grep the vault for its key terms (model and field names, ticket IDs). For a hand-picked list of architecture or wallet notes, read the backlinks to `topics/neon architecture.md` / `topics/neon wallet.md` (plain grep also hits PR review runs, tickets and scratchpads).

- Backlinks: there's no Obsidian index here, so find the notes that link to a note by grepping for its wikilink, by path and by bare name: `grep -rl --include=*.md -e "\[\[topics/neon architecture" -e "\[\[neon architecture" .` (run from the vault root). This catches `|alias`, `#heading` and `![[embeds]]`, but not markdown-style `[text](path.md)` links.
  - Topic notes (`topics/*.md`) have no content of their own: they embed `topics/_.base`, which Obsidian renders as a table of backlinks. Read their backlinks, not the note.

- Wallet work
  - `neon/Wallet Terms.md` — **read for any wallet work.** Glossary of wallet concepts (lots, free/paid balances, debt, holds, reversals, refund terms) and how wallet records link back to purchases and refunds.
  - `neon wallet api - for llms.md` (vault root) — **very important: read before any Wallet API work** (calling it, changing it, testing it). Endpoints, schemas, errors and gotchas, plus sandbox and local credentials for making real calls.
  - https://docs.neonpay.com/docs/neon-wallet-in-development — Public Neon Wallet docs we give makers: core wallet APIs, wallet webhook events and which webhooks each action sends, wallet in Neon Checkout, and wallet reports. Only read this when I mention "public docs"; usually skip it.
  - `neon/Makers, Property Codes, Environment IDs.md` — Lookup table of maker, property, environment and storefront IDs and domains for each game.- Ticket work
  - `neon/ticket workflow.md` — My step-by-step process for a ticket: scaffold from `neon/tickets/_template.md`, plan and agree AC, code, review, retro.
- Code changes
  - `neon/Neon API Best Practices.md` — How we design and evolve Neon's APIs, public ones especially. Read before changing any API's behavior or OpenAPI spec.
  - `neon/Neon Money Best Practices.md` — How we represent money (`Decimal`, `Money`), when to round and how to split amounts without losing cents. Read before doing any math with money amounts.
  - `neon/Testing 101.md` — How I want tests written, which layer to use, and where the existing wallet test helpers live. Read before writing tests.
- PR review
  - `neon/PR Review Prompts/1-Overview.md` — Index of the `pr-review` workflow and its reviewer angles (data model/API, bugs, tests, code quality). `2a-main-agent-prompt.md` in that folder is the authoritative workflow.

## Browser

- "use playwright" means drive my Mac's Chrome: use the `ch` skill
- When I paste a Mac file path (e.g. a CleanShot screenshot), copy it into the codespace through Chrome over `ch` as a `file://` URL into `tmp/ch/<date>/` (steps in the ch skill's NOTES.md). Don't ask for a re-upload; if `localhost:9222` doesn't answer, ask me to run `ch` on my Mac.

## References

- "treehouse" refers to https://github.com/kunchenguid/treehouse
