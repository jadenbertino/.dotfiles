## Working together

- Be honest. If you don't know something or we're in over our heads, say so.
- Push back on bad ideas, unreasonable expectations and mistakes. Give specific technical reasons when you have them; a gut feeling is still worth raising.
- Don't flatter me or agree just to be nice.

## Writing docs and notes

- Prefer active voice: describe which actor or system performs each action, rather than saying that something "is handled," "is stored," or "is updated" without naming who or what does it.
- Prefer conceptual explanations first: use precise domain terminology to describe the domain model, lifecycle, and data flow in plain English before referencing specific functions, files, or code symbols.
- Prefer minimal headers and nested bullet point lists.
- Prefer short bullets (1-2, occasionally 3 sentences) and nest them if you need to add more detail.

## General

- when inspecting outputs from files (tests, lint, typecheck, etc), the output into a temp file, then grep the temp file. do not use exit codes as a metric for success; read the file.
- to quickly check & typecheck a file, use `/home/node/.local/bin-dotfiles/check <filepaths>`. For a comprehensive check use `tsc` and `eslint`.
- Do not run tests unless the user or an applicable skill explicitly tells you to. The `check` script is allowed.
- **IMPORTANT:** Always run `/home/node/.local/bin-dotfiles/check <filepaths>` on the relevant files before running tests.
- `ls` is aliased to `eza`

## git

- Always commit after making changes to any files in my `~/.dotfiles` repo
- Prefer small, frequent commits
- If I reference a git diff then i assume i mean from `main`
- Don't include yourself as a commit author.

## Code style

- Skip typecheck and lint. Allow the pre-commit hook to handle these checks.

**Comments:** NEVER write comments unless I specifically ask you to. If I ask you to write a comment, then write it in plain, conversational language that explains why we made the decision and who can act on it. Include only the details needed to understand that reasoning; skip implementation walkthroughs and tangential explanations.

**Default to inline. Don't extract unless one of the following is true (ordered high to low priority):**

1. **Reused in 2+ real places** — clearest, most objective signal. Not "might be reused" — actually is.
2. **High complexity / line count makes the caller hard to skim** — the extracted name does real explanatory work; the caller reads better without the detail inline.
3. **Needs independent tests** — the logic is non-trivial enough to verify in isolation, separate from whatever consumes it.
4. **Crosses a clear system boundary** — generic primitive vs. domain-specific usage (e.g. `QrCode.tsx` vs `ShareQrCode.tsx`); the extracted thing has a different *kind* of responsibility, not just a different task. Usually a special case of 2+3 combined, but the clearest justification for a new *file* rather than just a new function.

The cost of extraction is always indirection — the reader has to leave the current context. The benefit has to outweigh that. One signal alone rarely justifies it.

For **files** specifically, the bar is higher than for functions. A file signals "standalone unit of the system." A file used in one place with no tests is lying.

**Naming is exact, not approximate.** `review.tsx` → `ReviewModal.tsx`, `offers.tsx` → `Offers.tsx`. Names should describe the shape of the thing (Modal, Panel, Row, Form), not just the subject domain.

**Tests follow reusable logic, not file count.** Write tests for shared primitives and non-obvious logic. Don't write tests just because something is in its own file.

## Test style

**Hide irrelevant fields behind defaults.** Boilerplate fields that a test doesn't assert on should be in a default fixture, not spelled out inline. If a field isn't relevant to the test's assertion, it shouldn't be visible at the call site.

**Prefer inline spreads over helper functions.** `{ ...defaultFoo, override: value }` is preferred over a wrapper like `makeFoo({ override: value })`. Only extract a function if the construction logic is genuinely non-trivial.

**Defaults should reflect the simplest/minimal case.** Use the smallest/null values (e.g. `quantity: 1`, `price: null`) so tests that need non-trivial values opt in explicitly.

## Skills

- `db`: use when understanding DB schema, updating it, or querying the DB
- when writing tests, read `neon/Testing 101.md` first
- `translate`: use if you are updating `translation.json` files

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

## References

- "treehouse" refers to https://github.com/kunchenguid/treehouse
