- Prefer small, frequent commits
- Skip typecheck and lint. Allow the pre-commit hook to handle these checks.
- You can view `yarn dev` logs at `/tmp/neon-dev.log`

## Code style

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

## References

- "treehouse" refers to https://github.com/kunchenguid/treehouse
