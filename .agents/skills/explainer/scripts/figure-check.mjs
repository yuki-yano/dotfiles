#!/usr/bin/env node
// 手で書いた概念図（SVG / HTML / D2）を描画し、機械で検査し、目で見るための画像を作る。
//
//   node figure-check.mjs <fig.svg | fig.fig.html | fig.d2 | fig.mmd> [--facts f.facts.json] [--write] [--out dir]
//
// 1. D2 は d2 で SVG にする（既定は TALA。ファイルの vars.d2-config.layout-engine があればそれ）。
//    ほかのフラグは、ファイルの `# d2-flags: --tala-seeds=5` の行から渡す。
//    Mermaid（.mmd）は、プロジェクトの mermaid をブラウザで動かして SVG にする。--write のとき <name>.svg を隣に書く
// 2. ブラウザで描画し、3 つの見え方を 1 枚にまとめた <out>/<name>.sheet.png を作る
//      ライト 760px ・ ダーク 760px ・ スマホ 375px
//    → このシートを Read で開き、目で確かめる（文字の重なり・線が文字を横切る・意味の取り違えは、機械では拾いきれない）
// 3. 機械の検査（落ちたら ✗）
//      overlap   文字と文字が重なっている
//      clipped   文字が図の外にはみ出している
//      crossing  文字が箱の枠線をまたいでいる（SVG の rect、HTML の枠線）
//      through   線（矢印・接続線）が文字の中を通っている
//      tiny      スマホ幅で文字の高さが 9px 未満になる
//      facts     事実シートの labels がすべて図にあり、forbidden が図に無い。D2 / Mermaid なら edges がソースの中にある
//      vlmkit    図だけのページに check integrity と check a11y contrast を通す
//      arrows    D2 / Mermaid（と data-edge を付けた SVG）の矢印の読みやすさ（figure-arrows.mjs）
//                  ✗ shared   2 本の辺が長く重なって走る   ✗ through  辺が端点でない箱の中を通る
//                  △ cross    交差   △ detour  遠回り   △ against  流れと逆向き（△ は落とさないが、辺のシートで目で見る）
//                辺を 1 本ずつ赤くした <out>/<name>.edges.png も作る。これも Read で開いて、各矢印が「どこからどこへ」と読めるか確かめる
//    HTML の図は --write のとき、Markdown から参照するための <name>.fig.png も書く
//
// 事実シート <name>.facts.json：{ "labels": ["…"], "forbidden": ["…"], "edges": ["a->b"] }
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { arrowScore, collectArrows, edgeSheet, flowDirection, judgeArrows } from './figure-arrows.mjs';

const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: { facts: { type: 'string' }, write: { type: 'boolean', default: false }, out: { type: 'string' }, json: { type: 'string' } },
});
const src = resolve(positionals[0] ?? '');
if (!existsSync(src)) { console.error('usage: figure-check.mjs <fig.svg|fig.fig.html|fig.d2|fig.mmd|fig.vl.json> [--facts f.json] [--write]'); process.exit(2); }

const dir = dirname(src);
const kind = src.endsWith('.fig.html') ? 'html' : src.endsWith('.vl.json') ? 'vl' : extname(src).slice(1);
const name = basename(src).replace(/\.fig\.html$|\.svg$|\.d2$|\.mmd$|\.vl\.json$/, '');
const out = resolve(opt.out ?? join(dir, '.figure-check', name));
mkdirSync(out, { recursive: true });
// 道具（.tools/d2、node_modules）は、図の近く、実行したディレクトリの近く、このスクリプトの近くの順に、
// playwright を持つ package.json を探す（図の横に別の package.json があっても、そこに playwright が無ければ次へ）
const here = dirname(fileURLToPath(import.meta.url));
const hasPlaywright = (d) => { try { createRequire(join(d, 'package.json')).resolve('playwright'); return true; } catch { return false; } };
const root = [dir, process.cwd(), here].map((d) => findUp(d, 'package.json')).find((d) => d && hasPlaywright(d))
  ?? findUp(dir, 'package.json') ?? process.cwd();
const projectRequire = createRequire(join(root, 'package.json'));
const { chromium } = projectRequire('playwright');

let failures = 0;
const ok = (m) => console.log(`  ✓ ${m}`);
const summary = { fail: [], look: [], arrowScore: null, sheet: null, edges: null };
const ng = (m, fix) => { failures++; summary.fail.push(m); console.log(`  ✗ ${m}${fix ? `\n    → ${fix}` : ''}`); };
const look = (m) => { summary.look.push(m); console.log(`  △ ${m}`); };
// Mermaid の flowchart の辺を「a->b」の形で取り出す。a[ラベル] --> b --> c は 2 本。|ラベル| と -- ラベル --> は読み飛ばす
function mermaidEdges(source) {
  const edges = [];
  const arrow = /\s*(?:<?-->|<?==>|<?-\.->|---|===|-\.-)(?:\|[^|]*\|)?\s*/;
  for (const raw of source.split('\n')) {
    const line = raw.replace(/%%.*$/, '').replace(/--\s[^->]+?\s-->/g, '-->').trim();
    const parts = line.split(arrow);
    if (parts.length < 2) continue;
    const ids = parts.map((x) => x.match(/^([\w-]+)/)?.[1]);
    if (ids.some((x) => !x)) continue;
    for (let i = 0; i + 1 < ids.length; i++) edges.push(`${ids[i]}->${ids[i + 1]}`);
  }
  return edges;
}
// D2 の辺を「a.b->c」の形で取り出す。箱の { } の中の辺は箱の名前を前に付け、a -> b -> c は 2 本に分ける
function d2Edges(source) {
  const scope = [], edges = [];
  for (const raw of source.split('\n')) {
    const line = raw.replace(/^\s*#.*$/, '').trim();
    if (!line || line.startsWith('(')) continue;
    const open = line.match(/^([\w.-]+)\s*(?::[^{]*)?\{$/);
    if (open) { scope.push(open[1]); continue; }
    if (line === '}') { scope.pop(); continue; }
    const body = line.replace(/:\s[^>]*$|:\s*\{.*$/, '');
    const parts = body.split(/\s*(<->|->|<-|--)\s*/);
    if (parts.length < 3) continue;
    const at = (id) => [...scope, id.trim()].join('.');
    for (let i = 0; i + 2 < parts.length; i += 2) {
      const [a, op, b] = [at(parts[i]), parts[i + 1], at(parts[i + 2])];
      edges.push(op === '<-' ? `${b}->${a}` : `${a}->${b}`);
    }
  }
  return edges;
}
function findUp(d, f) { for (; d !== dirname(d); d = dirname(d)) if (existsSync(join(d, f))) return d; return null; }
const sh = (cmd, args) => spawnSync(cmd, args, { encoding: 'utf8' });

console.log(`figure ${basename(src)} (${kind})`);

// ---- 1. 図の本体（HTML の断片）を作る ----------------------------------------------
let figureHtml, d2Source = null, mmdSource = null, vlSpec = null;
if (kind === 'd2') {
  const d2 = [join(root, '.tools/d2'), 'd2'].find((p) => sh(p, ['--version']).status === 0);
  if (!d2) { ng('d2 is not installed', 'put the d2 binary at .tools/d2 or on PATH'); process.exit(1); }
  d2Source = readFileSync(src, 'utf8');
  const v = sh(d2, ['validate', src]);
  if (v.status !== 0) { ng(`d2 validate: ${(v.stderr || v.stdout).trim().split('\n')[0]}`); process.exit(1); }
  const f = sh(d2, ['fmt', '--check', src]);
  f.status === 0 ? ok('d2 fmt --check') : ng('d2 is not formatted', `run: ${d2} fmt ${src}`);
  const svgOut = join(out, `${name}.svg`);
  // 既定は TALA。ファイルが vars.d2-config.layout-engine を持っていれば、それに従う
  const engine = d2Source.match(/layout-engine:\s*(\w+)/)?.[1];
  // ファイルの中に書けない d2 のフラグは、`# d2-flags: --tala-seeds=5` の行で渡す
  // （d2 v0.9.0 は vars.d2-config.tala-seeds を受け付けない）
  const flags = d2Source.match(/^#\s*d2-flags:\s*(.+)$/m)?.[1].trim().split(/\s+/) ?? [];
  const r = sh(d2, [...(engine ? [] : ['--layout=tala']), '--pad=16', ...flags, src, svgOut]);
  ok(`layout: ${engine ?? 'tala (default)'}${flags.length ? ` ${flags.join(' ')}` : ''}`);
  if (r.status !== 0) { ng(`d2 render failed: ${(r.stderr || '').trim().split('\n').at(-1)}`); process.exit(1); }
  const svg = readFileSync(svgOut, 'utf8');
  if (opt.write) { writeFileSync(join(dir, `${name}.svg`), svg); ok(`wrote ${name}.svg`); }
  else if (!existsSync(join(dir, `${name}.svg`)) || readFileSync(join(dir, `${name}.svg`), 'utf8') !== svg)
    ng(`${name}.svg is stale or missing`, 're-run with --write after editing the .d2');
  else ok(`${name}.svg matches the .d2`);
  figureHtml = svg.replace(/<\?xml[^>]*>/, '');
} else if (kind === 'mmd') {
  let mermaidJs;
  try { mermaidJs = join(dirname(projectRequire.resolve('mermaid/package.json')), 'dist/mermaid.min.js'); }
  catch { ng('mermaid is not installed in this project', 'npm i -D mermaid'); process.exit(1); }
  mmdSource = readFileSync(src, 'utf8');
  const b = await chromium.launch();
  const p = await b.newPage();
  await p.setContent('<body></body>');
  await p.addScriptTag({ path: mermaidJs });
  // 文字は SVG の <text> で描かせる（foreignObject の HTML だと、ここの文字の検査が届かない）。id は固定し、毎回同じ SVG にする
  // アイコン：プロジェクトに入っている Iconify のセット（lucide・logos）を登録する。図からは A@{ icon: "lucide:database" } で使う
  const packs = ['lucide', 'logos'].flatMap((n) => { try { return [{ name: n, icons: projectRequire(`@iconify-json/${n}/icons.json`) }]; } catch { return []; } });
  if (packs.length) await p.evaluate((ps) => mermaid.registerIconPacks(ps.map((x) => ({ name: x.name, icons: x.icons }))), packs);
  // id は図の名前から作る。1 ページに複数の Mermaid の図を置いても、SVG の中の CSS（#id …）がぶつからない
  const r = await p.evaluate(async ([s, id]) => {
    mermaid.initialize({ startOnLoad: false, htmlLabels: false, flowchart: { htmlLabels: false }, deterministicIds: true });
    try { return { svg: (await mermaid.render(id, s)).svg }; } catch (e) { return { error: String(e.message ?? e).split('\n')[0] }; }
  }, [mmdSource, `mmd-${name.replace(/[^\w-]/g, '-')}`]);
  await b.close();
  if (r.error) { ng(`mermaid: ${r.error}`); process.exit(1); }
  ok('mermaid: rendered');
  if (opt.write) { writeFileSync(join(dir, `${name}.svg`), r.svg); ok(`wrote ${name}.svg`); }
  else if (!existsSync(join(dir, `${name}.svg`)) || readFileSync(join(dir, `${name}.svg`), 'utf8') !== r.svg)
    ng(`${name}.svg is stale or missing`, 're-run with --write after editing the .mmd');
  else ok(`${name}.svg matches the .mmd`);
  figureHtml = r.svg;
} else if (kind === 'vl') {
  // Vega-Lite の spec（データの図）。vega で SVG にする。ブラウザは要らず、文字は <text> のまま残る
  let vega, vl;
  try { vega = await import(pathToFileURL(projectRequire.resolve('vega')).href); vl = await import(pathToFileURL(projectRequire.resolve('vega-lite')).href); }
  catch { ng('vega / vega-lite is not installed in this project', 'npm i -D vega vega-lite'); process.exit(1); }
  vlSpec = JSON.parse(readFileSync(src, 'utf8'));
  let svg;
  try {
    const view = new vega.View(vega.parse(vl.compile(vlSpec).spec), { renderer: 'none' });
    svg = await view.toSVG();
    view.finalize();
  } catch (e) { ng(`vega-lite: ${String(e.message ?? e).split('\n')[0]}`); process.exit(1); }
  ok('vega-lite: rendered');
  if (opt.write) { writeFileSync(join(dir, `${name}.svg`), svg); ok(`wrote ${name}.svg`); }
  else if (!existsSync(join(dir, `${name}.svg`)) || readFileSync(join(dir, `${name}.svg`), 'utf8') !== svg)
    ng(`${name}.svg is stale or missing`, 're-run with --write after editing the .vl.json');
  else ok(`${name}.svg matches the .vl.json`);
  figureHtml = svg;
} else if (kind === 'svg') {
  figureHtml = readFileSync(src, 'utf8').replace(/<\?xml[^>]*>/, '');
} else if (kind === 'html') {
  figureHtml = readFileSync(src, 'utf8');
} else { ng(`unsupported file type: ${kind}`); process.exit(2); }

// 図だけのページ。ライト / ダークの配色は、資料の HTML（build-html.mjs）と同じトークン
const page = (scheme) => `<!doctype html><html lang="ja" data-theme="${scheme}"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><title>${name}</title>
<style>
:root { --bg:#ffffff; --fg:#1f2328; --muted:#57606a; --line:#d0d7de; --code:#f6f8fa; --accent:#0550ae; --fig:#ffffff; }
:root[data-theme="dark"] { --bg:#0d1117; --fg:#e6edf3; --muted:#9da7b3; --line:#30363d; --code:#161b22; --accent:#79c0ff; --fig:#ffffff; }
* { box-sizing: border-box; }
body { margin:0; padding:16px; background:var(--bg); color:var(--fg); font:16px/1.6 system-ui,-apple-system,"Hiragino Sans","Noto Sans JP",sans-serif; }
#figure { max-width:760px; margin:0 auto; }
#figure > svg { display:block; max-width:100%; height:auto; margin:0 auto; background:var(--fig); border-radius:6px; }
</style></head><body><figure id="figure" role="img" aria-label="${name}">${figureHtml}</figure></body></html>`;

// ---- 2. 描画と検査 -------------------------------------------------------------------
const browser = await chromium.launch();
const variants = [
  { key: 'light', scheme: 'light', width: 792 },
  { key: 'dark', scheme: 'dark', width: 792 },
  { key: 'mobile', scheme: 'light', width: 375 },
];
const shots = {};
const geometry = {};
let arrows = null, arrowResult = null, edgesPng = null, tofu = [];
for (const v of variants) {
  const p = await browser.newPage({ viewport: { width: v.width, height: 900 }, colorScheme: v.scheme, deviceScaleFactor: 2 });
  await p.setContent(page(v.scheme), { waitUntil: 'networkidle' });
  const fig = await p.$('#figure');
  const png = join(out, `${name}.${v.key}.png`);
  await fig.screenshot({ path: png });
  shots[v.key] = png;
  // 矢印：ライトの見え方で 1 回だけ測り、1 本ずつ強調した画像も撮る
  if (v.key === 'light' && ['d2', 'mmd', 'svg'].includes(kind)) {
    arrows = await p.evaluate(collectArrows);
    if (arrows.edges.length) {
      arrowResult = judgeArrows(arrows, flowDirection(d2Source ?? mmdSource ?? '', kind));
      const flagged = [...new Set([...arrowResult.fail, ...arrowResult.look.filter((x) => x.kind !== 'cross')].flatMap((x) => x.edges))];
      edgesPng = join(out, `${name}.edges.png`);
      await edgeSheet(p, browser, arrows, flagged, edgesPng);
    }
  }
  if (v.key === 'light') tofu = await p.evaluate(() => {
    const c = document.createElement('canvas'); c.width = 64; c.height = 64;
    const g = c.getContext('2d', { willReadFrequently: true });
    const draw = (ch, font) => { g.clearRect(0, 0, 64, 64); g.font = font; g.fillText(ch, 4, 48); return g.getImageData(0, 0, 64, 64).data.join(','); };
    const found = [], seen = new Set();
    const figure = document.querySelector('#figure');
    for (const el of figure.querySelectorAll('text, tspan, *')) {
      const own = [...el.childNodes].filter((n) => n.nodeType === 3).map((n) => n.textContent).join('');
      if (!own.trim()) continue;
      const cs = getComputedStyle(el);
      const font = `40px ${cs.fontFamily}`;
      const none = draw('\u{10FFFF}', font);
      for (const ch of own) {
        const cp = ch.codePointAt(0);
        if (cp < 0x80 || /\s/.test(ch) || seen.has(ch + font)) continue;
        seen.add(ch + font);
        if (draw(ch, font) === none) found.push({ ch, cp: cp.toString(16).toUpperCase().padStart(4, '0'), text: own.trim().slice(0, 30) });
      }
    }
    return found;
  });
  // 文字の箱：SVG なら text 要素、HTML なら直下に文字を持つ要素
  geometry[v.key] = await p.evaluate(() => {
    const figure = document.querySelector('#figure');
    const fr = figure.getBoundingClientRect();
    const els = [...figure.querySelectorAll('text')];
    for (const el of figure.querySelectorAll('*')) {
      if (el.closest('svg')) continue;
      if ([...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) els.push(el);
    }
    const boxes = els.map((el) => {
      // 文字そのものの範囲（HTML はブロックの幅ではなく、文字の行の幅）
      let r = el.getBoundingClientRect();
      if (!el.closest('svg')) {
        const range = document.createRange();
        range.selectNodeContents(el);
        const rs = [...range.getClientRects()];
        if (rs.length) r = rs.reduce((a, b) => ({ left: Math.min(a.left, b.left), top: Math.min(a.top, b.top), right: Math.max(a.right, b.right), bottom: Math.max(a.bottom, b.bottom) }));
      }
      // Mermaid の辺のラベル（.edgeLabel）は、背景の箱ごと線の上に置く作りなので、線が通っても隠れる
      return { el, onLine: !!el.closest('.edgeLabel'), text: el.textContent.trim().replace(/\s+/g, ' ').slice(0, 40), left: r.left, top: r.top, right: r.right, bottom: r.bottom, h: (r.bottom - r.top) };
    }).filter((b) => b.text && b.right > b.left);
    // 入れ子（親と子、text と tspan）は重なりとして数えない：祖先の番号を持たせる
    boxes.forEach((b, i) => { b.i = i; });
    for (const b of boxes) b.anc = boxes.filter((o) => o !== b && o.el.contains(b.el)).map((o) => o.i);
    for (const b of boxes) delete b.el;
    // 枠線のある箱（SVG の rect と、HTML の枠線のある要素）の 4 辺
    const edges = [];
    for (const el of figure.querySelectorAll('rect, *')) {
      const cs = getComputedStyle(el);
      const inSvg = el.tagName.toLowerCase() === 'rect';
      const stroked = inSvg ? (el.getAttribute('stroke') || cs.stroke) && (el.getAttribute('stroke') || cs.stroke) !== 'none' : parseFloat(cs.borderTopWidth) > 0 && cs.borderTopStyle !== 'none';
      if (!stroked || (!inSvg && el.closest('svg'))) continue;
      const r = el.getBoundingClientRect();
      if (r.width < 4 || r.height < 4) continue;
      edges.push({ box: el.id || el.getAttribute('class') || el.tagName, l: r.left, t: r.top, r: r.right, b: r.bottom });
    }
    // 線（塗りの無い line / polyline / path）を点列にする。D2 の矢印もここに入る
    const strokes = [];
    for (const el of figure.querySelectorAll('svg line, svg polyline, svg path')) {
      const cs = getComputedStyle(el);
      if (el.closest('marker, defs, clipPath, mask')) continue;
      const filled = cs.fill && cs.fill !== 'none' && !/rgba\(\s*0,\s*0,\s*0,\s*0\s*\)/.test(cs.fill) && el.tagName !== 'line';
      if (filled || !cs.stroke || cs.stroke === 'none') continue;
      const len = el.getTotalLength?.() ?? 0;
      const m = el.getScreenCTM();
      if (!len || !m) continue;
      // マスクで切り抜かれた部分（D2 は辺のラベルの下の線をこうして消す）は描かれないので数えない
      const holes = [];
      const masked = el.closest('[mask]');
      const maskEl = masked && document.querySelector(masked.getAttribute('mask').replace(/^url\(["']?|["']?\)$/g, ''));
      if (maskEl) {
        const mm = masked.getScreenCTM();
        for (const hr of maskEl.querySelectorAll('rect')) {
          if (!/^(black|#000|#000000)$/i.test(hr.getAttribute('fill') ?? '')) continue;
          const x = +hr.getAttribute('x'), y = +hr.getAttribute('y'), w = +hr.getAttribute('width'), h = +hr.getAttribute('height');
          const tl = { x: mm.a * x + mm.c * y + mm.e, y: mm.b * x + mm.d * y + mm.f };
          const br = { x: mm.a * (x + w) + mm.c * (y + h) + mm.e, y: mm.b * (x + w) + mm.d * (y + h) + mm.f };
          holes.push({ l: Math.min(tl.x, br.x), t: Math.min(tl.y, br.y), r: Math.max(tl.x, br.x), b: Math.max(tl.y, br.y) });
        }
      }
      const pts = [];
      for (let d = 0; d <= len; d += 2) {
        const p = el.getPointAtLength(d);
        const q = { x: m.a * p.x + m.c * p.y + m.e, y: m.b * p.x + m.d * p.y + m.f };
        if (!holes.some((h) => q.x >= h.l && q.x <= h.r && q.y >= h.t && q.y <= h.b)) pts.push(q);
      }
      strokes.push({ id: el.id || el.getAttribute('class') || el.tagName, pts });
    }
    return { frame: { left: fr.left, top: fr.top, right: fr.right, bottom: fr.bottom }, boxes, edges, strokes, text: figure.textContent.replace(/\s+/g, ' ') };
  });
  await p.close();
}

// 3 つを 1 枚に並べたシート
const sheet = await browser.newPage({ viewport: { width: 1400, height: 800 }, deviceScaleFactor: 1 });
const img = (k) => `data:image/png;base64,${readFileSync(shots[k]).toString('base64')}`;
await sheet.setContent(`<body style="margin:0;padding:12px;background:#888;font:14px system-ui;display:flex;gap:12px;align-items:flex-start">
${['light', 'dark', 'mobile'].map((k) => `<div style="background:#fff;padding:6px"><div>${k}</div><img src="${img(k)}" style="width:${k === 'mobile' ? 300 : 520}px;display:block"></div>`).join('')}</body>`);
const sheetPng = join(out, `${name}.sheet.png`);
await sheet.screenshot({ path: sheetPng, fullPage: true });
await browser.close();

if (kind === 'html' && opt.write) { writeFileSync(join(dir, `${name}.fig.png`), readFileSync(shots.light)); ok(`wrote ${name}.fig.png (for Markdown)`); }

// ---- 3. 機械の検査 -------------------------------------------------------------------
// 文字が文字のまま描かれているか。matplotlib の SVG は既定で文字を輪郭（path）にするので、下の文字の検査がすべて素通りする
const textCount = (figureHtml.match(/<text\b/g) ?? []).length;
const glyphUses = (figureHtml.match(/<use\b/g) ?? []).length + (figureHtml.match(/<path\b[^>]*\bid="[^"]*(?:-[0-9a-f]{2,}|glyph)[^"]*"/gi) ?? []).length;
if (['svg', 'html'].includes(kind) && textCount === 0 && glyphUses >= 5)
  ng(`text is drawn as outlines (${glyphUses} glyph shapes, 0 <text>); the text checks below cannot read it`,
    'matplotlib: plt.rcParams["svg.fonttype"] = "none" before savefig. Or draw the chart as a Vega-Lite spec (.vl.json)');
// 字形の無い文字（豆腐）：その文字を、図と同じフォントで描いた画素が、どのフォントにも無い文字（U+10FFFF）と同じなら豆腐
if (tofu.length) ng(`${tofu.length} character(s) have no glyph in any installed font (drawn as tofu): ${tofu.slice(0, 5).map((c) => `"${c.ch}" U+${c.cp} in "${c.text}"`).join(', ')}`,
  'use a font that has the character, or replace it (e.g. ≤ → 以下)');
else ok('every character has a glyph');
const area = (a) => Math.max(0, a.right - a.left) * Math.max(0, a.bottom - a.top);
const inter = (a, b) => area({ left: Math.max(a.left, b.left), top: Math.max(a.top, b.top), right: Math.min(a.right, b.right), bottom: Math.min(a.bottom, b.bottom) });
for (const key of ['light', 'mobile']) {
  const { boxes, frame } = geometry[key];
  const overlaps = [];
  for (let i = 0; i < boxes.length; i++)
    for (let j = i + 1; j < boxes.length; j++) {
      const a = boxes[i], b = boxes[j];
      // 入れ子（tspan と text、子と親）は数えない
      if (a.anc.includes(b.i) || b.anc.includes(a.i)) continue;
      if (inter(a, b) > 0.15 * Math.min(area(a), area(b))) overlaps.push(`"${a.text}" × "${b.text}"`);
    }
  overlaps.length ? ng(`${key}: ${overlaps.length} text overlap(s): ${overlaps.slice(0, 3).join(', ')}`, 'move one of them, or shorten the label') : ok(`${key}: no text overlaps (${boxes.length} labels)`);
  const clipped = boxes.filter((b) => b.left < frame.left - 1 || b.right > frame.right + 1 || b.top < frame.top - 1 || b.bottom > frame.bottom + 1);
  clipped.length ? ng(`${key}: ${clipped.length} label(s) outside the figure: ${clipped.slice(0, 3).map((b) => `"${b.text}"`).join(', ')}`, 'widen the viewBox / container, or move the label in') : ok(`${key}: all labels inside the figure`);
}
// 文字が箱の枠線をまたいでいないか（線が文字の中を通る）
for (const key of ['light', 'mobile']) {
  const { boxes, edges } = geometry[key];
  const m = 1; // 1px の余裕
  const crossing = [];
  for (const b of boxes)
    for (const e of edges) {
      const vx = [e.l, e.r].some((x) => x > b.left + m && x < b.right - m) && e.b > b.top + m && e.t < b.bottom - m;
      const hy = [e.t, e.b].some((y) => y > b.top + m && y < b.bottom - m) && e.r > b.left + m && e.l < b.right - m;
      if (vx || hy) crossing.push(`"${b.text}"`);
    }
  const uniq = [...new Set(crossing)];
  uniq.length ? ng(`${key}: ${uniq.length} label(s) cross a box edge: ${uniq.slice(0, 3).join(', ')}`, 'move the label fully inside or outside the box') : ok(`${key}: no label crosses a box edge (${edges.length} boxes)`);
}
// 線が文字の中を通っていないか
for (const key of ['light', 'mobile']) {
  const { boxes, strokes } = geometry[key];
  const hit = [];
  for (const b of boxes.filter((x) => !x.onLine))
    for (const st of strokes)
      if (st.pts.some((p) => p.x > b.left + 1 && p.x < b.right - 1 && p.y > b.top + 1 && p.y < b.bottom - 1)) hit.push(`"${b.text}"`);
  const uniq = [...new Set(hit)];
  uniq.length ? ng(`${key}: a line runs through ${uniq.length} label(s): ${uniq.slice(0, 3).join(', ')}`, 'route the line around the label, or move the label') : ok(`${key}: no line runs through a label (${strokes.length} lines)`);
}
// 矢印の読みやすさ
if (arrowResult) {
  for (const x of arrowResult.fail) ng(`arrows: ${x.msg}`, x.kind === 'shared' ? 'D2 なら seed やエンジンを変える（figure-variants.mjs で並べて選ぶ）。箱の並びを変えるか、辺を 1 本にまとめる' : '箱の並びを変える。D2 なら seed やエンジンを変える（figure-variants.mjs）');
  for (const x of arrowResult.look) look(`arrows: ${x.msg}`);
  if (!arrowResult.fail.length) ok(`arrows: ${arrows.edges.length} edge(s), none share a trunk or pass through a box`);
  summary.arrowScore = arrowScore(arrowResult);
} else if (['d2', 'mmd'].includes(kind)) ng('arrows: no edges found in the rendered SVG', 'the D2 / Mermaid output format may have changed; figure-arrows.mjs cannot see the arrows');
// データの図：パネルの題に「何を見る図か — 何が見えれば合格か」があるか（無くても落とさない。目で見る項目）
if (vlSpec) {
  const titles = [];
  const walk = (o) => { if (!o || typeof o !== 'object') return; if (typeof o.title === 'string' && (o.mark || o.layer)) titles.push(o.title); for (const k of ['vconcat', 'hconcat', 'concat', 'layer']) (o[k] ?? []).forEach(walk); };
  walk(vlSpec);
  const bare = titles.filter((t) => !/\s[—–-]\s/.test(t));
  bare.length ? look(`panels without "what to look at — what passes" in the title: ${bare.map((t) => `"${t}"`).join(', ')}`) : titles.length && ok(`${titles.length} panel title(s) say what to look at and what passes`);
}
const tiny = geometry.mobile.boxes.filter((b) => b.h < 9);
tiny.length ? ng(`mobile: ${tiny.length} label(s) render under 9px tall: ${tiny.slice(0, 3).map((b) => `"${b.text}" ${b.h.toFixed(1)}px`).join(', ')}`, 'the figure is too wide for its text; fewer columns, larger font, or a taller layout') : ok('mobile: every label is at least 9px tall');

// アイコン・画像：図の中に埋め込まれているか（外のファイルを指したままだと、資料の HTML に貼ったときに消える）
const hrefs = [...figureHtml.matchAll(/<image\b[^>]*?\s(?:xlink:)?href="([^"]*)"/g)].map((m) => m[1]);
const loose = hrefs.filter((h) => !h.startsWith('data:'));
loose.length ? ng(`icons: ${loose.length} image(s) not embedded: ${loose.slice(0, 3).join(', ')}`, 'the file is missing or unreadable; put it with icons.mjs add, or fix the path (relative to the .d2)') : hrefs.length && ok(`icons: ${hrefs.length} image(s) embedded`);
// D2 のアイコンは、出典とライセンスを figures/icons/ICONS.md に残す（icons.mjs add が書く）
if (d2Source) {
  const used = [...new Set([...d2Source.matchAll(/icon:\s*(\S+?\.svg)/g)].map((m) => m[1]).filter((u) => !/^https?:/.test(u)))];
  if (used.length) {
    const recorded = (u) => { const md = join(dir, dirname(u), 'ICONS.md'); return existsSync(md) && readFileSync(md, 'utf8').includes(`| \`${basename(u)}\``); };
    const missing = used.filter((u) => !recorded(u));
    missing.length ? ng(`icons: no source / license recorded for ${missing.join(', ')}`, 'add icons with icons.mjs add, which records them in ICONS.md next to the icon') : ok(`icons: ${used.length} icon(s) recorded in ICONS.md`);
  }
}

const factsPath = opt.facts ?? join(dir, `${name}.facts.json`);
if (existsSync(factsPath)) {
  const facts = JSON.parse(readFileSync(factsPath, 'utf8'));
  const text = geometry.light.text;
  const norm = (s) => s.replace(/\s+/g, ' ');
  const missing = (facts.labels ?? []).filter((l) => !text.includes(norm(l)));
  missing.length ? ng(`facts: label(s) not in the figure: ${missing.map((l) => `"${l}"`).join(', ')}`) : ok(`facts: ${facts.labels?.length ?? 0} label(s) present`);
  const present = (facts.forbidden ?? []).filter((l) => text.includes(norm(l)));
  present.length ? ng(`facts: forbidden label(s) drawn: ${present.map((l) => `"${l}"`).join(', ')}`) : ok(`facts: ${facts.forbidden?.length ?? 0} forbidden label(s) absent`);
  if (facts.edges) {
    if (!d2Source && !mmdSource) ng('facts: "edges" can only be checked for a .d2 or .mmd figure');
    else {
      const drawn = new Set(d2Source ? d2Edges(d2Source) : mermaidEdges(mmdSource));
      const lack = facts.edges.filter((e) => !drawn.has(e));
      const extra = [...drawn].filter((e) => !facts.edges.includes(e));
      lack.length || extra.length
        ? ng(`facts: edges differ (missing: ${lack.join(', ') || '-'}; not in facts: ${extra.join(', ') || '-'})`)
        : ok(`facts: ${facts.edges.length} edge(s) exactly as in the ${d2Source ? 'D2' : 'Mermaid'}`);
    }
  }
} else ng(`no fact sheet (${basename(factsPath)})`, 'list the labels the figure must show; a figure checked only against itself proves nothing');

// ---- 4. vlmkit のゲート（図だけのページ） ------------------------------------------------
const wrapper = join(out, `${name}.page.html`);
writeFileSync(wrapper, page('light'));
const vlmkit = join(root, 'node_modules/.bin/vlmkit');
if (existsSync(vlmkit)) {
  for (const gate of ['check integrity', 'check a11y contrast']) {
    const r = spawnSync('sh', ['-c', `${vlmkit} ${gate} file://${wrapper}`], { encoding: 'utf8', env: { ...process.env, NO_COLOR: '1' } });
    const outText = (r.stdout + r.stderr).replace(/\x1b\[[0-9;]*m/g, '');
    const verdict = outText.match(/verdict:.*$/m)?.[0] ?? outText.trim().split('\n').at(-1);
    r.status === 0 ? ok(`vlmkit ${gate}: ${verdict}`) : ng(`vlmkit ${gate}: ${verdict}`, outText.split('\n').filter((x) => x.includes('[')).slice(0, 3).join(' / '));
  }
} else console.log('  - vlmkit not installed; skipped');

console.log(`\n  look at it: ${sheetPng}`);
if (edgesPng) console.log(`  look at the arrows: ${edgesPng}（赤い線が 1 本ずつ、どこからどこへ読めるか）`);
summary.sheet = sheetPng; summary.edges = edgesPng; summary.light = shots.light;
if (opt.json) writeFileSync(opt.json, JSON.stringify(summary, null, 2));
console.log(failures === 0 ? 'figure verdict: CLEAN (now look at the sheet)' : `figure verdict: ${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);
