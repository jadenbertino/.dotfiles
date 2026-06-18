// Usage: node merge-translations.js <workspace>
// workspace: "storefront" → apps/storefront, "@neon/foo" → packages/foo
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = '/workspaces/neon';
const workspace = process.argv[2];
if (!workspace) { console.error('Usage: node merge-translations.js <workspace>'); process.exit(1); }

function resolveBasePath(ws) {
  return ws.startsWith('@neon/')
    ? path.join(ROOT, 'packages', ws.slice('@neon/'.length))
    : path.join(ROOT, 'apps', ws);
}

function findLocalesDir(basePath) {
  const result = execSync(`find "${basePath}" -name "__translations_tmp.csv" -maxdepth 6 2>/dev/null`, { encoding: 'utf8' }).trim();
  if (result) return path.dirname(result);
  throw new Error(`__translations_tmp.csv not found under ${basePath}`);
}

const localesDir = findLocalesDir(resolveBasePath(workspace));
const tmpPath = path.join(localesDir, '__translations_tmp.csv');
const missingPath = path.join(localesDir, '__translations_missing.csv');

const missing = fs.readFileSync(missingPath, 'utf8');
const translatedMap = {};
for (const line of missing.split('\n').filter(l => l.trim()).slice(1)) {
  const key = line.match(/^([^,]+),/)?.[1];
  if (key) translatedMap[key] = line;
}

const updated = fs.readFileSync(tmpPath, 'utf8').split('\n').map(line => {
  const key = line.match(/^([^,]+),/)?.[1];
  return (key && translatedMap[key]) ? translatedMap[key] : line;
});

fs.writeFileSync(tmpPath, updated.join('\n'));
console.log('Merged keys:', Object.keys(translatedMap).join(', '));
