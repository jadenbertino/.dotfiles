# ch notes

Things learned while driving Chrome with `ch`. Read before starting; append when something surprises you.

## Playwright over CDP

- A script that never calls `browser.close()` keeps node alive forever, so the Bash call hangs until its timeout.
- `page.setViewportSize({ width: 390, height: 844 })` works on a background tab, so you can emulate a phone without bringing Chrome forward.
- A full-page screenshot with a fixed-position modal open only dims the part of the page that was in the viewport. Screenshot the modal element itself (`locator.screenshot()`) instead.
- To reuse a tab across several scripts, reconnect and find it by URL: `browser.contexts().flatMap(c => c.pages()).find(p => p.url().includes(…))`.

## Shell

- `pkill -f <pattern>` kills its own shell when the pattern also appears in that same command line (the Bash call exits with 144). Use `pgrep -af` to find the PID, then `kill <pid>`.

## Neon checkout (localhost:3001)

- Chrome on the Mac can open `localhost:3001` / `localhost:8080` in the codespace directly.
- The card form has two `input[data-testid=emailAddress]` (one belongs to the hidden Neon Pay auth block). Target the visible one with `input#emailAddress`.
- Locally, the card form requires a phone number (e.g. `2015550123`), or Place Order shows "Please enter a valid phone number".
- Clicking `[data-testid=wallet-balance-toggle]` right after the page loads may not register. Check the wallet state in a screenshot before relying on it.
