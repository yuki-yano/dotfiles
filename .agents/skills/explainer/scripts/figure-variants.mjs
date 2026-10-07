#!/usr/bin/env node
// 同じ図を、配置だけ変えて何通りか描き、機械の検査の点数つきで 1 枚に並べる。目で見比べて選ぶためのもの。
//
//   node figure-variants.mjs <fig.d2 | fig.mmd> [--seeds 1-6] [--directions down,right] [--out dir]
//
// 候補
//   D2       TALA の seed（既定 1〜6）・ELK・dagre。--directions を付けると、向きも変えて掛け合わせる
//   Mermaid  向き（既定 TD と LR）× 線の曲げ方（basis と linear）
// 各候補を figure-check.mjs に通し（--json）、減点（✗ を重みづけしたもの）、矢印の点数、△ の数で並べる。小さいほど良い。
// 出力
//   <out>/<name>.variants.png   候補の描画を点数つきで並べた 1 枚 → Read で開いて見比べる
//   標準出力                    候補ごとの点数と、選んだ候補をソースに書く方法
// 機械の点数は「明らかに悪いもの」を落とすためのもの。残った候補から選ぶのは、目で見てから。
import { spawn } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const here = dirname(fileURLToPath(import.meta.url));
const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: { seeds: { type: 'string', default: '1-6' }, directions: { type: 'string' }, out: { type: 'string' } },
});
const src = resolve(positionals[0] ?? '');
const kind = extname(src).slice(1);
if (!existsSync(src) || !['d2', 'mmd'].includes(kind)) { console.error('usage: figure-variants.mjs <fig.d2|fig.mmd> [--seeds 1-6] [--directions down,right]'); process.exit(2); }
const name = basename(src).replace(/\.(d2|mmd)$/, '');
const out = resolve(opt.out ?? join(dirname(src), '.figure-check', name, 'variants'));
mkdirSync(out, { recursive: true });
const source = readFileSync(src, 'utf8');
const root = (() => { for (let d = dirname(src); d !== dirname(d); d = dirname(d)) if (existsSync(join(d, 'package.json'))) return d; return process.cwd(); })();
const facts = join(dirname(src), `${name}.facts.json`);

// ---- 候補を作る ----
const candidates = [];
if (kind === 'd2') {
  // 配置を決める行（エンジン・d2-flags・トップレベルの direction）を外した本体
  const body = source.split('\n').filter((l) => !/^\s*layout-engine:/.test(l) && !/^#\s*d2-flags:/.test(l)).join('\n');
  const dirs = opt.directions ? opt.directions.split(',') : [null];
  const [s0, s1] = opt.seeds.split('-').map(Number);
  const withDir = (b, d) => (d ? `direction: ${d}\n${b.replace(/^direction:\s*\w+\s*$/m, '')}` : b);
  for (const d of dirs) {
    const tag = d ? ` / direction: ${d}` : '';
    for (let s = s0; s <= (s1 ?? s0); s++)
      candidates.push({ label: `TALA seed ${s}${tag}`, text: `# d2-flags: --tala-seeds=${s}\n${withDir(body, d)}`, apply: `ファイルに「# d2-flags: --tala-seeds=${s}」の行を書き、layout-engine の指定を消す${d ? `。direction: ${d}` : ''}` });
    for (const e of ['elk', 'dagre'])
      candidates.push({ label: `${e.toUpperCase()}${tag}`, text: `vars: {d2-config: {layout-engine: ${e}}}\n${withDir(body, d)}`, apply: `ファイルの先頭に vars: { d2-config: { layout-engine: ${e} } } を書く${d ? `。direction: ${d}` : ''}` });
  }
} else {
  const dirs = opt.directions ? opt.directions.split(',') : ['TD', 'LR'];
  const header = /^(\s*(?:flowchart|graph))\s+(TD|TB|BT|LR|RL)\b/m;
  if (!header.test(source)) { console.error('only flowchart / graph can be varied'); process.exit(2); }
  const body = source.replace(/^%%\{init:.*\}%%\s*$/m, '');
  for (const d of dirs)
    for (const curve of ['basis', 'linear'])
      candidates.push({
        label: `${d} / curve ${curve}`,
        text: `%%{init: {"flowchart": {"curve": "${curve}"}}}%%\n${body.replace(header, `$1 ${d}`)}`,
        apply: `先頭を「flowchart ${d}」にする${curve === 'basis' ? '' : `。1 行目に %%{init: {"flowchart": {"curve": "${curve}"}}}%% を書く`}`,
      });
}

// ✗ を重みで 1 つの数にする。ライトとスマホで同じ問題は 1 回と数える。
// 文字が潰れる・重なる・線が箱を突き抜ける・2 本が重なる は重く、線が文字の上を通るは中くらい
function penalty(fail) {
  const seen = new Map();
  for (const m of fail) {
    const k = m.replace(/^(light|dark|mobile): /, '').replace(/\d+(\.\d+)?px/g, '').slice(0, 60);
    let w = 1;
    if (/under 9px/.test(m)) w = Math.min(...[...m.matchAll(/(\d+(?:\.\d+)?)px/g)].map((x) => +x[1])) < 6 ? 5 : 2;
    else if (/text overlap|outside the figure|^arrows: .*(重なって走る|の中を通る)/.test(m)) w = 3;
    else if (/line runs through|cross a box edge/.test(m)) w = 2;
    seen.set(k, Math.max(seen.get(k) ?? 0, w));
  }
  return [...seen.values()].reduce((a, b) => a + b, 0);
}

// ---- 各候補を figure-check に通す（4 つずつ並行） ----
const run = (c, i) => new Promise((done) => {
  const f = join(out, `v${i}.${kind}`);
  writeFileSync(f, c.text);
  if (existsSync(facts)) copyFileSync(facts, join(out, `v${i}.facts.json`));
  const json = join(out, `v${i}.json`);
  const p = spawn('node', [join(here, 'figure-check.mjs'), f, '--write', '--json', json, '--out', join(out, `v${i}`)], { cwd: root, env: { ...process.env, NO_COLOR: '1' } });
  let stdout = '';
  p.stdout.on('data', (d) => { stdout += d; });
  p.on('close', () => {
    // 描けなかった候補（d2 のエラーなど）は、最後に回す
    if (!existsSync(json)) return done({ ...c, i, fail: [stdout.match(/✗ (.*)/)?.[1] ?? 'figure-check failed'], look: [], score: 99, penalty: 99 });
    const s = JSON.parse(readFileSync(json, 'utf8'));
    const fail = s.fail.filter((m) => !/^no fact sheet|is stale or missing/.test(m));
    done({ ...c, i, fail, look: s.look, score: s.arrowScore ?? 99, penalty: penalty(fail), light: s.light });
  });
});
const results = [];
for (let k = 0; k < candidates.length; k += 4) results.push(...(await Promise.all(candidates.slice(k, k + 4).map((c, j) => run(c, k + j)))));
results.sort((a, b) => a.penalty - b.penalty || a.score - b.score || a.look.length - b.look.length);

// ---- 並べた 1 枚 ----
const { chromium } = createRequire(join(root, 'package.json'))('playwright');
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1400, height: 800 }, deviceScaleFactor: 1 });
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
await page.setContent(`<body style="margin:0;padding:12px;background:#888;font:13px system-ui,'Noto Sans JP';display:flex;flex-wrap:wrap;gap:10px;align-items:flex-start">
${results.map((r, n) => `<div style="background:#fff;padding:6px;width:330px"><div style="font-weight:600">#${n + 1} ${esc(r.label)}</div>
<div>減点 ${r.penalty}（✗ ${r.fail.length}） · 矢印 ${r.score} · △ ${r.look.length}</div>
${r.fail.slice(0, 2).map((m) => `<div style="color:#b3261e">✗ ${esc(m.slice(0, 70))}</div>`).join('')}
${r.light && existsSync(r.light) ? `<img src="data:image/png;base64,${readFileSync(r.light).toString('base64')}" style="width:330px;display:block;margin-top:4px">` : '<div>（描けなかった）</div>'}</div>`).join('')}</body>`);
const sheet = join(out, `${name}.variants.png`);
await page.screenshot({ path: sheet, fullPage: true });
await browser.close();

console.log(`variants of ${basename(src)}（減点 → 矢印の点数 → △ の数 の順。小さいほど良い）`);
for (const [n, r] of results.entries()) console.log(`  #${n + 1} ${r.label.padEnd(26)} 減点 ${String(r.penalty).padStart(2)}  矢印 ${String(r.score).padStart(2)}  △ ${r.look.length}${r.fail.length ? `   ${r.fail[0].slice(0, 60)}` : ''}`);
console.log(`\n  look at them: ${sheet}`);
console.log(`  選んだら：${results[0].apply}（#1 を選ぶ場合）。選んだ理由をソースのコメントに 1 行残す`);
if (results[0].penalty > 0)
  console.log(`  どの候補にも ✗ が残った。配置の選び直しでは直らない。図の構造（箱の分け方・向き・ラベルの長さ）を変える${kind === 'mmd' ? '。Mermaid で足りないなら D2（TALA）に移す' : ''}`);
