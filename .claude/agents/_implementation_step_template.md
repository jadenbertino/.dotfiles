# \_implementation_step_template.md

# Step N: [Descriptive Name]

## Context

Parent ticket: TICKET-ID ([Brief feature description])
This is step N of M.

## Goal

[Clear, single-sentence description of what this step accomplishes]

## Files

<!-- Example format — replace with actual paths and symbols for this step -->

### Read

- `src/api/transactions.ts`
  - `createTransaction` (function) — error handling pattern to follow
  - `validatePayment` (function) — validation approach to mirror
- `src/components/FilterDropdown.tsx`
  - `FilterDropdown` (component) — component structure
  - `useFilterState` (hook) — hook pattern for filter state
- `src/types/payment.ts`
  - `PaymentStatus` (type) — use for status options
  - `Transaction` (interface) — response shape

### Modify

- `src/api/transactions.ts`
  - add `filterTransactions` (function)
- `src/components/index.ts`
  - add export for new component

### Mirror

- `src/components/DateRangePicker.tsx`
  - `DateRangePicker` (component) — overall structure
  - `useDateRange` (hook) — hook pattern

### Create

- `src/components/TransactionFilter.tsx`
- `src/components/TransactionFilter.test.tsx`

## Implementation Notes

[Any specific guidance, gotchas, edge cases, or decisions already made]

## Checks

- [ ] TypeScript compiles: `pnpm typecheck`
- [ ] Lint passes: `pnpm lint`
- [ ] Tests pass: `pnpm test path/to/relevant.test.ts`
- [ ] [Step-specific checks, e.g. "New endpoint returns 200"]

## References

- Full spec (read if needed): ../0_SPEC.md
- General patterns: CLAUDE.md
