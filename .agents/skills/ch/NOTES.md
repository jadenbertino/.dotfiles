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

- Chrome on the Mac can open `localhost:3001` / `localhost:8080` in the codespace directly, but only when the Mac forwards those ports from this codespace. `ch` tunnels only the debug port, so with several codespaces open the ports can point at a different one and every checkout shows "404 Not Found". To check, fetch a made-up path like `localhost:8080/zz-probe` from the page and grep `/tmp/neon-dev.log` for it.
- The card form has two `input[data-testid=emailAddress]` (one belongs to the hidden Neon Pay auth block). Target the visible one with `input#emailAddress`.
- Locally, the card form requires a phone number (e.g. `2015550123`), or Place Order shows "Please enter a valid phone number".
- Clicking `[data-testid=wallet-balance-toggle]` right after the page loads may not register. Check the wallet state in a screenshot before relying on it.

## GitHub

- `gh` can't upload images. To get `user-attachments` URLs for a PR description, open the PR in a background tab and call `setInputFiles({ name, mimeType, buffer })` on a `fc-…` file input. Wait for the matching textarea to contain the `<img … src="https://github.com/user-attachments/…">` tag, read it, then reload the page so nothing gets saved. Then put the tags in the body with `gh pr edit --body-file`.
  - The first `input[type=file]` on a PR page belongs to the PR description's hidden edit form (`fc-issue-<id>-body`), not to the new comment box (`fc-new_comment_field`). Either works, as long as you read the textarea with the same id.
  - Passing a buffer works over CDP even though the files live in the codespace, not on the Mac.

## Mac files

- When the user pastes a Mac path (e.g. a CleanShot screenshot under `~/Library/Application Support/CleanShot/media/...`), open it as `file://` + `encodeURI(path)` in a background tab, draw the `<img>` onto a canvas, and write `canvas.toDataURL()` to `tmp/ch/<date>/` in the codespace. Mac Chrome can read local files, while the codespace can't.

## Timeouts

- The user doesn't want to wait on long backstops: wrap scripts in `timeout 20`, not `timeout 60`, and keep page waits to a few seconds.
- Streaming endpoints (e.g. Vercel's `runtime-logs`) never close, so a plain `fetch` + `text()` hangs. Read the body with an `AbortController` that aborts after ~5s.

## Vercel

- `fetch('/api/...', { credentials: 'include' })` from a `vercel.com` tab calls the Vercel API with the user's session (the CLI here is logged out). The neonxyz team ID is `team_3CRSgsRxhrAwHmSnDpGmK637`.
