---
name: db
description: Database access and schema conventions for the Neon monorepo. Use when querying the database, inspecting the schema, or working with seed data.
---

# db

- Connect with `psql service=<name>` — available services: `local`, `prod-read`
- To inspect the schema, prefer `psql` (faster) or grep `apps/server/prisma/schema.prisma`
- Connect to Snowflake with the JS SDK when the CLI is noisy or unavailable.
  - Prefer the existing keypair auth shape used in `packages/sales-outreach/src/services/webshop/snowflake.ts`.
  - Typical options are `account`, `username`, `authenticator: "SNOWFLAKE_JWT"`, `privateKeyPath`, `warehouse`, plus `database`, `schema`, and `role` as needed.
  - Use `connect()`/`connectAsync()` and `execute({ sqlText, complete })`; wrap them in promises for modern async/await flow.
  - For long-running reads, page with a deterministic `ORDER BY` and keep a logical checkpoint value; avoid `OFFSET` for restartable jobs.
  - If you need to inspect schema or table shape, use `SHOW SCHEMAS`, `SHOW TABLES`, and `DESCRIBE TABLE` through the SDK.
- Local DB uses a scaffold — fixed IDs are in `apps/server/scripts/seed/constants.ts`:

  | Prefix | Maker ID | Environment ID | Storefront ID | Purpose |
  |---|---|---|---|---|
  | `SEED_` | `aaaaaaaa-7d85-…` | `eeeeeeee-7d85-…` | `e59cf7ad-…` | Main localhost storefront (localhost:3002) |
  | `SEED_COST_PLUS_` | `bbbbbbbb-7d85-…` | `ffffffff-7d85-…` | `f69cf7ad-…` | Cost+ variant |
  | `SEED_STOREFRONT_V2_` | `cccccccc-7d85-…` | `dddddddd-7d85-…` | `d69cf7ad-…` | V2 block-composition (blocks.localhost) |
- Schema is at `packages/database/prisma/schema.prisma`

## Pricing sheets & currency key files

| File | Purpose |
|---|---|
| `packages/i18n/src/markets.ts` | `MARKET_DATA` — per-country currency, `canTakePayments`, `classifyCountry` |
| `packages/currency/src/currency.ts` | Currency definitions: `createTwoDecimalCurrency` vs `createZeroDecimalCurrency` (KRW, JPY, ISK, CLP are zero-decimal) |
| `packages/currency/src/money.ts` | `Money` class — `toNeonInteger()`, `toMinorUnitInt()`, `fromNeonInteger()`, `fromMinorUnitInt()` |
| `apps/server/src/services/loyalty/points.ts` | `DEFAULT_CURRENCY_TO_POINTS_CONVERSION` — source of truth for loyalty conversion amounts |
| `apps/server/src/repos/loyalty/index.ts` | Reads loyalty `amount` from DB via `fromMinorUnitInt()` |
| `apps/server/src/apis/storefront-app-api/http.ts` | Serializes loyalty `amount` to client via `toNeonInteger()` |
| `apps/server/src/services/storefront-app/index.ts` | `getStorefrontPricingCountryWithDefault` — falls back to US for `canTakePayments: false` countries |
| `apps/server/src/services/pricing/pricing-sheet.ts` | Resolves price for a country from a CSV sheet |
| `apps/server/src/scaffold/maker.ts` | Per-property scaffold config including `customPricingSheets` |
| `apps/server/src/services/pricing/data/tests/2024-06-12-price-tiers-TR-default.csv` | TR custom pricing sheet (used by eeeeeeee seed environment) |

### Key rules
- **DB loyalty `amount`** stored as `toMinorUnitInt()`. For 2-decimal currencies (USD, UZS) this equals `toNeonInteger()`; for zero-decimal (KRW, JPY) it's the raw integer (100× smaller than neon).
- **Wire format** from storefront API is always neon integer (`toNeonInteger()`). Storefront component receives and uses neon integer.
- **TR custom pricing CSV**: if a country column is missing, throws `INVALID_ITEM_PRICE_ERROR` immediately — no fallback to base `PRICE_DATA`.
- **`canTakePayments: false`** countries (e.g. UZ) are classified `unsupported` and always fall back to US pricing — their CSV column is never read.

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

**Checkout tokens (`ct_`)** — the `ct_abc...` string in checkout URLs is stored plaintext on `Checkout.token`. Resolve to checkout/purchase/storefront UUIDs:
```sql
SELECT c.id AS checkout_id, p.id AS purchase_id, s.id AS storefront_id
FROM "Checkout" c
JOIN "Purchase" p ON p."checkoutId" = c.id
JOIN "Storefront" s ON s."environmentId" = c."environmentId"
WHERE c.token = 'ct_...';
```
Note: `CheckoutBearerToken` and `CheckoutSessionToken` are separate tables — don't confuse them with `Checkout.token`:

- **`CheckoutBearerToken`** — server-to-server auth for the checkout-app-api. Scoped to a `Checkout` only (no player/user). Token stored as a SHA-256 hash. Passed via `Authorization: Bearer <token>` header. Currently only required for specific makers (e.g. Krafton). Lets an external maker server authenticate its API calls to Neon's checkout endpoints.

- **`CheckoutSessionToken`** — short-lived (5 min) player identity token. Scoped to `Checkout` + `Player` + `User`. Has a `usageCount` field (consumed on use). Created when `skipInviteFlow` is on and a matching Neon player already exists for the maker user. Bridges from maker-side auth into a Neon player checkout session.

**Construct a local success page URL** — the storefront `/success` page needs `purchaseId`, `purchaseToken`, and `storefrontToken` as query params. After resolving the UUIDs above, mint the JWTs with node:
```js
import('/workspaces/neon/apps/server/src/config.ts').then(({ config }) => {
  import('jsonwebtoken').then(({ default: jwt }) => {
    const secret = config.jwt_secret_key;
    const purchaseToken = jwt.sign(
      { data: { purchaseId: PURCHASE_ID, checkoutId: CHECKOUT_ID, createdAt: new Date().toISOString() } },
      secret, { expiresIn: '7d' }
    );
    const storefrontToken = jwt.sign(
      { data: { storefrontId: STOREFRONT_ID, generatedAt: new Date().toISOString() } },
      secret, { expiresIn: '7d' }
    );
    console.log(`http://localhost:3000/success?purchaseId=${PURCHASE_ID}&purchaseToken=${purchaseToken}&storefrontToken=${storefrontToken}`);
  });
});
```
