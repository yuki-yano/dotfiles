#!/usr/bin/env node
// 図に使うアイコン。Iconify の JSON 形式のアイコンセットから探し、図の隣に SVG として置く。
//
//   node icons.mjs search <語> [<語> …] [--sheet out.png]   名前にすべての語を含むアイコンを探す。--sheet で候補を 1 枚に並べる（目で見て選ぶ）
//   node icons.mjs add <set:name> [--dir figures/icons] [--as file] [--color #1f2328]
//                                                              figures/icons/<file>.svg を書き、ICONS.md（出典とライセンス）に記録する
//   node icons.mjs inline <set:name> [--size 24] [--x 0] [--y 0] [--color #1f2328]
//                                                              手書きの SVG / HTML に貼る <svg> を出力する
//
// セット（プロジェクトに入っているものだけ使える）
//   lucide   線のアイコン（データベース・サーバ・人など）。ISC。npm i -D @iconify-json/lucide
//   logos    技術のロゴ（PostgreSQL・Redis・GitHub など、色つき）。CC0。npm i -D @iconify-json/logos
//            ロゴは各社の商標。その製品そのものを指すときだけ使う
// D2 からは icon: ./icons/<file>.svg、Mermaid からは <set>:<name>（figure-check がセットを登録する）で使う
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    dir: { type: 'string', default: 'figures/icons' }, as: { type: 'string' }, color: { type: 'string', default: '#1f2328' },
    size: { type: 'string', default: '24' }, x: { type: 'string', default: '0' }, y: { type: 'string', default: '0' }, sheet: { type: 'string' },
  },
});
const [cmd, ...args] = positionals;
function findUp(d, f) { for (; d !== dirname(d); d = dirname(d)) if (existsSync(join(d, f))) return d; return null; }
// アイコンセットは、実行したディレクトリのプロジェクトから探す。無ければ、このスクリプトの近くのプロジェクトから
const roots = [findUp(process.cwd(), 'package.json'), findUp(dirname(fileURLToPath(import.meta.url)), 'package.json')].filter(Boolean);
const tryReq = (id) => { for (const r of roots) { try { return createRequire(join(r, 'package.json'))(id); } catch {} } throw new Error(`cannot find ${id}`); };
const req = Object.assign((id) => tryReq(id), {});

export const SETS = ['lucide', 'logos'];
export function loadSet(prefix) {
  try { return { icons: req(`@iconify-json/${prefix}/icons.json`), info: req(`@iconify-json/${prefix}/info.json`) }; } catch { return null; }
}
const sets = Object.fromEntries(SETS.map((p) => [p, loadSet(p)]).filter(([, s]) => s));
if (!Object.keys(sets).length) { console.error('no icon set installed: npm i -D @iconify-json/lucide @iconify-json/logos'); process.exit(2); }

// set:name → { svg（単体の SVG 文字列）, w, h, set, name }
export function resolveIcon(ref, color = '#1f2328') {
  const [prefix, raw] = ref.includes(':') ? ref.split(':') : [null, ref];
  const cands = prefix ? [prefix] : Object.keys(sets);
  for (const p of cands) {
    const s = sets[p];
    if (!s) continue;
    const name = s.icons.aliases?.[raw]?.parent ?? raw;
    const icon = s.icons.icons[name];
    if (!icon) continue;
    const w = icon.width ?? s.icons.width ?? 16, h = icon.height ?? s.icons.height ?? 16;
    const body = icon.body.replace(/currentColor/g, color);
    return { set: p, name, w, h, body, svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}">${body}</svg>\n` };
  }
  return null;
}

function search(words) {
  const ws = words.map((w) => w.toLowerCase());
  const hits = [];
  for (const [p, s] of Object.entries(sets))
    for (const n of [...Object.keys(s.icons.icons), ...Object.keys(s.icons.aliases ?? {})])
      if (ws.every((w) => n.includes(w))) hits.push(`${p}:${n}`);
  return hits.sort((a, b) => a.length - b.length);
}

async function sheet(refs, out) {
  const { chromium } = req('playwright');
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1000, height: 600 }, deviceScaleFactor: 2 });
  const cells = refs.map((r) => [r, resolveIcon(r, opt.color)]).filter(([, i]) => i);
  await p.setContent(`<body style="margin:0;background:#fff;font:12px system-ui"><div id="w" style="display:inline-flex;flex-wrap:wrap;gap:8px;padding:12px;width:960px">
${cells.map(([r, i]) => `<div style="width:110px;text-align:center;border:1px solid #d0d7de;border-radius:6px;padding:8px 4px">${i.svg.replace('<svg ', '<svg style="width:40px;height:40px" ')}<div style="word-break:break-all;margin-top:4px">${r}</div></div>`).join('')}
</div></body>`);
  await (await p.$('#w')).screenshot({ path: out });
  await b.close();
}

if (cmd === 'search') {
  if (!args.length) { console.error('usage: icons.mjs search <word> [<word> …]'); process.exit(2); }
  const hits = search(args);
  console.log(hits.length ? hits.slice(0, 60).join('\n') : '(no match; try a shorter or more general word)');
  if (hits.length > 60) console.log(`… ${hits.length - 60} more`);
  if (opt.sheet && hits.length) { await sheet(hits.slice(0, 40), resolve(opt.sheet)); console.log(`\n  look at them: ${resolve(opt.sheet)}`); }
} else if (cmd === 'add') {
  const [ref] = args;
  const icon = ref && resolveIcon(ref, opt.color);
  if (!icon) { console.error(`not found: ${ref}. Search first: icons.mjs search <word>`); process.exit(1); }
  const dir = resolve(opt.dir);
  mkdirSync(dir, { recursive: true });
  const file = `${opt.as ?? icon.name}.svg`;
  writeFileSync(join(dir, file), icon.svg);
  // 出典とライセンスを ICONS.md に残す（同じファイル名の行は置き換える）
  const md = join(dir, 'ICONS.md');
  const { info } = sets[icon.set];
  const rows = existsSync(md) ? readFileSync(md, 'utf8').split('\n').filter((l) => l.startsWith('| `') && !l.startsWith(`| \`${file}\``)) : [];
  rows.push(`| \`${file}\` | \`${icon.set}:${icon.name}\` | [${info.name}](${info.author?.url ?? ''}) | [${info.license?.spdx ?? info.license?.title}](${info.license?.url ?? ''}) |`);
  writeFileSync(md, `# アイコンの出典\n\n\`icons.mjs add\` が書く。手で消さない。\n\n| ファイル | アイコン | セット | ライセンス |\n|---|---|---|---|\n${rows.sort().join('\n')}\n`);
  console.log(`wrote ${join(opt.dir, file)} (${icon.set}:${icon.name}, ${info.license?.spdx})`);
  console.log(`  D2:   icon: ./${join(opt.dir.replace(/^figures\/?/, ''), file) || file}   （.d2 から見た相対パス）`);
  console.log(`  見る: icons.mjs search ${icon.name} --sheet /tmp/icons.png`);
} else if (cmd === 'inline') {
  const [ref] = args;
  const icon = ref && resolveIcon(ref, opt.color);
  if (!icon) { console.error(`not found: ${ref}`); process.exit(1); }
  const s = Number(opt.size);
  console.log(`<svg x="${opt.x}" y="${opt.y}" width="${s}" height="${s}" viewBox="0 0 ${icon.w} ${icon.h}" role="img" aria-label="${icon.name}">${icon.body}</svg>`);
} else {
  console.error('usage: icons.mjs search <word…> [--sheet out.png] | add <set:name> [--dir figures/icons] [--as file] | inline <set:name> [--size 24]');
  process.exit(2);
}
