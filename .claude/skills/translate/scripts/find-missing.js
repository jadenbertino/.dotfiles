// Usage: node find-missing.js <workspace>
// workspace: "storefront" → apps/storefront, "@neon/foo" → packages/foo
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = '/workspaces/neon';
const workspace = process.argv[2];
if (!workspace) { console.error('Usage: node find-missing.js <workspace>'); process.exit(1); }

function resolveBasePath(ws) {
  return ws.startsWith('@neon/')
    ? path.join(ROOT, 'packages', ws.slice('@neon/'.length))
    : path.join(ROOT, 'apps', ws);
}

function findLocalesDir(basePath) {
  const result = execSync(`find "${basePath}" -name "__translations_tmp.csv" -maxdepth 6 2>/dev/null`, { encoding: 'utf8' }).trim();
  if (result) return path.dirname(result);
  throw new Error(`__translations_tmp.csv not found under ${basePath} — did yarn translations-to-csv run?`);
}

const localesDir = findLocalesDir(resolveBasePath(workspace));
const tmpPath = path.join(localesDir, '__translations_tmp.csv');
const missingPath = path.join(localesDir, '__translations_missing.csv');

const content = fs.readFileSync(tmpPath, 'utf8');
const lines = content.split('\n');
const header = lines[0];
const filtered = lines.slice(1).filter(line => {
  if (!line.trim()) return false;
  const cols = line.match(/(?:"[^"]*"|[^,]*)(?:,|$)/g)?.map(c => c.replace(/,$/, '').replace(/^"|"$/g, '')) ?? [];
  const hasKey = cols[0] && cols[0].trim();
  const hasEn = cols[1] && cols[1].trim();
  const othersFilled = cols.slice(2).some(c => c && c.trim());
  return hasKey && hasEn && !othersFilled;
});

fs.writeFileSync(missingPath, [header, ...filtered].join('\n'));
console.log(`Found ${filtered.length} rows with missing translations.`);
filtered.forEach(line => {
  const key = line.match(/^([^,]+),/)?.[1];
  if (key) console.log(`  - ${key}`);
});
