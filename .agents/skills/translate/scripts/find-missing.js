// Usage: node find-missing.js <workspace>
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

// Splits CSV content into rows, respecting quoted fields that contain newlines.
// Preserves raw content (including "" escape sequences) so parseCSVCols can process them correctly.
function parseCSVRows(content) {
  const rows = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < content.length; i++) {
    const ch = content[i];
    if (ch === '"') {
      if (inQuotes && content[i + 1] === '"') { current += '""'; i++; } // preserve raw "" escape
      else { inQuotes = !inQuotes; current += ch; }
    } else if (ch === '\n' && !inQuotes) {
      if (current.trim()) rows.push(current);
      current = '';
    } else {
      current += ch;
    }
  }
  if (current.trim()) rows.push(current);
  return rows;
}

// Parses a single CSV row into columns, handling quoted fields and escaped quotes.
function parseCSVCols(line) {
  const cols = [];
  let i = 0;
  while (i < line.length) {
    if (line[i] === '"') {
      let val = '';
      i++;
      while (i < line.length) {
        if (line[i] === '"' && line[i + 1] === '"') { val += '"'; i += 2; }
        else if (line[i] === '"') { i++; break; }
        else { val += line[i++]; }
      }
      cols.push(val);
      if (line[i] === ',') i++;
    } else {
      const end = line.indexOf(',', i);
      if (end === -1) { cols.push(line.slice(i)); break; }
      cols.push(line.slice(i, end));
      i = end + 1;
    }
  }
  // If the line ends with a comma, the trailing empty field was not captured by the loop.
  if (line.endsWith(',')) cols.push('');
  return cols;
}

const localesDir = findLocalesDir(resolveBasePath(workspace));
const tmpPath = path.join(localesDir, '__translations_tmp.csv');
const missingPath = path.join(localesDir, '__translations_missing.csv');

const raw = fs.readFileSync(tmpPath, 'utf8');
const rows = parseCSVRows(raw);

// Validate column counts — malformed quotes cause csv-to-translations to fail silently.
const headerCols = parseCSVCols(rows[0]);
const headerCount = headerCols.length;
const malformed = [];
for (let i = 1; i < rows.length; i++) {
  const count = parseCSVCols(rows[i]).length;
  if (count !== headerCount) {
    malformed.push({ line: i + 1, key: parseCSVCols(rows[i])[0] ?? '(unknown)', count });
  }
}
if (malformed.length > 0) {
  console.error(`\nERROR: ${malformed.length} row(s) in __translations_tmp.csv have the wrong number of columns (expected ${headerCount}):`);
  for (const { line, key, count } of malformed) {
    console.error(`  Line ${line}: "${key}" — ${count} columns`);
  }
  console.error('\nFix: wrap values containing commas or quotes in double quotes, and escape internal quotes by doubling them ("").');
  process.exit(1);
}
const header = rows[0];
const filtered = rows.slice(1).filter(line => {
  const cols = parseCSVCols(line);
  const hasKey = cols[0]?.trim();
  const hasEn = cols[1]?.trim();
  const othersFilled = cols.slice(2).some(c => c?.trim());
  return hasKey && hasEn && !othersFilled;
});

fs.writeFileSync(missingPath, [header, ...filtered].join('\n'));
console.log(`Found ${filtered.length} rows with missing translations.`);
filtered.forEach(line => {
  const key = parseCSVCols(line)[0];
  if (key) console.log(`  - ${key}`);
});
