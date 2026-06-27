---
name: translate
description: Finds untranslated keys in a workspace's translation CSV (rows where only key and en are filled), generates translations for all language columns, and writes them back. Use when adding new translation keys, filling missing translations, or running the translations workflow for an app.
---

# translate

Spawn **one subagent** to run the full translation workflow. The subagent handles everything including verification — do not spawn additional agents.

## Auto-detect workspace (when none given)

1. Run `git diff main --name-only` and look for changed files under a `locales/` directory.
2. Derive workspace from path: `apps/foo/...` → `foo`, `packages/foo/...` → `@neon/foo`.
3. If multiple or zero workspaces match, ask the user.

## Spawn the subagent

```
Agent({
  description: "Translate missing <workspace> keys",
  prompt: `Read the file at /home/node/.claude/skills/translate/PROMPT.md.
Replace every occurrence of {{workspace}} in those instructions with "<workspace>".
This is the Neon monorepo at /workspaces/neon. Follow the instructions exactly.`
})
```

Wait for the agent to finish, then report what keys were translated and whether verification passed.
