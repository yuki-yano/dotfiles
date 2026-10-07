#!/usr/bin/env node
// Markdown を自己完結 HTML にする。1 ページでも、章立ての本でも。
// - figures/*.svg への画像リンクは SVG をそのまま埋め込む (外部参照なし)
// - figures/*.fig.png への画像リンクは、同名の *.fig.html（手で書いた HTML の図）があればそれを埋め込む
// - 複数ページのときは、ページ間の .md リンクを .html に張り替え、目次・前後の章へのナビを付ける
//
//   node build-html.mjs <doc>/README.md                       → dist/index.html
//   node build-html.mjs <book>/README.md <book>/01-x.md …     → dist/index.html, dist/01-x.html, …
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { basename, dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

// 依存は「資料を置いたリポジトリ」の node_modules から解決する。
// プラグインとして入れたとき、このスクリプトの隣には node_modules が無いため。
const projectRequire = createRequire(join(process.cwd(), 'package.json'));
let marked;
try {
  ({ marked } = await import(pathToFileURL(projectRequire.resolve('marked')).href));
} catch {
  console.error('marked is not installed in this project: npm i -D marked @mizchi/vlmkit playwright');
  process.exit(2);
}

const pages = (process.argv.length > 2 ? process.argv.slice(2) : ['README.md']).map((p) => resolve(p));
const docDir = dirname(pages[0]);
const dist = join(docDir, 'dist');
mkdirSync(dist, { recursive: true });

const htmlName = (md) => (basename(md) === 'README.md' ? 'index.html' : basename(md).replace(/\.md$/, '.html'));
const titleOf = (src) => src.match(/^# (.+)$/m)?.[1] ?? 'Explainer';
const sources = pages.map((p) => readFileSync(p, 'utf8'));
const book = pages.length > 1;
const mdNames = new Set(pages.map((p) => basename(p)));

function render(src) {
  let md = src.replace(/<!--[\s\S]*?-->/g, '');
  // 図のマークアップは Markdown に通さない。空行や字下げがあると、marked が HTML ブロックを閉じて
  // 残りを <pre> にしてしまうため（D2 の SVG で起きた）。置き換え用の印を置き、変換のあとで戻す
  const figures = [];
  const hold = (html) => `\n\nXFIGUREX${figures.push(html) - 1}XFIGUREX\n\n`;
  // HTML の図：Markdown は figures/<name>.fig.png を参照し、HTML では figures/<name>.fig.html をそのまま埋め込む
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?)\.fig\.png\)/g, (all, alt, base) => {
    const html = join(docDir, `${base}.fig.html`);
    if (!existsSync(html)) return all;
    return hold(`<figure aria-label="${alt}">${readFileSync(html, 'utf8')}<figcaption>${alt}</figcaption></figure>`);
  });
  // SVG の図 → インライン SVG
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?)\.svg\)/g, (_, alt, base) => {
    const svg = readFileSync(join(docDir, `${base}.svg`), 'utf8').replace(/<\?xml[^>]*>/, '');
    return hold(`<figure role="img" aria-label="${alt}">${svg}<figcaption>${alt}</figcaption></figure>`);
  });
  // 画像（PNG など）の図 → data: URI で埋め込む（出力の HTML 1 枚で完結させる。dist には figures/ を写さない）
  const mime = { png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', gif: 'image/gif', webp: 'image/webp' };
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?\.(png|jpe?g|gif|webp))\)/g, (all, alt, file, ext) => {
    const path = join(docDir, file);
    if (!existsSync(path)) return all;
    return hold(`<figure><img src="data:${mime[ext]};base64,${readFileSync(path).toString('base64')}" alt="${alt}" style="max-width:100%;height:auto"><figcaption>${alt}</figcaption></figure>`);
  });
  // 本の中のページへのリンクを .html に
  md = md.replace(/\]\(([\w.-]+\.md)(#[^)]*)?\)/g, (all, file, hash = '') =>
    mdNames.has(file) ? `](${htmlName(file)}${hash})` : all);
  return marked.parse(md).replace(/<p>XFIGUREX(\d+)XFIGUREX<\/p>|XFIGUREX(\d+)XFIGUREX/g, (_, a, b) => figures[Number(a ?? b)]);
}

function nav(i) {
  if (!book) return '';
  const link = (j, label) => `<a href="${htmlName(pages[j])}">${label}${titleOf(sources[j])}</a>`;
  const prev = i > 0 ? link(i - 1, '← ') : '<span></span>';
  const next = i < pages.length - 1 ? link(i + 1, '→ ') : '<span></span>';
  const toc = i > 0 ? `<a href="index.html">目次</a>` : '';
  return `<nav class="book" aria-label="章の移動">${prev}${toc}${next}</nav>`;
}

const CSS = `
:root { --bg: #ffffff; --fg: #1f2328; --muted: #57606a; --line: #d0d7de; --code: #f6f8fa; --accent: #0550ae; --fig: #ffffff; }
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { --bg: #0d1117; --fg: #e6edf3; --muted: #9da7b3; --line: #30363d; --code: #161b22; --accent: #79c0ff; --fig: #ffffff; }
}
:root[data-theme="dark"] { --bg: #0d1117; --fg: #e6edf3; --muted: #9da7b3; --line: #30363d; --code: #161b22; --accent: #79c0ff; --fig: #ffffff; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--fg); font: 16px/1.75 system-ui, -apple-system, "Hiragino Sans", "Noto Sans JP", sans-serif; }
main { max-width: 760px; margin: 0 auto; padding: 32px 16px 96px; }
h1 { font-size: 1.8rem; line-height: 1.35; }
h2 { margin-top: 2.6em; padding-top: .6em; border-top: 1px solid var(--line); font-size: 1.35rem; }
h3 { margin-top: 1.8em; font-size: 1.1rem; }
a { color: var(--accent); }
code { background: var(--code); padding: .1em .3em; border-radius: 4px; font-size: .9em; }
pre { background: var(--code); border: 1px solid var(--line); border-radius: 6px; padding: 12px 14px; overflow-x: auto; line-height: 1.5; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; display: block; overflow-x: auto; font-size: .93rem; }
th, td { border: 1px solid var(--line); padding: 6px 10px; text-align: left; vertical-align: top; }
blockquote { margin: 1em 0; padding: .2em 1em; border-left: 4px solid var(--line); color: var(--muted); }
figure { margin: 1.5em 0; }
figure svg { display: block; max-width: 100%; max-height: 720px; width: auto; height: auto; margin: 0 auto; background: var(--fig); border-radius: 6px; }
figcaption { color: var(--muted); font-size: .9rem; text-align: center; margin-top: .4em; }
details { border: 1px solid var(--line); border-radius: 6px; padding: 8px 12px; margin: .6em 0; }
summary { cursor: pointer; font-weight: 600; }
nav.book { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px 16px; padding: 12px 0; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); font-size: .93rem; }
`;

pages.forEach((p, i) => {
  const title = titleOf(sources[i]);
  const html = `<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<style>${CSS}</style>
</head>
<body><main>
${nav(i)}
${render(sources[i])}
${nav(i)}
</main></body>
</html>
`;
  writeFileSync(join(dist, htmlName(p)), html);
  console.log(`wrote ${join(dist, htmlName(p))}`);
});
