- If I reference a git diff then i assume i mean from `main`
- when inspecting outputs from files (tests, lint, typecheck, etc), the output into a temp file, then grep the temp file. do not use exit codes as a metric for success; read the file.
- If you are writing tests, use the `/tdd` skill.
- to quickly check & typecheck a file, use `/home/node/.local/bin-dotfiles/check <filepaths>`. For a comprehensive check use `tsc` and `eslint`.
- `ls` is aliased to `eza`
- `graphify`: when exploring the code, use graphify skill first to point yourself in the right direction before searching, reading, or grepping files

## Database

If you are working with the database, use the `/db` skill.

## neon

- "arrakis" is the codename for `apps/neon-dash`
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`
