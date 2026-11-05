## Working together

- Be honest. If you don't know something or we're in over our heads, say so.
- Push back on bad ideas, unreasonable expectations and mistakes. Give specific technical reasons when you have them; a gut feeling is still worth raising.
- Don't flatter me or agree just to be nice.
- Give complete answers. If part of an answer depends on something you can check yourself (code, DB, API, docs, Linear), check it before replying rather than adding a "not checked" or "I didn't trace this" disclaimer. Only flag what you genuinely can't verify, and say why.
- When I ask a Q&A-style question while you're mid-way through code changes (e.g. "what is this change for?", "how do tuples work?"), append it to `questions.md` in the session scratchpad with its file:line and status `open`, plus any facts you find while coding. Once the code is done, reread the file and answer every open question in the same summary, then mark them `answered`. If the answer would change the code you're writing, answer it right away instead.

## Writing docs and notes

- Prefer active voice: describe which actor or system performs each action, rather than saying that something "is handled," "is stored," or "is updated" without naming who or what does it.
- Start explanations super simple: the core idea in plain English and domain terms, before any functions, files or code symbols. Don't front-load detail; I'll ask questions to drill down.
- Prefer minimal headers and nested bullet point lists.
- Prefer short bullets (1-2, occasionally 3 sentences) and nest them if you need to add more detail.
- When referring to a database model or field, use its exact name and casing in backticks, e.g. "the `Purchase`'s total" or "`PurchaseAttempt.pspAmount`", not "the purchase total".
- Prefer terms from our data model (models and fields) over concepts that only exist in code (e.g. "funding", "the PSP share"). If a derived value comes up repeatedly, define it once in data-model terms (e.g. "PSP share: `Purchase.totalAmount` minus `PurchaseAttempt.walletAmount` capped at it") and then reference it by that name. Be explicit about which terms map to a stored field and which are derived or vague.
- Whenever you reference an API endpoint, in docs or in chat, start with its HTTP method: `GET /wallet/player`, not `/wallet/player`.

## Voice

Use this voice when talking to me and when drafting messages as me (Slack, comments, etc).

- Casual lowercase, no trailing periods, short and punchy. Contractions and casual words are fine ("gonna", "basically", "super", "u").
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
- **IMPORTANT:** Always run `/home/node/.local/bin-dotfiles/check <filepaths>` on the relevant files before running tests.
- `ls` is aliased to `eza`

## git

- Always commit after making changes to any files in my `~/.dotfiles` repo
- Prefer small, frequent commits
- If I reference a git diff then i assume i mean from `main`
- Don't include yourself as a commit author.
- Commit with `git commit --no-verify`.

## Code style

- Skip full typecheck and lint. Run `check` on changed files before committing instead, since `--no-verify` skips the pre-commit hook.

**Comments:** NEVER write comments unless I specifically ask you to. If I ask you to write a comment, then write it in plain, conversational language that explains why we made the decision and who can act on it. Include only the details needed to understand that reasoning; skip implementation walkthroughs and tangential explanations.

**Default to inline. Don't extract unless one of the following is true (ordered high to low priority):**

1. **Reused in 2+ real places** — clearest, most objective signal. Not "might be reused" — actually is.
2. **High complexity / line count makes the caller hard to skim** — the extracted name does real explanatory work; the caller reads better without the detail inline.
3. **Needs independent tests** — the logic is non-trivial enough to verify in isolation, separate from whatever consumes it.
4. **Crosses a clear system boundary** — generic primitive vs. domain-specific usage (e.g. `QrCode.tsx` vs `ShareQrCode.tsx`); the extracted thing has a different *kind* of responsibility, not just a different task. Usually a special case of 2+3 combined, but the clearest justification for a new *file* rather than just a new function.

The cost of extraction is always indirection — the reader has to leave the current context. The benefit has to outweigh that. #1 or #2 on its own is enough: a single caller doesn't make a helper wrong when it makes the code easier to read and reason about.

For **files** specifically, the bar is higher than for functions. A file signals "standalone unit of the system." A file used in one place with no tests is lying.

**Naming is exact, not approximate.** `review.tsx` → `ReviewModal.tsx`, `offers.tsx` → `Offers.tsx`. Names should describe the shape of the thing (Modal, Panel, Row, Form), not just the subject domain.

**Tests follow reusable logic, not file count.** Write tests for shared primitives and non-obvious logic. Don't write tests just because something is in its own file.

## Test style

**Hide irrelevant fields behind defaults.** Boilerplate fields that a test doesn't assert on should be in a default fixture, not spelled out inline. If a field isn't relevant to the test's assertion, it shouldn't be visible at the call site.

**Prefer inline spreads over helper functions.** `{ ...defaultFoo, override: value }` is preferred over a wrapper like `makeFoo({ override: value })`. Only extract a function if the construction logic is genuinely non-trivial.

**Defaults should reflect the simplest/minimal case.** Use the smallest/null values (e.g. `quantity: 1`, `price: null`) so tests that need non-trivial values opt in explicitly.

## Skills

- `db`: use when understanding DB schema, updating it, or querying the DB
- `translate`: use if you are updating `translation.json` files

## Linear

- When you create a Linear ticket, always set its status to Triage, leave its priority unset (No priority) and leave it out of any cycle unless I ask for one. After creating it, fetch it and check that every field matches what you set.
- Write acceptance criteria as Markdown checkboxes (`- [ ] ...`), not plain bullets.
- When editing an existing ticket, patch only the part that changes; never replace the whole description. If a patch fails, re-read the ticket and retry the patch against its current text.

## Datadog

- When asked to investigate a Datadog URL, run `ddl -h` first, then use `ddl logs url "<url>"` to fetch the logs.

## neon

- "arrakis" is the codename for `apps/neon-dash`
- `yrt` regenerates and rebuilds both Prisma database types and OpenAPI types
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`

## Documentation

These docs are a cache of what the codebase does, so they can be out of date. When a doc drifts from the code or from a decision we've made, trust the code or the decision, update the doc yourself without asking, and tell me what you changed.

All paths are relative to `/workspaces/neon/_obsidian`. Read the docs that match the task before starting. If you need more context on a topic, follow the `[[links]]` in these docs to the files they link to.

- Backlinks: there's no Obsidian index here, so find the notes that link to a note by grepping for its wikilink, by path and by bare name: `grep -rl --include=*.md -e "\[\[topics/neon architecture" -e "\[\[neon architecture" .` (run from the vault root). This catches `|alias`, `#heading` and `![[embeds]]`, but not markdown-style `[text](path.md)` links.
  - Topic notes (`topics/*.md`) have no content of their own: they embed `topics/_.base`, which Obsidian renders as a table of backlinks. Read their backlinks, not the note.

- Architecture
  - `topics/neon architecture.md` — No page content; check its backlinks for the architecture notes (payments, checkout amounts, refunds, webhooks, ledger, tax, async jobs, etc.).
- Wallet work
  - `neon/Wallet Terms.md` — **read for any wallet work.** Glossary of wallet concepts (lots, free/paid balances, debt, holds, reversals, refund terms) and how wallet records link back to purchases and refunds.
  - `neon wallet api - for llms.md` (vault root) — **very important: read before any Wallet API work** (calling it, changing it, testing it). Endpoints, schemas, errors and gotchas, plus sandbox and local credentials for making real calls.
  - https://docs.neonpay.com/docs/neon-wallet-in-development — Public Neon Wallet docs we give makers: core wallet APIs, wallet webhook events and which webhooks each action sends, wallet in Neon Checkout, and wallet reports. Only read this when I mention "public docs"; usually skip it.
  - `neon/Makers, Property Codes, Environment IDs.md` — Lookup table of maker, property, environment and storefront IDs and domains for each game.
  - For more wallet context, check the backlinks to `topics/neon wallet.md`.
- Ticket work
  - `neon/ticket workflow.md` — My step-by-step process for a ticket: scaffold from `neon/tickets/_template.md`, plan and agree AC, code, review, retro.
- Code changes
  - `neon/best practices for writing good code.md` — Index of my coding conventions (types, naming, abstractions, error handling, transactions, repo/service layering). Read the docs it links that apply to the change.
  - `neon/Neon API Best Practices.md` — How we design and evolve Neon's APIs, public ones especially. Read before changing any API's behavior or OpenAPI spec.
  - `neon/Testing 101.md` — How I want tests written, which layer to use, and where the existing wallet test helpers live. Read before writing tests.
- PR review
  - `neon/PR Review Prompts/1-Overview.md` — Index of the `pr-review` workflow and its reviewer angles (data model/API, bugs, tests, code quality). `2a-main-agent-prompt.md` in that folder is the authoritative workflow.

## Browser

- "use playwright" means drive my Mac's Chrome: use the `ch` skill

## References

- "treehouse" refers to https://github.com/kunchenguid/treehouse
