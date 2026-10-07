// 矢印の読みやすさ：D2 / Mermaid / data-edge 付きの SVG から「どの線がどの辺か」を取り出し、測る。
// figure-check.mjs と figure-variants.mjs が使う。
//
//   collectArrows   ブラウザの中で動かす。辺（from, to, 点列）と箱（葉の箱の矩形）を返す。
//                   辺の要素には data-arrow-index を付ける（あとで 1 本ずつ強調した画像を撮るため）
//   judgeArrows     Node 側で測る。{ fail: [...], look: [...] } を返す
//                     fail  shared   2 本の辺が長く重なって走る（分かれ目が、別の箱同士をつなぐ矢印に見える）
//                           through  辺が、端点でない箱の中を通る
//                     look  cross    辺どうしの交差
//                           detour   端点どうしの距離に比べて、ひどく遠回り
//                           against  流れ（direction）と逆向き。戻る辺なら意図どおりか確かめる
//   edgeSheet       辺を 1 本ずつ赤くした縮小画像を並べた 1 枚を作る

// ---- ブラウザ側 --------------------------------------------------------------------
export function collectArrows() {
  const figure = document.querySelector('#figure');
  const svg = figure.querySelector('svg');
  if (!svg) return { edges: [], nodes: [] };
  const screen = (el, p) => { const m = el.getScreenCTM(); return { x: m.a * p.x + m.c * p.y + m.e, y: m.b * p.x + m.d * p.y + m.f }; };
  const sample = (el) => {
    const len = el.getTotalLength?.() ?? 0;
    const pts = [];
    for (let d = 0; d < len; d += 2) pts.push(screen(el, el.getPointAtLength(d)));
    if (len) pts.push(screen(el, el.getPointAtLength(len)));
    return pts;
  };
  const rect = (el) => { const r = el.getBoundingClientRect(); return { l: r.left, t: r.top, r: r.right, b: r.bottom }; };
  const edges = [], nodes = [];
  const addEdge = (el, from, to) => {
    const pts = sample(el);
    if (pts.length < 2) return;
    el.setAttribute('data-arrow-index', String(edges.length));
    edges.push({ from, to, key: `${from}->${to}`, pts });
  };
  const unb64 = (s) => { try { return new TextDecoder('utf-8', { fatal: true }).decode(Uint8Array.from(atob(s), (c) => c.charCodeAt(0))); } catch { return null; } };
  const unent = (s) => s.replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&amp;/g, '&');

  // D2：各オブジェクトが class=base64(id) の <g>。辺の id は「箱.(a -> b)[0]」
  for (const g of svg.querySelectorAll('g[class]')) {
    const raw = unb64(g.getAttribute('class').split(' ')[0]);
    if (!raw || /[\x00-\x1f]/.test(raw)) continue;
    const id = unent(raw);
    const m = id.match(/^(.*?)\((.+?) (->|<-|<->|--) (.+?)\)\[\d+\]$/);
    if (m) {
      const path = g.querySelector('path.connection');
      if (!path) continue;
      const [a, b] = m[3] === '<-' ? [m[4], m[2]] : [m[2], m[4]];
      addEdge(path, m[1] + a, m[1] + b);
      continue;
    }
    const shape = g.querySelector(':scope > .shape');
    if (shape) nodes.push({ id, ...rect(shape) });
  }
  // Mermaid：箱は g.node（id は「<図>-flowchart-<id>-<n>」）、辺は path[data-edge]（id は「<図>-L_<from>_<to>_<n>」）
  // アイコンや画像の箱は g.node ではなく g.icon-shape / g.image-shape になる
  const mNodes = [...svg.querySelectorAll('g.node[id], g.icon-shape[id], g.image-shape[id]')].map((g) => ({ el: g, id: g.id.replace(/^.*?flowchart-/, '').replace(/-\d+$/, '') }));
  for (const n of mNodes) nodes.push({ id: n.id, ...rect(n.el) });
  for (const c of svg.querySelectorAll('g.cluster[id]')) nodes.push({ id: c.id.replace(/^.*?-(?=[^-]+$)/, ''), ...rect(c) });
  const ids = new Set(mNodes.map((n) => n.id));
  for (const p of svg.querySelectorAll('path[data-edge="true"][id]')) {
    const body = p.id.replace(/^.*?L_/, '').replace(/_\d+$/, '');
    const parts = body.split('_');
    for (let i = 1; i < parts.length; i++) {
      const a = parts.slice(0, i).join('_'), b = parts.slice(i).join('_');
      if (ids.has(a) && ids.has(b)) { addEdge(p, a, b); break; }
    }
  }
  // 手で書いた SVG：線に data-edge="a->b"、箱に data-node="a" を付けておけば、同じ検査が効く
  for (const el of svg.querySelectorAll('[data-edge]:not([data-edge="true"])')) {
    const [a, b] = el.getAttribute('data-edge').split('->').map((x) => x.trim());
    if (a && b) addEdge(el.matches('path, line, polyline') ? el : el.querySelector('path, line, polyline') ?? el, a, b);
  }
  for (const el of svg.querySelectorAll('[data-node]')) nodes.push({ id: el.getAttribute('data-node'), ...rect(el) });

  // 葉の箱：ほかの箱を含まない箱。入れ子の外側の箱（コンテナ）は、辺が通ってよい
  const inside = (a, b) => a.l >= b.l - 1 && a.r <= b.r + 1 && a.t >= b.t - 1 && a.b <= b.b + 1;
  for (const n of nodes) n.leaf = !nodes.some((o) => o !== n && inside(o, n) && (o.r - o.l) * (o.b - o.t) < (n.r - n.l) * (n.b - n.t));
  return { edges, nodes };
}

// ---- Node 側 ---------------------------------------------------------------------------
const dist = (p, q) => Math.hypot(p.x - q.x, p.y - q.y);
const length = (pts) => pts.slice(1).reduce((s, p, i) => s + dist(p, pts[i]), 0);

function segCross(p1, p2, p3, p4) {
  const d = (p2.x - p1.x) * (p4.y - p3.y) - (p2.y - p1.y) * (p4.x - p3.x);
  if (Math.abs(d) < 1e-9) return null;
  const t = ((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d;
  const u = ((p3.x - p1.x) * (p2.y - p1.y) - (p3.y - p1.y) * (p2.x - p1.x)) / d;
  return t > 0 && t < 1 && u > 0 && u < 1 ? { x: p1.x + t * (p2.x - p1.x), y: p1.y + t * (p2.y - p1.y) } : null;
}

// direction：'down' | 'up' | 'right' | 'left' | null（ソースから読む）
export function flowDirection(source, kind) {
  if (kind === 'd2') return source.match(/^direction:\s*(down|up|right|left)\s*$/m)?.[1] ?? null;
  if (kind === 'mmd') {
    const d = source.match(/^\s*(?:flowchart|graph)\s+(TD|TB|BT|LR|RL)\b/m)?.[1];
    return { TD: 'down', TB: 'down', BT: 'up', LR: 'right', RL: 'left' }[d] ?? null;
  }
  return null;
}

export function judgeArrows({ edges, nodes }, direction) {
  const fail = [], look = [];
  const name = (e) => e.key;
  // shared：a の点のうち、b の線から 2px 以内にあるものの長さ。端点の近く（12px）は、同じ箱から出る辺が重なって当然なので数えない
  for (let i = 0; i < edges.length; i++)
    for (let j = i + 1; j < edges.length; j++) {
      const a = edges[i], b = edges[j];
      const near = (p, e) => dist(p, e.pts[0]) < 12 || dist(p, e.pts.at(-1)) < 12;
      let run = 0;
      for (const p of a.pts) if (!near(p, a) && b.pts.some((q) => dist(p, q) <= 2)) run += 2;
      if (run >= 40) fail.push({ kind: 'shared', edges: [i, j], msg: `${name(a)} と ${name(b)} が ${run}px 重なって走る。分かれ目が、別の箱同士をつなぐ矢印に見える` });
    }
  // through：辺が、端点でない葉の箱の中（3px 内側）を通る
  for (const [i, e] of edges.entries()) {
    const hit = nodes.filter((n) => n.leaf && n.id !== e.from && n.id !== e.to && !e.from.startsWith(`${n.id}.`) && !e.to.startsWith(`${n.id}.`)
      && e.pts.some((p) => p.x > n.l + 3 && p.x < n.r - 3 && p.y > n.t + 3 && p.y < n.b - 3));
    if (hit.length) fail.push({ kind: 'through', edges: [i], msg: `${name(e)} が、端点でない箱 ${hit.map((n) => `"${n.id}"`).join(', ')} の中を通る` });
  }
  // cross：交差点。近い交差点（6px）はまとめる
  const crosses = [];
  for (let i = 0; i < edges.length; i++)
    for (let j = i + 1; j < edges.length; j++) {
      const a = edges[i].pts, b = edges[j].pts, pts = [];
      for (let s = 0; s + 1 < a.length; s += 1)
        for (let t = 0; t + 1 < b.length; t += 1) {
          const x = segCross(a[s], a[s + 1], b[t], b[t + 1]);
          if (x && !pts.some((q) => dist(q, x) < 6) && ![a[0], a.at(-1), b[0], b.at(-1)].some((q) => dist(q, x) < 10)) pts.push(x);
        }
      if (pts.length) crosses.push({ i, j, n: pts.length });
    }
  if (crosses.length) look.push({ kind: 'cross', edges: [...new Set(crosses.flatMap((c) => [c.i, c.j]))], msg: `交差 ${crosses.reduce((s, c) => s + c.n, 0)} か所：${crosses.slice(0, 4).map((c) => `${name(edges[c.i])} × ${name(edges[c.j])}`).join(', ')}` });
  // detour：長さが、端点どうしの縦横の距離の 1.8 倍を超え、120px 以上余計
  for (const [i, e] of edges.entries()) {
    const a = e.pts[0], b = e.pts.at(-1);
    const manhattan = Math.abs(a.x - b.x) + Math.abs(a.y - b.y), len = length(e.pts);
    if (len > 1.8 * manhattan && len - manhattan > 120) look.push({ kind: 'detour', edges: [i], msg: `${name(e)} が遠回り（長さ ${Math.round(len)}px、端点の距離 ${Math.round(manhattan)}px）` });
  }
  // against：流れと逆向きの辺
  if (direction) {
    const axis = { down: ['y', 1], up: ['y', -1], right: ['x', 1], left: ['x', -1] }[direction];
    const back = edges.map((e, i) => [e, i]).filter(([e]) => (e.pts.at(-1)[axis[0]] - e.pts[0][axis[0]]) * axis[1] < -20);
    if (back.length) look.push({ kind: 'against', edges: back.map(([, i]) => i), msg: `流れ（${direction}）と逆向きの辺：${back.map(([e]) => name(e)).join(', ')}。戻る辺として意図したものか確かめる` });
  }
  return { fail, look };
}

// 数字 1 つにまとめる（小さいほど良い）。候補を並べて比べるときに使う
export const arrowScore = ({ fail, look }) =>
  fail.length * 10 + look.reduce((s, x) => s + (x.kind === 'cross' ? Number(x.msg.match(/交差 (\d+)/)[1]) : x.kind === 'against' ? 0 : 1), 0);

// ---- 1 本ずつ強調した画像 -------------------------------------------------------------------
// page は図を載せたページ（collectArrows を済ませたもの）。flagged は問題のある辺の番号
export async function edgeSheet(page, browser, arrows, flagged, out) {
  const thumbs = [];
  const fig = await page.$('#figure');
  const order = [...new Set([...flagged, ...arrows.edges.keys()])].slice(0, 30);
  for (const i of order) {
    await page.evaluate((k) => {
      for (const el of document.querySelectorAll('[data-arrow-index]')) {
        const on = el.getAttribute('data-arrow-index') === String(k);
        el.style.opacity = on ? '1' : '0.15';
        el.style.stroke = on ? '#d1242f' : '';
        el.style.strokeWidth = on ? '5' : '';
      }
    }, i);
    thumbs.push({ i, png: (await fig.screenshot()).toString('base64') });
  }
  await page.evaluate(() => { for (const el of document.querySelectorAll('[data-arrow-index]')) el.removeAttribute('style'); });
  const p = await browser.newPage({ viewport: { width: 1400, height: 800 }, deviceScaleFactor: 1 });
  await p.setContent(`<body style="margin:0;padding:12px;background:#888;font:13px system-ui,'Noto Sans JP';display:flex;flex-wrap:wrap;gap:10px;align-items:flex-start">
${thumbs.map(({ i, png }) => `<div style="background:#fff;padding:6px;width:320px;${flagged.includes(i) ? 'outline:3px solid #d1242f' : ''}"><div>${i + 1}. ${arrows.edges[i].from} → ${arrows.edges[i].to}${flagged.includes(i) ? '（要確認）' : ''}</div><img src="data:image/png;base64,${png}" style="width:320px;display:block"></div>`).join('')}</body>`);
  await p.screenshot({ path: out, fullPage: true });
  await p.close();
}
