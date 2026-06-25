---
name: translate
description: Finds untranslated keys in a workspace's translation CSV (rows where only key and en are filled), generates translations for all language columns, and writes them back. Use when adding new translation keys, filling missing translations, or running the translations workflow for an app.
---

# translate

Fills in missing translations for a workspace. **Assumes English keys already exist** — jump straight to Step 1, do not ask the user to create them.

## Workspace

**Name formats:**
- `apps/foo` → pass `foo` (e.g. `storefront`, `server`)
- `packages/foo` → pass `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)

**Auto-detection (when no workspace is given):**
1. Run `git diff main --name-only` and look for changed files under a `locales/` directory
2. Derive workspace from path:
   - `apps/foo/...` → `foo`
   - `packages/foo/...` → `@neon/foo`
3. If multiple or zero workspaces match, ask the user

## Workflow

### Step 1 — Export to CSV and find missing rows

```bash
yarn translations-to-csv <workspace>
node /home/node/.claude/skills/translate/scripts/find-missing.js <workspace>
```

This writes `__translations_missing.csv` (next to `__translations_tmp.csv`) containing only rows where all non-English columns are empty.

### Step 2 — Translate

Read `__translations_missing.csv` and translate it using the rules below.

Fill in all the non-English translation cells in the CSV using the `en` column as the source text.

#### Critical Output Rules
- Do not change the header row or the order of rows.
- Do not change the `key` or `en` columns — leave them exactly as-is.
- For every other column, overwrite the value with a new translation based on the `en` text in that row.
- The number and order of columns must be identical to the input.
- If a cell contains a comma, newline, or double quote:
  - wrap the entire value in double quotes `"..."`,
  - and escape any internal quotes by doubling them (`""`).
- Write the final result as valid CSV directly to `__translations_missing.csv` using the Write tool.
- Before writing, validate that every row has the same number of columns as the header. If they don't, fix them first.

#### Translation Guidelines
- Use informal language matching the tone of the English text.
- For `zh` and `zh-CN`, use simplified Chinese. Those two must be identical.
- For `zh-TW`, use traditional Chinese.
- If a translation includes a period, use the `。` character only for `ja`, `zh`, `zh-CN`, and `zh-TW`. Use normal periods for all other languages.
- Keep anything inside curly braces (`{}`) unchanged.
- Do not translate brand names like "Neon".
- If unsure about a translation, give your best attempt and add a short note explaining what was unclear.
- If there should be additional region-specific overrides that would better represent a translation and don't already exist as columns in the CSV, list them after writing with a description.

### Step 3 — Merge

Write the translated CSV to `__translations_missing.csv`, then merge back:

```bash
node /home/node/.claude/skills/translate/scripts/merge-translations.js <workspace>
```

### Step 4 — Write translation files

```bash
yarn csv-to-translations <workspace>
```

**IMPORTANT:** Capture the full output and check stderr. This command fails with a CSV parse error if the main `__translations_tmp.csv` has malformed quotes — it does NOT always exit non-zero cleanly. If there is any error output, stop and fix the CSV before proceeding. Do not treat a truncated or partial success message as confirmation that the locale JSON files were written.

### Step 5 — Verify (spawn a separate agent)

Spawn a subagent with the following instructions:

1. Run `git diff --name-only | grep 'translation\.json'` and confirm at least one file is modified. If none, stop and report failure — the write step silently failed.
2. Read each modified translation file and adversarially review them: look for missing keys, untranslated values left in English when they shouldn't be, broken interpolation variables (`{{}}`), malformed JSON, and any obviously wrong or machine-garbled translations.
3. Fix any issues found directly in the files.

## Delegation

**Always spawn a subagent to run this entire skill.** The translation workflow is self-contained and should not block the main context. Use `Agent({ description: "Translate missing storefront keys", prompt: "Run the translate skill for the storefront workspace..." })` and wait for it to complete before reporting done.
