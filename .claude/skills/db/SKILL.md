---
name: db
description: Database access and schema conventions for the Neon monorepo. Use when querying the database, inspecting the schema, or working with seed data.
---

# db

- Connect with `psql service=<name>` — available services: `local`, `prod-read`
- To inspect the schema, prefer `psql` (faster) or grep `apps/server/prisma/schema.prisma`
- Local DB uses a scaffold — see `apps/server/scripts/seed/constants.ts`
