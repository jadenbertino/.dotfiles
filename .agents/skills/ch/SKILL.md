---
name: ch
description: Drive the user's Mac Chrome from the codespace over CDP, opening tabs in the background so Chrome never steals focus. Use when the user says "use playwright" or asks you to open, click through, or screenshot something in their browser.
---

# ch

- `ch` (`~/.local/bin-dotfiles/ch`) runs on my Mac and tunnels my Chrome's debug port into the codespace at `http://localhost:9222`
  - if `curl -s localhost:9222/json/version` fails, ask me to run `ch` on my Mac
- connect with `chromium.connectOverCDP("http://localhost:9222")` rather than launching a new browser
  - if it fails with "Browser context management is not supported", Chrome is probably stuck on its "choose a profile" screen: ask me to pick a profile (or restart `ch`, which passes `--profile-directory`) rather than switching to raw CDP
  - `playwright-core` is installed in `/workspaces/neon/node_modules`
- I want to watch, so avoid headless browsers: don't fall back to one without asking me first
- open tabs in the background so Chrome doesn't steal focus from whatever app I'm in
  - `newPage()`, `/json/new`, `Target.activateTarget` and `page.bringToFront()` all bring Chrome to the front, so don't use them
  - instead, create the tab over CDP and let Playwright pick it up as a normal page:
    ```js
    const cdp = await browser.newBrowserCDPSession();
    const pageP = browser.contexts()[0].waitForEvent("page");
    await cdp.send("Target.createTarget", { url, background: true });
    const page = await pageP;
    ```
  - `goto`, clicks, `fill` and screenshots all work in a background tab without bringing Chrome forward
  - tell me the tab's title when you open it, so I can switch to it if I want to watch
