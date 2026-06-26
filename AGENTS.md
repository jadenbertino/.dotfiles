- If I reference a git diff then i assume i mean from `main`
- when inspecting outputs from files (tests, lint, typecheck, etc), the output into a temp file, then grep the temp file. do not use exit codes as a metric for success; read the file.

## Writing tests

If you are writing tests, use the `/tdd` skill.

## Tools

- prefer `check` over `tsc-fast`; prefer `tsc-fast` over `tsc`. Only use `tsc` if you need a comprehensive typecheck. Neither `check` nor `tsc-fast` are yarn scripts; they are directly in my bin
- If you don't know the schema, grep `apps/server/prisma/schema.prisma`
- `ls` is aliased to `eza`
- `graphify`: when exploring the code, use graphify skill first to point yourself in the right direction before searching, reading, or grepping files

## Database

- You can use `psql service=<name>` — available services: `local`, `prod-read`

## neon

- "arrakis" is the codename for `apps/neon-dash`
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
- always use curly braces with if statements
- Local DB uses a scaffold, see `apps/server/scripts/seed/constants.ts`

### apps/server

- avoid service methods that are thin wrappers around repos; call a repo method directly instead
