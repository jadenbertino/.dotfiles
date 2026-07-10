- NEVER use the memory system; persist information to this file or a skill instead.
- when inspecting outputs from files (tests, lint, typecheck, etc), the output into a temp file, then grep the temp file. do not use exit codes as a metric for success; read the file.
- to quickly check & typecheck a file, use `/home/node/.local/bin-dotfiles/check <filepaths>`. For a comprehensive check use `tsc` and `eslint`.
- `ls` is aliased to `eza`

## Code Style

- when creating enums use const object enum
- Prefer switch over ternary when branching on a union/enum type — a ternary has a catch-all else that silently handles any value not in the if condition, including future values added to the union. A switch forces each variant to be an explicit case, so new union members are caught at compile time. When possible, wrap the switch in an immediately-invoked function expression ((() => { switch... })()) rather than using a let that gets reassigned in each branch.
- when trying to iterate through a union type, create a const object enum, then derive an array from it to ensure it's exhaustive

## git

- Always commit after making changes to any files in my `~/.dotfiles` repo
- If I reference a git diff then i assume i mean from `main`
- Don't include yourself as a commit author.

## Skills

- `db`: use when understanding DB schema, updating it, or querying the DB
- when writing tests, read `neon/Testing Overview.md` first

## Datadog

- When asked to investigate a Datadog URL, run `ddl -h` first, then use `ddl logs url "<url>"` to fetch the logs.

## neon

- "arrakis" is the codename for `apps/neon-dash`
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`
