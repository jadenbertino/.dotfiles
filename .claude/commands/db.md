# IMPORTANT

- If the user asks you anything about payments, purchases, checkouts, or other live data, then use --service=prod-read.
- You can read the database schema either by grepping the prisma schema at `apps/server/prisma/schema.prisma` or querying the database directly with `psql`
- Always scope queries with a WHERE clause (email, ID, etc.) to avoid full table scans.

# Database Schema

- `Maker` is a game developer, a `Property` is a game by that developer, and an `Environment` is an environment-scoped (via `isSandbox` field) instance of that game. Most of the game-related config is done at the `Environment` level.
- `Property` has a `makerId` column — you can chain Payment → Environment → Property → Maker in a single join path.
- `Environment` has an `environmentPaymentMethodAvailabilityId` FK to `EnvironmentPaymentMethodAvailability`, which has boolean flags for every payment method (e.g. `isAlipayEnabled`, `isWeChatPayEnabled`). Use this to check what's enabled for a given environment.
- When querying `Environment` records, always include the environment `id` plus `prop."displayName"` and `m."displayName"` (maker) for context.

## Common Tables

### `Maker`
Game developer. Key columns: `id`, `displayName`.

### `Property`
A game. Key columns: `id`, `displayName`, `makerId` (FK → `Maker`).

### `Environment`
An environment-scoped instance of a game. Key columns: `id`, `displayName`, `isSandbox`, `propertyId` (FK → `Property`), `makerId` (FK → `Maker`), `environmentPaymentMethodAvailabilityId` (FK → `EnvironmentPaymentMethodAvailability`).

### `EnvironmentPaymentMethodAvailability`
Boolean flags controlling which payment methods are enabled for an environment (e.g. `isAlipayEnabled`, `isWeChatPayEnabled`, `isPayPalEnabled`). Joined via `env."environmentPaymentMethodAvailabilityId"`.

### `Customer`
A player. Key columns: `id`, `email`.

### `Checkout`
A checkout session. Key columns: `id`, `customerId` (FK → `Customer`), `environmentId` (FK → `Environment`).

### `Payment`
An attempt to charge a customer. Key columns: `id`, `method` (payment method e.g. `alipay`, `card`), `playerUserAgent` (raw UA string). A payment does not mean success.

**Detecting desktop vs mobile via `playerUserAgent`:**
- Desktop: `ILIKE '%windows nt%' OR ILIKE '%macintosh%' OR ILIKE '%x11%'`
- Mobile: `ILIKE '%android%' OR ILIKE '%iphone%' OR ILIKE '%mobile%'`
- Note: `X11` can appear on Android (HeyTap/WebView UAs) — treat with caution. `playerUserAgent` also exists on `Checkout`.

### `Purchase`
A read-only record created only after a payment succeeds. Key columns: `id`, `shortId`, `createdAt`, `status`, `totalAmount`, `currency`, `paymentId` (FK → `Payment`), `checkoutId` (FK → `Checkout`), `environmentId` (FK → `Environment`).

# Example Queries

## Lookup `Purchase` by email

```sql
SELECT p.id, p."shortId", p."createdAt", p.status, p."totalAmount", p.currency,
         pay.method, prop."displayName" AS property
  FROM "Purchase" p
  JOIN "Checkout" c ON c.id = p."checkoutId"
  JOIN "Customer" cu ON cu.id = c."customerId"
  LEFT JOIN "Payment" pay ON pay.id = p."paymentId"
  LEFT JOIN "Environment" env ON env.id = p."environmentId"
  LEFT JOIN "Property" prop ON prop.id = env."propertyId"
  WHERE cu.email = 'email@example.com'
  ORDER BY p."createdAt" DESC;
```
