#!/usr/bin/env node
// 解説ドキュメントの「主張」を道具で検査する。
//
//   node verify-doc.mjs <doc-dir> [--pages README.md,01-x.md,…] [--write] [--skip-html]
//
// 1. checks   <doc-dir>/checks.json のコマンドを再実行し、expect の各行が stdout に順に現れるか
// 2. figures  図（*.svg / *.fig.html / *.d2 / *.mmd）を figure-check.mjs に通す。*.facts.json があれば照合し、
//             --write で .d2 / .mmd から描いた SVG を上書きする
// 3. prose    各ページ (既定は README.md) の <!-- output: name --> 直後のコードブロックが、その check の実出力にあるか
//             <!-- source: path --> 直後のコードブロックが、そのファイルの一部と一致するか
//             画像リンクとページ間リンク (*.md) の参照先が存在するか
// 3b. 日本語  yomiyasu（入っていれば）の yomiyasu_lint.py で本文を点検し、見直す候補を △ で出す（落とさない）
// 4. page     HTML に組み、各ページに vlmkit check integrity / check a11y contrast を通す (--skip-html で省略)
//
// どれか 1 つでも落ちれば exit 1。落ちた項目ごとに「何が・どこで・どう直すか」を 1 行で出す。
import { spawnSync } from 'node:child_process';
import { existsSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    write: { type: 'boolean', default: false },
    'skip-html': { type: 'boolean', default: false },
    pages: { type: 'string', default: 'README.md' },
  },
});
const docDir = resolve(positionals[0] ?? '.');
const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = findUp(docDir, 'package.json') ?? process.cwd();
const bin = (name) => join(repoRoot, 'node_modules', '.bin', name);
const TMP = mkdtempSync(join(tmpdir(), 'explainer-verify-'));
const env = { ...process.env, NO_COLOR: '1', FORCE_COLOR: '0', TMP, TLA2TOOLS: join(repoRoot, '.tools/tla2tools.jar'),
  APALACHE: join(repoRoot, '.tools/apalache/bin/apalache-mc') };

let failures = 0;
const ok = (msg) => console.log(`  ✓ ${msg}`);
const ng = (msg, fix) => { failures++; console.log(`  ✗ ${msg}${fix ? `\n    → ${fix}` : ''}`); };

function findUp(dir, file) {
  for (let d = dir; d !== dirname(d); d = dirname(d)) if (existsSync(join(d, file))) return d;
  return null;
}
function sh(cmd, cwd) {
  const r = spawnSync('sh', ['-c', cmd], { cwd, env, encoding: 'utf8', maxBuffer: 64 << 20 });
  const strip = (x) => (x ?? '').replace(/\x1b\[[0-9;]*m/g, '');
  return { code: r.status, out: strip(r.stdout) + strip(r.stderr) };
}
// needles が haystack の行に「順に」部分一致するか。最初に見つからなかった行を返す
function missingInOrder(haystack, needles) {
  const lines = haystack.split('\n');
  let i = 0;
  for (const n of needles) {
    while (i < lines.length && !lines[i].includes(n)) i++;
    if (i === lines.length) return n;
    i++;
  }
  return null;
}

// ---- 1. checks ---------------------------------------------------------------
console.log('checks (checks.json を再実行)');
const outputs = new Map();
const checksFile = join(docDir, 'checks.json');
if (existsSync(checksFile)) {
  for (const c of JSON.parse(readFileSync(checksFile, 'utf8')).checks) {
    const { out } = sh(c.cmd, join(docDir, c.cwd ?? '.'));
    outputs.set(c.name, out);
    if (c.save) writeFileSync(c.save.replace('$TMP', TMP), out);
    const miss = missingInOrder(out, c.expect ?? []);
    if (miss === null) ok(c.name);
    else ng(`${c.name}: expected line not found: ${JSON.stringify(miss)}`,
      `run \`${c.cmd}\` in ${c.cwd ?? '.'} and compare; if the tool's answer changed, the prose that quotes it is now wrong too\n    output tail: ${out.trim().split('\n').slice(-3).join(' | ')}`);
  }
} else console.log('  (no checks.json)');

// ---- 2. figures（SVG / HTML / D2 / Mermaid） ---------------------------------------------
// figure-check.mjs に通す。目で見るシートもここで作られる
const figDir = join(docDir, 'figures');
const all = existsSync(figDir) ? readdirSync(figDir) : [];
const handMade = all.filter((f) =>
  f.endsWith('.d2') || f.endsWith('.mmd') || f.endsWith('.vl.json') || f.endsWith('.fig.html') ||
  (f.endsWith('.svg') && !['.d2', '.mmd', '.vl.json'].some((x) => all.includes(f.replace(/\.svg$/, x)))));
if (handMade.length) console.log('figures (figure-check)');
for (const f of handMade) {
  const r = sh(`node ${join(here, 'figure-check.mjs')} ${join(figDir, f)}${opt.write ? ' --write' : ''}`);
  const fails = r.out.split('\n').filter((l) => l.trim().startsWith('✗'));
  const looks = r.out.split('\n').filter((l) => l.trim().startsWith('△')).length;
  r.code === 0 ? ok(`${f}: CLEAN${looks ? `, △ ${looks}（辺のシートで目で見る）` : ''} (sheet: figures/.figure-check/${f.replace(/\.fig\.html$|\.svg$|\.d2$|\.mmd$|\.vl\.json$/, '')}/)`) : ng(`${f}: ${fails.length} problem(s): ${fails.map((l) => l.trim().slice(2)).slice(0, 2).join(' / ')}`, `node ${join(here, 'figure-check.mjs')} ${join(figDir, f)} — then look at the sheet`);
}

// ---- 3. prose ----------------------------------------------------------------
console.log('prose (本文の引用が実物と一致するか)');
const pages = opt.pages.split(',').map((x) => x.trim()).filter(Boolean);
for (const page of pages) {
  const md = readFileSync(join(docDir, page), 'utf8');
  const lineOf = (idx) => md.slice(0, idx).split('\n').length;
  for (const m of md.matchAll(/<!--\s*(output|source):\s*([^\s]+)\s*-->\s*\n```[^\n]*\n([\s\S]*?)\n```/g)) {
    const [, kind, ref, body] = m;
    const at = `${page}:${lineOf(m.index)}`;
    if (kind === 'output') {
      const out = outputs.get(ref);
      if (out === undefined) { ng(`${at}: output block names unknown check "${ref}"`, 'add it to checks.json'); continue; }
      const lines = body.split('\n').filter((x) => x.trim() && !x.trim().startsWith('...'));
      const miss = missingInOrder(out, lines);
      miss === null ? ok(`${at}: output of ${ref}`) : ng(`${at}: quoted output not produced by ${ref}: ${JSON.stringify(miss)}`, 'paste the real output, do not retype it');
    } else {
      const file = join(docDir, ref);
      if (!existsSync(file)) { ng(`${at}: source ${ref} does not exist`); continue; }
      const src = readFileSync(file, 'utf8').replace(/\s+$/gm, '');
      src.includes(body.replace(/\s+$/gm, ''))
        ? ok(`${at}: excerpt of ${ref}`)
        : ng(`${at}: excerpt differs from ${ref}`, 'the file changed or the excerpt was edited by hand; copy it again');
    }
  }
  for (const m of md.matchAll(/!\[[^\]]*\]\(([^)\s]+)\)/g))
    existsSync(join(docDir, m[1])) ? ok(`${page}: image ${m[1]}`) : ng(`${page}: image ${m[1]} is missing`);
  for (const m of md.matchAll(/\]\(([\w.-]+\.md)(?:#[^)]*)?\)/g))
    if (!existsSync(join(docDir, m[1]))) ng(`${page}: link to ${m[1]}, which does not exist`);
}

// ---- 3b. 日本語の読みやすさ（yomiyasu）------------------------------------------
// yomiyasu のリンターは、AI の文章に出やすい型（太字・箇条書きの多さ、文末のコロン、比喩の動詞など）を数える。
// 人の文章でも点数が出るので、落とさずに △ で知らせるだけにする。場所は $YOMIYASU_LINT か、スキルの置き場所から探す
function findYomiyasu() {
  if (process.env.YOMIYASU_LINT) return existsSync(process.env.YOMIYASU_LINT) ? process.env.YOMIYASU_LINT : null;
  const rel = 'yomiyasu/scripts/yomiyasu_lint.py';
  const bases = [join(process.cwd(), '.claude/skills'), join(process.cwd(), '.agents/skills'), join(homedir(), '.claude/skills'), join(homedir(), '.agents/skills')];
  for (const b of bases) if (existsSync(join(b, rel))) return join(b, rel);
  // プラグインとして入れた場合：~/.claude/plugins の下を浅く探す
  const walk = (d, depth) => {
    if (depth < 0 || !existsSync(d)) return null;
    for (const e of readdirSync(d, { withFileTypes: true })) {
      if (!e.isDirectory()) continue;
      const p = join(d, e.name);
      if (existsSync(join(p, rel))) return join(p, rel);
      const found = walk(p, depth - 1);
      if (found) return found;
    }
    return null;
  };
  return walk(join(homedir(), '.claude/plugins'), 5);
}
const yomiyasu = findYomiyasu();
console.log('japanese (yomiyasu)');
if (!yomiyasu) console.log('  - yomiyasu not installed; skipped (npx skills add nanaism/yomiyasu)');
else for (const page of pages) {
  const r = spawnSync('python3', ['-I', yomiyasu, '--json', join(docDir, page)], { encoding: 'utf8' });
  let d;
  try { d = JSON.parse(r.stdout); } catch { console.log(`  - ${page}: yomiyasu_lint failed: ${(r.stderr || '').trim().split('\n').at(-1)}`); continue; }
  const m = d.metrics ?? {};
  const head = `${page}: score ${d.score}（太字 1,000 字あたり ${m.bold_per_1000}、箇条書き ${Math.round((m.list_ratio ?? 0) * 100)}%）`;
  if (!d.findings?.length) { ok(head); continue; }
  console.log(`  △ ${head}、見直す候補 ${d.findings.length} 件（references/writing.md の「読みやすい日本語」）`);
  for (const f of d.findings.slice(0, 5)) console.log(`      L${f.line} ${f.rule}: ${(f.snippet ?? '').slice(0, 50)}`);
}

// ---- 4. page -----------------------------------------------------------------
if (!opt['skip-html']) {
  console.log('page (vlmkit)');
  const b = sh(`node ${join(here, 'build-html.mjs')} ${pages.map((x) => join(docDir, x)).join(' ')}`);
  if (b.code !== 0) ng('build-html failed', b.out.trim().split('\n').at(-1));
  else for (const page of pages) {
    const html = join(docDir, 'dist', page === 'README.md' ? 'index.html' : page.replace(/\.md$/, '.html'));
    // 閉じた <details> の答えは、非表示でも箱の寸法が残り container-protrusion と測られる。
    // そこで「全部開いた版」を厳格に検査し、閉じた版はその 1 種だけ理由付きで除外する。
    // 図がページの中で壊れていないか：Markdown の変換で <pre> にされたり、タグがエスケープされたりしていないか
    const built = readFileSync(html, 'utf8');
    const broken = [...built.matchAll(/<figure\b[\s\S]*?<\/figure>/g)]
      .map((m) => m[0])
      .filter((f) => /<pre\b/.test(f) || /&lt;\/?(svg|g|text|path|rect|div|style)\b/.test(f));
    broken.length
      ? ng(`${page}: ${broken.length} figure(s) broken in the built page (turned into <pre> or escaped markup)`, 'the figure markup went through Markdown; see build-html.mjs placeholders')
      : ok(`${page}: ${built.match(/<figure\b/g)?.length ?? 0} figure(s) intact in the built page`);
    const openHtml = html.replace(/\.html$/, '.open.html');
    writeFileSync(openHtml, readFileSync(html, 'utf8').replace(/<details>/g, '<details open>'));
    const allowClosed = `--allow "container-protrusion@details;closed <details> keeps its hidden answer's box — checked expanded in the .open.html copy"`;
    for (const [gate, page, extra] of [
      ['check integrity', openHtml, ''],
      ['check integrity', html, allowClosed],
      ['check a11y contrast', html, ''],
    ]) {
      const r = sh(`${bin('vlmkit')} ${gate} file://${page} ${extra}`);
      const verdict = r.out.match(/verdict:.*$/m)?.[0] ?? r.out.trim().split('\n').at(-1);
      const label = `${gate} (${page.split('/').pop()})`;
      r.code === 0 ? ok(`${label}: ${verdict}`) : ng(`${label}: ${verdict}`, r.out.split('\n').filter((x) => x.includes('[')).slice(0, 5).join(' / '));
    }
  }
}

console.log(failures === 0 ? '\nverdict: VERIFIED' : `\nverdict: ${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);
