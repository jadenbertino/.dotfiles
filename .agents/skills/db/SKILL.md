---
name: db
description: Database access and schema conventions for the Neon monorepo. Use when querying the database, inspecting the schema, or working with seed data.
---

# db

- Connect with `psql service=<name>` — available services: `local`, `prod-read`
- To inspect the schema, prefer `psql` (faster) or grep `apps/server/prisma/schema.prisma`
- Local DB uses a scaffold — see `apps/server/scripts/seed/constants.ts`
- Schema is at `packages/database/prisma/schema.prisma`

## Common queries

**Environment/storefront details** — id + displayName for environment, property, and maker:
```sql
SELECT
  e.id AS environment_id, e."displayName" AS environment_name,
  p.id AS property_id, p."displayName" AS property_name,
  m.id AS maker_id, m."displayName" AS maker_name
FROM "Environment" e
JOIN "Property" p ON e."propertyId" = p.id
JOIN "Maker" m ON e."makerId" = m.id
WHERE e.id = '<id>';
```
