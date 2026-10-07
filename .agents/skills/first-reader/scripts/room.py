#!/usr/bin/env python3
"""Build the first-reader page: the draft with the reading still on it.

Takes a run directory holding one or more feed.py sessions and emits a
single self-contained HTML page: the draft passage by passage, each
reader's margin notes with their needle, quit points rendered as a fold
line, a needle strip up top, and lenses. It is a report: the author
acts on it by talking to their agent, not by clicking.

Usage:
  python3 room.py <run-dir> [--out room.html] [--annotations room-annotations.json]

<run-dir> layout: every subdirectory containing state.json + log.jsonl is
a reader session. All sessions must come from the same draft.

The page builds without annotations, using deterministic fallbacks:
excerpts are trimmed from the raw logs, and the memory/trust lenses hide
until the annotations file provides their phrase lists. The annotations
format is documented in references/room.md; the reviewing agent writes it
after the recall and report steps so the page carries curated excerpts, a
plain-language verdict, flags, and the lens data.
"""
import argparse
import html
import json
import re
from pathlib import Path

VERSION = "1.0.0"
M1, M2 = "\ue000", "\ue001"
P1, P2 = "\ue002", "\ue003"
E1, E2 = "\ue004", "\ue005"
N1, N2 = "\ue006", "\ue007"


def esc(t):
    return html.escape(t, quote=False)


class Marker:
    def __init__(self, mem, portable, ents):
        self.mem = sorted(mem, key=len, reverse=True)
        self.portable = portable
        self.ents = sorted(ents, key=len, reverse=True)

    def wrap(self, seg):
        for ph in self.mem:
            seg = seg.replace(esc(ph), M1 + esc(ph) + M2)
        for ph in self.portable:
            seg = seg.replace(esc(ph), P1 + esc(ph) + P2)
        for ph in self.ents:
            seg = re.sub(r"(?<![\w>-])(" + re.escape(ph) + r")(?![\w])", E1 + r"\1" + E2, seg)
        seg = re.sub(r"(?<![\w-])([\w$][\w.,:%$-]*\d[\w.,:%$-]*)", N1 + r"\1" + N2, seg)
        return seg

    def mark(self, h):
        parts = re.split(r"(<[^>]+>)", h)
        out = "".join(p if p.startswith("<") else self.wrap(p) for p in parts)
        return (out.replace(M1, '<mark class="mem">').replace(M2, "</mark>")
                   .replace(P1, '<span class="portable">').replace(P2, "</span>")
                   .replace(E1, '<span class="ent">').replace(E2, "</span>")
                   .replace(N1, '<span class="num">').replace(N2, "</span>"))


def inline_md(t):
    t = esc(t)
    t = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1", t)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    return t


def first_sentence_wrap(phtml):
    m = re.search(r"[.!?](\s|$)", phtml)
    if not m:
        return f'<span class="fs">{phtml}</span>'
    i = m.end()
    return f'<span class="fs">{phtml[:i]}</span>{phtml[i:]}'


def md_block(text, marker):
    out, lines, i = [], text.split("\n"), 0
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("```"):
            buf = []
            i += 1
            while i < len(lines) and not lines[i].startswith("```"):
                buf.append(lines[i]); i += 1
            i += 1
            # tabindex so a keyboard user can scroll a wide block
            out.append('<pre class="code" tabindex="0">' + marker.mark(esc("\n".join(buf))) + "</pre>")
            continue
        if re.match(r"#{1,6}\s", ln):
            # one level down: the page's own title is the only h1
            lvl = min(len(ln) - len(ln.lstrip("#")) + 1, 4)
            out.append(f"<h{lvl}>{marker.mark(inline_md(ln.lstrip('# ')))}</h{lvl}>")
            i += 1; continue
        if re.match(r"(\*|-|\d+\.)\s", ln):
            items = []
            while i < len(lines) and re.match(r"(\*|-|\d+\.)\s", lines[i]):
                item = re.sub(r"^(\*|-|\d+\.)\s+", "", lines[i])
                items.append("<li>" + first_sentence_wrap(marker.mark(inline_md(item))) + "</li>")
                i += 1
            out.append("<ul>" + "".join(items) + "</ul>")
            continue
        if ln.strip():
            para = [ln]
            i += 1
            while i < len(lines) and lines[i].strip() and not re.match(r"(#{1,6}|\*|-|\d+\.|```)\s?", lines[i]):
                para.append(lines[i]); i += 1
            out.append("<p>" + first_sentence_wrap(marker.mark(inline_md(" ".join(para)))) + "</p>")
            continue
        i += 1
    return "\n".join(out)


def load_sessions(run_dir):
    sessions = []
    for d in sorted(run_dir.iterdir()):
        if d.is_dir() and (d / "state.json").exists() and (d / "log.jsonl").exists():
            state = json.loads((d / "state.json").read_text())
            entries = [json.loads(l) for l in (d / "log.jsonl").read_text().splitlines() if l.strip()]
            sessions.append({"dir": d.name, "state": state, "entries": entries})
    if not sessions:
        raise SystemExit(f"No sessions (state.json + log.jsonl) found under {run_dir}")
    n = len(sessions[0]["state"]["chunks"])
    for s in sessions:
        if len(s["state"]["chunks"]) != n:
            raise SystemExit("Sessions disagree on passage count; they must come from one draft.")
    return sessions


def parse_needle(entry):
    m = re.search(r"needle\s*[=:]?\s*([+-]?\d)", entry)
    if not m:
        return 0
    return max(-2, min(2, int(m.group(1))))


def auto_excerpt(entry):
    t = re.sub(r"^\s*needle\s*[=:]?\s*[+-]?\d[.,;:]?\s*", "", entry).strip()
    parts = re.split(r"(?<=[.!?])\s+", t)
    out = ""
    for p in parts:
        if out and len(out) + len(p) > 200:
            break
        out = (out + " " + p).strip()
        if len(out) > 140:
            break
    return out[:240]


def needle_map(session):
    per = {}
    for e in session["entries"]:
        per[e["chunk"]] = parse_needle(e["entry"])
    return per


def prev_strip(prev_run):
    """A dimmed strip of last run's needles so revision reads as progress."""
    try:
        psess = load_sessions(Path(prev_run))
    except SystemExit:
        return ""
    pn = len(psess[0]["state"]["chunks"])
    cells = []
    for idx in range(1, pn + 1):
        rows = []
        for ps in psess:
            v = needle_map(ps).get(idx)
            rows.append(f'<i class="tr v{"x" if v is None else v}"></i>')
        cells.append(f'<span class="cell" role="img" aria-label="last time, passage {idx}">{"".join(rows)}</span>')
    return (f'<div class="scrublabel">last time ({pn} passages)</div>'
            f'<div class="scrub prev" aria-label="how each reader felt last time">{"".join(cells)}</div>'
            '<div class="scrublabel">this time</div>')


def needle_chip(v):
    cls = {2: "n2", 1: "n1", 0: "n0", -1: "nm1", -2: "nm2"}[v]
    return f'<span class="chip {cls}">{"+" if v > 0 else ""}{v}</span>'


def render_skim(skim):
    """The skim gate's verdict: what a scanner thought this was, and whether they opened it."""
    if not skim:
        return ""
    committed = skim.get("commits")
    tag = "opened it" if committed else "moved on"
    return (f'<div class="skim"><div class="flabel">the skimmer {tag}</div>'
            f'<p>{esc(skim.get("said", ""))}</p></div>')


def render_ask_hint(sessions):
    names = " or ".join(f'"ask {s["initial"]} ..."' for s in sessions[:2])
    return (f'<div class="askhint">These are people you can consult. In chat: {names}, '
            f'"ask the skimmer what would have made them open it", or "ask everyone ...". '
            f'Revise in your own editor, then "again" for a fresh read.</div>')


def render_stats(sessions, n):
    """The chips in the top bar: readers, finished, stopped early, passages, fixes."""
    finished = sum(1 for s in sessions if not s["quit_at"])
    quits = len(sessions) - finished
    stats = [f'<span class="statchip"><b>{len(sessions)}</b> readers</span>',
             f'<span class="statchip"><b>{finished}</b> finished</span>']
    if quits:
        stats.append(f'<span class="statchip" style="color:var(--nm2-ink)"><b>{quits}</b> stopped early</span>')
    stats.append(f'<span class="statchip"><b>{n}</b> passages</span>')
    stats_html = "".join(stats)

    return stats_html


def render_legend(sessions, chunk_html):
    """The card that introduces the readers and the needle chips to a first-time author."""
    count_word = {1: "One reader", 2: "Two readers", 3: "Three readers", 4: "Four readers"}.get(
        len(sessions), f"{len(sessions)} readers")
    legend_items = "".join(
        f'<span class="litem"><span class="who w{s["key"]}">{esc(s["initial"])}</span>{esc(s["title"])}</span>'
        for s in sessions)
    any_skim = any('class="skimtag"' in c for c in chunk_html)
    skim_item = ('<span class="litem"><span class="skimtag">skim</span>started skimming here</span>'
                 if any_skim else "")
    legend_html = ('<div class="legend"><div class="lrow"><span class="flabel">about the margin notes</span> '
                   f'{count_word} met this piece one passage at a time, no peeking ahead, and wrote down each '
                   'reaction as it happened. Those raw notes sit beside each passage.</div>'
                   f'<div class="lrow">{legend_items}</div>'
                   '<div class="lrow"><span class="flabel">each note starts with how it felt</span>'
                   '<span class="litem"><span class="chip n2">+2</span>leaning in</span>'
                   '<span class="litem"><span class="chip n0">0</span>neutral</span>'
                   '<span class="litem"><span class="chip nm2">-2</span>wanted out</span>'
                   f'{skim_item}</div></div>')

    return legend_html


def lens_controls(ann):
    """Lens buttons for the data the annotations actually carry, and the label that names them."""
    have_mem = bool(ann.get("memory_phrases"))
    have_trust = bool(ann.get("portable_sentences") or ann.get("entities"))
    views_label = "see it: as a skimmer" + (" · what stuck" if have_mem else "") + \
        (" · trust signals" if have_trust else "") + " · replay the read"
    lens_btns = ['<button class="btn" id="lensRead" aria-pressed="true" onclick="lens(\'read\')">reading</button>',
                 '<button class="btn" id="lensScan" aria-pressed="false" onclick="lens(\'scan\')">what a skimmer sees</button>']
    if have_mem:
        lens_btns.append('<button class="btn" id="lensMem" aria-pressed="false" onclick="lens(\'mem\')">what stuck</button>')
    if have_trust:
        lens_btns.append('<button class="btn" id="lensTrust" aria-pressed="false" onclick="lens(\'trust\')">trust</button>')

    return lens_btns, views_label


def build(run_dir, out_path, ann):
    sessions = load_sessions(run_dir)
    chunks = sessions[0]["state"]["chunks"]
    n = len(chunks)
    readers_meta = ann.get("readers", {})
    used_initials = set()
    for ix, s in enumerate(sessions):
        meta = readers_meta.get(s["dir"], {})
        persona = s["state"].get("persona") or s["dir"]
        initial = meta.get("initial") or persona[:1].upper()
        while initial in used_initials:
            initial += "2"
        used_initials.add(initial)
        s["initial"] = initial
        s["label"] = meta.get("label") or persona
        s["title"] = meta.get("title") or persona
        s["key"] = f"r{ix}"
        s["quit_at"] = s["state"].get("quit_at")
        per = {}
        for e in s["entries"]:
            c = e["chunk"]
            exc = ann.get("excerpts", {}).get(s["dir"], {}).get(str(c)) or auto_excerpt(e["entry"])
            skim = bool(re.search(r"\bskim", e["entry"], re.I)) and not \
                re.search(r"(stop(ped)?|quit|no longer|slowed|without)[^.]{0,20}skimm", e["entry"], re.I)
            per[c] = {"needle": parse_needle(e["entry"]),
                      "skim": skim,
                      "quit": e.get("quit", False), "text": exc}
        s["per"] = per

    marker = Marker(ann.get("memory_phrases", []), ann.get("portable_sentences", []),
                    ann.get("entities", []))
    flags = {int(k): v for k, v in ann.get("flags", {}).items()}

    chunk_html = []
    for idx, ch in enumerate(chunks, 1):
        body = md_block(ch, marker)
        skim_attrs = "".join(f' data-skim-{s["key"]}="1"' for s in sessions if s["per"].get(idx, {}).get("skim"))
        unseen_attrs = "".join(f' data-unseen-{s["key"]}="1"' for s in sessions
                               if s["quit_at"] and idx > s["quit_at"])
        flag = f'<div class="flag">{esc(flags[idx])}</div>' if idx in flags else ""
        notes = []
        for s in sessions:
            e = s["per"].get(idx)
            if not e:
                continue
            final = (not s["quit_at"]) and idx == max(s["per"])
            quit_here = s["quit_at"] == idx
            tag = ('<span class="skimtag">skimmed</span>' if e["skim"] else "")
            head = ('<span class="skimtag stop">stopped reading here</span>' if quit_here else tag)
            notes.append(
                f'<div class="note note-{s["key"]}{" final" if (final or quit_here) else ""}">'
                f'<span class="who w{s["key"]}" title="{esc(s["title"])}">{esc(s["initial"])}</span>'
                f'{needle_chip(e["needle"])}{head}<span class="ntext">{esc(e["text"])}</span></div>')
        folds = "".join(
            f'<div class="fold">{esc(s["initial"])} stopped here. They never saw anything below this line.</div>'
            for s in sessions if s["quit_at"] == idx)
        chunk_html.append(f"""
  <section class="chunk" id="c{idx}" data-i="{idx}"{skim_attrs}{unseen_attrs}>
    <div class="prose">{flag}<div class="cnum">passage {idx:02d} of {n}</div>{body}</div>
    <div class="notes" role="group" aria-label="notes on passage {idx}">{''.join(notes)}</div>
  </section>{folds}""")

    cells = []
    for idx in range(1, n + 1):
        fl = f'<i class="fmark" title="{esc(flags[idx])}"></i>' if idx in flags else ""
        rows, said = [], []
        for s in sessions:
            e = s["per"].get(idx)
            v = "x" if e is None else e["needle"]
            rows.append(f'<i class="tr t{s["key"]} v{v}"></i>')
            said.append(f'{s["initial"]} ' + ("did not see it" if e is None else f'{"+" if e["needle"] > 0 else ""}{e["needle"]}'))
        label = f'passage {idx}: ' + ", ".join(said) + (f' ({flags[idx]})' if idx in flags else "")
        cells.append(f'<button class="cell" onclick="jump({idx})" aria-label="{esc(label)}">{"".join(rows)}{fl}</button>')

    sel_btns = ['<button class="btn" id="selall" aria-pressed="true" onclick="sel(\'all\')">both</button>'
                if len(sessions) > 1 else ""]
    for s in sessions:
        sel_btns.append(f'<button class="btn" id="sel{s["key"]}" aria-pressed="false" '
                        f'onclick="sel(\'{s["key"]}\')">{esc(s["label"])}</button>')
    sel_css = "\n".join(
        f'body.sel-{s["key"]} .note:not(.note-{s["key"]}) {{ display:none }}\n'
        f'body.sel-{s["key"]} .chunk[data-skim-{s["key"]}="1"] .prose {{ opacity:.38 }}\n'
        f'body.sel-{s["key"]} .chunk[data-unseen-{s["key"]}="1"] .prose {{ opacity:.12 }}\n'
        f'body.sel-{s["key"]} .tr:not(.t{s["key"]}) {{ opacity:.15 }}'
        for s in sessions)
    palette = [("var(--n1)", "var(--on-n1)"), ("var(--ink-soft)", "#fff"),
               ("var(--nm1)", "var(--on-nm1)"), ("var(--n2)", "var(--on-n2)")]
    who_css = "\n".join(f'.w{s["key"]} {{ background:{palette[ix % len(palette)][0]}; color:{palette[ix % len(palette)][1]} }}'
                        for ix, s in enumerate(sessions))

    lens_btns, views_label = lens_controls(ann)

    skim_html = render_skim(ann.get("skim"))
    ask_html = render_ask_hint(sessions)
    stats_html = render_stats(sessions, n)

    verdict_lead = ann.get("verdict_lead", "The readers are done. Their notes are in the margin.")
    verdict_rest = ann.get("verdict_rest", "")
    previous = ann.get("previous", {}).get("summary", "")
    prev_html = f'<p class="prev"><b>Since last time:</b> {esc(previous)}</p>' if previous else ""
    prev_run = ann.get("previous", {}).get("run")
    prevscrub_html = prev_strip(prev_run) if prev_run and Path(prev_run).is_dir() else ""
    opinions = ann.get("opinions", [])
    opinions_html = ""
    if opinions:
        lis = "".join(f"<li>{esc(o)}</li>" for o in opinions)
        opinions_html = (f'<details class="envelope"><summary>I\'d push back on {len(opinions)} '
                         f'spot{"s" if len(opinions) > 1 else ""}. Ask me and I\'ll make the case.</summary><ul>{lis}</ul>'
                         '<p style="font-size:.85rem;color:var(--mute)">These stay opinions; the rewrite stays yours.</p></details>')
    reader_intro = " ".join(
        f'<span class="who w{s["key"]}">{esc(s["initial"])}</span>{esc(s["title"])}.' for s in sessions)

    legend_html = render_legend(sessions, chunk_html)

    tpl = (Path(__file__).parent / "room_template.html").read_text(encoding="utf-8")
    heading = next((ln.lstrip("# ").strip() for ln in chunks[0].splitlines()
                    if re.match(r"#{1,6}\s", ln)), None)
    default_title = f"First read: {heading}" if heading else "First read of your draft"
    page = (tpl.replace("@@TITLE@@", esc(ann.get("title", default_title)))
               .replace("@@VERSION@@", VERSION)
               .replace("@@STATS@@", stats_html)
               .replace("@@VERDICT_LEAD@@", esc(verdict_lead))
               .replace("@@VERDICT_REST@@", esc(verdict_rest))
               .replace("@@PREVIOUS@@", prev_html)
               .replace("@@PREVSCRUB@@", prevscrub_html)
               .replace("@@N@@", str(n))
               .replace("@@READER_INTRO@@", reader_intro)
               .replace("@@LEGEND@@", legend_html)
               .replace("@@SEL_BTNS@@", "".join(sel_btns))
               .replace("@@LENS_BTNS@@", "".join(lens_btns))
               .replace("@@VIEWS_LABEL@@", views_label)
               .replace("@@SEL_CSS@@", sel_css)
               .replace("@@WHO_CSS@@", who_css)
               .replace("@@SCRUB@@", "".join(cells))
               .replace("@@CHUNKS@@", "".join(chunk_html))
               .replace("@@SKIM@@", skim_html)
               .replace("@@ASKHINT@@", ask_html)
               .replace("@@OPINIONS@@", opinions_html))
    out_path.write_text(page, encoding="utf-8")
    print(f"wrote {out_path} ({len(page)} bytes, {n} passages, {len(sessions)} readers)")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("run_dir", type=Path)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--annotations", type=Path, default=None)
    a = ap.parse_args()
    ann = {}
    ann_path = a.annotations or (a.run_dir / "room-annotations.json")
    if ann_path.exists():
        ann = json.loads(ann_path.read_text())
    build(a.run_dir, a.out or (a.run_dir / "room.html"), ann)


if __name__ == "__main__":
    main()
