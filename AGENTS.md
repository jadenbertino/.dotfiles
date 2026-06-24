- If I reference a git diff then i assume i mean from `main`
- For browser automation, use the `/browser` skill.
- when running tests, lint, or typecheck, redirect the output into a temp file, then grep the temp file

## Writing tests

- Create default fixture constants with reasonable minimal values; individual tests spread the default and override only the fields relevant to what they're asserting
- Prefer inline spreads over helper functions: `{ ...defaultFoo, override: value }` not `makeFoo({ override: value })`
- Defaults should be the minimal/null case — tests that need complex values opt in explicitly
- Add `satisfies` to default fixtures so TypeScript catches drift between the fixture shape and the actual type: `const defaultFoo = { ... } satisfies FooType`
- Export input/output types from services when callers need to reference them (e.g. for `satisfies` in tests). Types that describe a service's public contract are fine to export; internal implementation types are not.
- When an assertion contains a non-obvious value, add an inline comment explaining why that value is expected: `expect(result.discountAmount).toEqual(m.usd(4)); // 20% off $20`. If the same value appears in multiple assertions (or in both an input and an assertion), extract it as a named constant and put the comment there instead: `const maximumAmount = m.usd(5); // uncapped would be $20`.

## Tools

- prefer `check` over `tsc-fast`; prefer `tsc-fast` over `tsc`. Only use `tsc` if you need a comprehensive typecheck. Neither `check` nor `tsc-fast` are yarn scripts; they are directly in my bin
- If you don't know the schema, grep `apps/server/prisma/schema.prisma`
- `ls` is aliased to `eza`

## Database

- You can use `psql service=<name>` — available services: `local`, `prod-read`
- Local DB uses a scaffold, see `apps/server/scripts/seed/constants.ts`

## neon

- "arrakis" is the codename for `apps/neon-dash`
- You can read the dev server logs at `/tmp/neon-dev.log`
- If I reference a `neon/**/*.md` file then assume this filepath is relative to `/workspaces/neon/_obsidian`
- workspace name formats depend on folder:
  - `apps/foo` → `foo` (e.g. `storefront`, `server`)
  - `packages/foo` → `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)
