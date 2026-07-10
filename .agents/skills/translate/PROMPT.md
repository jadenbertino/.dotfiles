# Translation workflow

You are running the translation workflow for the `{{workspace}}` workspace in the Neon monorepo at `/workspaces/neon`.

**Assumes English keys already exist** — jump straight to Step 1.

## Updating an existing key

If you are **editing** a key that already exists (i.e. the English value changed), you must first purge the stale translations from all other locale files before running the normal workflow. Otherwise the old translated values will persist untouched in other locales.

1. Delete the key from `en/translation.json` only (leave other locale files alone).
2. Run:
   ```bash
   yarn translations-to-csv {{workspace}} && yarn csv-to-translations {{workspace}}
   ```
   This syncs all other locale files to match — removing the now-deleted key everywhere.
3. Add the key back to `en/translation.json` with its new English value.
4. Continue from Step 1 below as normal (the key now appears as missing in the CSV).

## Workspace name formats

- `apps/foo` → pass `foo` (e.g. `storefront`, `server`)
- `packages/foo` → pass `@neon/foo` (e.g. `@neon/database`, `@neon/apis`)

## Step 1 — Export to CSV and find missing rows

```bash
yarn translations-to-csv {{workspace}}
node /home/node/.claude/skills/translate/scripts/find-missing.js {{workspace}}
```

This writes `__translations_missing.csv` (next to `__translations_tmp.csv`) containing only rows where all non-English columns are empty.

## Step 2 — Translate

Read `__translations_missing.csv` and translate it using the rules below.

Fill in all the non-English translation cells in the CSV using the `en` column as the source text.

### Critical Output Rules

- Do not change the header row or the order of rows.
- Do not change the `key` or `en` columns — leave them exactly as-is.
- For every other column, overwrite the value with a new translation based on the `en` text in that row.
- The number and order of columns must be identical to the input.
- If a cell contains a comma, newline, or double quote:
  - wrap the entire value in double quotes `"..."`,
  - and escape any internal quotes by doubling them (`""`).
- Write the final result as valid CSV directly to `__translations_missing.csv` using the Write tool.
- Before writing, validate that every row has the same number of columns as the header. If they don't, fix them first.
- **Comma trap — check your output before writing:** many translations naturally introduce commas that the English source didn't have (e.g. Polish, Russian, German subordinate clauses). Before calling Write, re-read every cell you translated and confirm that any value containing a comma is wrapped in `"..."`. A missing quote silently corrupts that row and every row after it. For example, `Kliknij link, aby aktywować` must be written as `"Kliknij link, aby aktywować"` — not bare.

### Translation Guidelines

- Use informal language matching the tone of the English text.
- For `zh` and `zh-CN`, use simplified Chinese. Those two must be identical.
- For `zh-TW`, use traditional Chinese.
- If a translation includes a period, use the `。` character only for `ja`, `zh`, `zh-CN`, and `zh-TW`. Use normal periods for all other languages.
- Keep anything inside curly braces (`{}`) unchanged.
- Do not translate brand names like "Neon".
- If unsure about a translation, give your best attempt and add a short note explaining what was unclear.
- If there should be additional region-specific overrides that would better represent a translation and don't already exist as columns in the CSV, list them after writing with a description.

## Step 3 — Merge

Write the translated CSV to `__translations_missing.csv`, then merge back:

```bash
node /home/node/.claude/skills/translate/scripts/merge-translations.js {{workspace}}
```

## Step 4 — Write translation files

```bash
yarn csv-to-translations {{workspace}}
```

**IMPORTANT:** Capture the full output and check stderr. This command fails with a CSV parse error if the main `__translations_tmp.csv` has malformed quotes — it does NOT always exit non-zero cleanly. If there is any error output, stop and fix the CSV before proceeding. Do not treat a truncated or partial success message as confirmation that the locale JSON files were written.

## Step 5 — Verify (do this yourself — do NOT spawn a subagent)

1. Run `git diff --name-only | grep 'translation\.json'` and confirm at least one file is modified. If none, stop and report failure — the write step silently failed.
2. Read each modified translation file and adversarially review them: look for missing keys, untranslated values left in English when they shouldn't be, broken interpolation variables (`{{}}`), malformed JSON, and any obviously wrong or machine-garbled translations.
3. Fix any issues found directly in the files.
