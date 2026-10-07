#!/usr/bin/env python3
"""Reveal a draft to a reader one passage at a time, with no lookahead.

Modified by the explainer project (2026-09): word counts treat CJK text as
about one word per two characters, and sentences also end at 。！？, so
Japanese drafts are served in paragraph-sized beats and paced like English.
Upstream: https://github.com/Shubhamsaboo/awesome-llm-apps/tree/main/agent_skills/first-reader

Humans read forward in time: at any sentence they know what came before,
roughly how much text remains, and nothing else. An LLM sees the whole
document at once, which makes "read this like a human" performed rather
than real. This driver restores the arrow of time, and in served mode it
enforces it: the text lives only in the memory of a local server the
orchestrator starts; each reader gets a one-line address with a token
and never a path; the server releases the next passage only after the
reader logs what just happened in them, never re-serves anything but the
current passage, and refuses to move faster than a person could read.
Nothing about the piece is written where a reader could find it until
every reader is finished.

SERVED MODE (default whenever readers are separate agents)

  Orchestrator, in the background:
    python3 feed.py serve <draft> --run <run-dir> --readers keen,skeptic
  It prints one READER_FEED address per reader plus an admin address.
  Hand each reader ONLY its own address, e.g.
    export READER_FEED=http://127.0.0.1:PORT/<token>

  Reader (READER_FEED set in its shell):
    python3 feed.py start
    python3 feed.py next --log "needle=<-2..+2> expected... got... <felt notes>"
    python3 feed.py quit --log "needle=-2 <why the persona stopped>"

  Orchestrator, to watch and to finish:
    python3 feed.py progress --admin <admin-address>
    python3 feed.py close --admin <admin-address>
  Closing writes <run-dir>/<reader>/state.json + log.jsonl in the layout
  recall.py and room.py expect. Logs stream to log.jsonl live (they hold
  only the reader's own words). The server also closes itself once every
  reader has finished or quit.

FILE MODE (solo fallback: one mind plays reader and reviewer)

    python3 feed.py start <draft> --session <dir> [--persona <name>]
    python3 feed.py next <dir> --log "<entry>"
    python3 feed.py quit <dir> --log "<entry>"
    python3 feed.py transcript <dir>
    python3 feed.py status <dir>

Log entry format (one line, free text, but include):
  needle=<-2..+2>  the felt reaction right now, minus is boredom/distrust
  expect: what you now expect next     got: what this chunk actually was
  plus anything felt: skimmed, lost, won back, doubted a claim, laughed.
"""
import argparse
import json
import os
import re
import secrets
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib import request as urlrequest
from urllib.error import HTTPError

TARGET_WORDS = 85   # a paragraph-scale beat
MAX_WORDS = 200     # split anything longer: nobody swallows 200 words as one beat
MIN_LOG_CHARS = 25

_CJK = re.compile(r"[\u3040-\u30ff\u3400-\u9fff\uf900-\ufaff\uff66-\uff9f]")


def nwords(text):
    """Space-separated words, plus about one word per two CJK characters."""
    cjk = len(_CJK.findall(text))
    return len(_CJK.sub(" ", text).split()) + (cjk + 1) // 2


def chunk(text):
    paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
    out, buf, buf_words = [], [], 0
    for p in paras:
        w = nwords(p)
        if w > MAX_WORDS:
            if buf:
                out.append("\n\n".join(buf)); buf, buf_words = [], 0
            sentences = re.findall(r".+?(?:[.!?](?=\s|$)|[。！？]|$)", p, re.S)
            piece, count = [], 0
            for s in sentences:
                sw = s.split()
                # a sentence-less blob (transcript, list dump) still gets beats
                while len(sw) > MAX_WORDS:
                    out.append(" ".join(piece + sw[:TARGET_WORDS]))
                    piece, count, sw = [], 0, sw[TARGET_WORDS:]
                piece.append(" ".join(sw)); count += nwords(" ".join(sw))
                if count >= TARGET_WORDS:
                    out.append(" ".join(piece)); piece, count = [], 0
            if piece:
                out.append(" ".join(piece))
            continue
        # keep a heading attached to the paragraph that follows it
        if re.match(r"#{1,6}\s", p) and buf_words == 0:
            buf.append(p); continue
        buf.append(p); buf_words += w
        if buf_words >= TARGET_WORDS:
            out.append("\n\n".join(buf)); buf, buf_words = [], 0
    if buf:
        out.append("\n\n".join(buf))
    return out



BRIEFING = ("You are this persona encountering this text cold. React honestly; "
            "your persona's patience budget is real, and quitting is a finding, "
            "not a failure.")


def chunk_header(i, chunks):
    remaining = sum(nwords(c) for c in chunks[i + 1:])
    return f"--- CHUNK {i + 1}/{len(chunks)} ({remaining} words remain after this) ---"


def chunk_footer():
    return ("--- record your moment log with: feed.py next --log \"...\" "
            "(or feed.py quit --log \"...\" if your persona stops here) ---")


def dwell_floor(text, factor):
    # a person needs roughly words/4 seconds at 238 wpm; the floor is a
    # fraction of that so honest readers never notice it and racers do
    return max(2.0, nwords(text) * factor) if factor > 0 else 0.0


# ---------------------------------------------------------------- served mode

class Feed:
    def __init__(self, draft, run_dir, names, persona_titles, dwell):
        text = Path(draft).read_text(encoding="utf-8")
        self.chunks = chunk(text)
        self.words = nwords(text)
        self.run_dir = Path(run_dir)
        self.dwell = dwell
        self.admin = secrets.token_urlsafe(18)
        self.readers = {}
        self.lock = threading.Lock()
        self.closed = False
        for name in names:
            token = secrets.token_urlsafe(18)
            d = self.run_dir / name
            d.mkdir(parents=True, exist_ok=True)
            (d / "log.jsonl").write_text("")
            self.readers[token] = {"name": name, "persona": persona_titles.get(name, name),
                                   "cursor": 0, "started": None, "served_at": None,
                                   "done": False, "quit_at": None, "log": []}

    def _payload(self, r):
        i = r["cursor"]
        r["served_at"] = time.time()
        return {"header": chunk_header(i, self.chunks), "text": self.chunks[i],
                "footer": chunk_footer(), "index": i + 1, "total": len(self.chunks)}

    def start(self, r):
        if r["done"]:
            return {"error": "Session already finished."}
        first = r["started"] is None
        if first:
            r["started"] = time.time()
        p = self._payload(r)
        p["briefing"] = (f"SESSION {r['name']} | persona: {r['persona']} | "
                         f"{len(self.chunks)} chunks, {self.words} words total\n{BRIEFING}") if first else \
            "(re-showing the current passage; nothing advanced)"
        return p

    def _record(self, r, entry, quit_, check_dwell=True, chunk=None):
        entry = (entry or "").strip()
        if len(entry) < MIN_LOG_CHARS:
            return {"refused": f"log entry under {MIN_LOG_CHARS} chars. What happened in you "
                               "during that chunk? needle=?, expected what, got what?"}
        # the dwell floor guards lookahead; quitting reveals nothing, so a
        # reader may leave the instant a passage loses them
        if check_dwell and r["served_at"] is not None and self.dwell > 0:
            floor = dwell_floor(self.chunks[r["cursor"]], self.dwell)
            waited = time.time() - r["served_at"]
            if waited < floor:
                return {"refused": f"too fast: a person needs about {floor:.0f}s with this passage "
                                   f"and {waited:.0f}s have passed. Read it, then log what happened."}
        rec = {"chunk": chunk or r["cursor"] + 1, "quit": quit_, "entry": entry, "t": time.time()}
        r["log"].append(rec)
        with (self.run_dir / r["name"] / "log.jsonl").open("a") as f:
            f.write(json.dumps(rec) + "\n")
        return None

    def next(self, r, entry):
        if r["done"]:
            return {"error": "Session already finished."}
        if r["started"] is None:
            return {"error": "Call feed.py start first."}
        bad = self._record(r, entry, False)
        if bad:
            return bad
        r["cursor"] += 1
        if r["cursor"] >= len(self.chunks):
            r["done"] = True
            self._maybe_finish()
            return {"end": "END OF PIECE. The reader finished. Add one final log line for the "
                           "ending itself via: feed.py quit --log \"final: ...\""}
        return self._payload(r)

    def quit(self, r, entry):
        if r["started"] is None:
            return {"error": "Call feed.py start first."}
        finished = r["done"] or r["cursor"] >= len(self.chunks) - 1
        # a final reaction after END belongs to the last chunk, not cursor+1
        last_chunk = len(self.chunks) if r["done"] else None
        bad = self._record(r, entry, not finished, check_dwell=False, chunk=last_chunk)
        if bad:
            return bad
        r["done"] = True
        r["quit_at"] = None if finished else r["cursor"] + 1
        r["served_at"] = time.time()
        self._maybe_finish()
        if r["quit_at"]:
            return {"end": f"Reader stopped at chunk {r['quit_at']}/{len(self.chunks)}. "
                           "That stop point is the primary finding."}
        return {"end": "Final reaction recorded. Session complete."}

    def progress(self):
        return {r["name"]: {"chunk": min(r["cursor"] + 1, len(self.chunks)), "of": len(self.chunks),
                            "started": r["started"] is not None, "done": r["done"],
                            "quit_at": r["quit_at"]} for r in self.readers.values()}

    def _maybe_finish(self):
        if all(r["done"] for r in self.readers.values()):
            self.flush()

    def flush(self):
        # only now does the text touch disk: every reader is finished
        for r in self.readers.values():
            state = {"draft": "(served)", "persona": r["persona"], "chunks": self.chunks,
                     "cursor": r["cursor"], "done": r["done"], "quit_at": r["quit_at"],
                     "started": r["started"] or time.time()}
            (self.run_dir / r["name"] / "state.json").write_text(json.dumps(state, indent=2))
        self.closed = True


class Handler(BaseHTTPRequestHandler):
    feed = None
    server_ref = None

    def log_message(self, *a):  # quiet
        pass

    def _send(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _route(self, method):
        parts = [p for p in self.path.split("?")[0].split("/") if p]
        if len(parts) != 2:
            return self._send(404, {"error": "not found"})
        token, action = parts
        body = {}
        if method == "POST":
            n = int(self.headers.get("Content-Length") or 0)
            if n:
                try:
                    body = json.loads(self.rfile.read(n) or b"{}")
                except json.JSONDecodeError:
                    body = {}
        f = self.feed
        with f.lock:
            if token == f.admin:
                if action == "progress":
                    return self._send(200, f.progress())
                if action == "close":
                    f.flush()
                    self._send(200, {"ok": True, "closed": True})
                    threading.Thread(target=self.server_ref.shutdown, daemon=True).start()
                    return
                return self._send(404, {"error": "not found"})
            r = f.readers.get(token)
            if r is None:
                return self._send(404, {"error": "not found"})
            if action == "start" and method == "GET":
                return self._send(200, f.start(r))
            if action == "next" and method == "POST":
                return self._send(200, f.next(r, body.get("log")))
            if action == "quit" and method == "POST":
                return self._send(200, f.quit(r, body.get("log")))
            return self._send(404, {"error": "not found"})

    def do_GET(self):
        self._route("GET")

    def do_POST(self):
        self._route("POST")


def cmd_serve(args):
    names = [n.strip() for n in args.readers.split(",") if n.strip()]
    titles = {}
    for spec in (args.persona or []):
        if "=" in spec:
            k, v = spec.split("=", 1); titles[k.strip()] = v.strip()
    feed = Feed(args.draft, args.run, names, titles, args.dwell)
    httpd = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    Handler.feed = feed
    Handler.server_ref = httpd
    port = httpd.server_address[1]
    base = f"http://127.0.0.1:{port}"
    print(f"FEED serving {len(feed.chunks)} passages, {feed.words} words, readers: {', '.join(names)}")
    for token, r in feed.readers.items():
        print(f"reader {r['name']}: READER_FEED={base}/{token}")
    print(f"admin: {base}/{feed.admin}")
    print("Give each reader ONLY its own READER_FEED line. Nothing else about the piece.", flush=True)
    if args.ready_file:
        Path(args.ready_file).write_text(json.dumps(
            {"base": base, "admin": f"{base}/{feed.admin}",
             "readers": {r["name"]: f"{base}/{t}" for t, r in feed.readers.items()}}))

    def watchdog():
        while True:
            time.sleep(5)
            if feed.closed:
                # every reader is done, but the last one may still be sending
                # its final reaction: stay up until things go quiet
                last = max([r["served_at"] or 0 for r in feed.readers.values()] + [0])
                if time.time() - last > 90:
                    httpd.shutdown(); return
                continue
            anyone_started = any(r["started"] is not None for r in feed.readers.values())
            if args.idle and anyone_started:
                last = max(r["served_at"] or 0 for r in feed.readers.values())
                if last and time.time() - last > args.idle:
                    with feed.lock:
                        feed.flush()
                    httpd.shutdown(); return
    threading.Thread(target=watchdog, daemon=True).start()
    try:
        httpd.serve_forever()
    finally:
        if not feed.closed:
            with feed.lock:
                feed.flush()


def _call(base, action, payload=None):
    url = base.rstrip("/") + "/" + action
    data = json.dumps(payload).encode() if payload is not None else None
    req = urlrequest.Request(url, data=data, method="POST" if data is not None else "GET",
                             headers={"Content-Type": "application/json"})
    try:
        with urlrequest.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except HTTPError as e:
        sys.exit(f"feed error: {e.code} (wrong READER_FEED address or the feed has closed)")
    except OSError as e:
        sys.exit(f"feed unreachable at {base}: {e}. Is the feed still running?")


def _print_served(res):
    if "refused" in res:
        sys.exit("REFUSED: " + res["refused"])
    if "error" in res:
        sys.exit(res["error"])
    if "briefing" in res:
        print(res["briefing"])
    if "end" in res:
        print(res["end"]); return
    print(res["header"]); print(res["text"]); print(res["footer"])


def served_base(args):
    return getattr(args, "feed", None) or os.environ.get("READER_FEED")


# ------------------------------------------------------------------ file mode

def load(session):
    d = Path(session)
    state = json.loads((d / "state.json").read_text())
    return d, state


def save(d, state):
    (d / "state.json").write_text(json.dumps(state, indent=2))


def show(state, i):
    chunks = state["chunks"]
    print(chunk_header(i, chunks))
    print(chunks[i])
    print(chunk_footer())


def cmd_start(args):
    base = served_base(args)
    if base:
        return _print_served(_call(base, "start"))
    if not args.draft or not args.session:
        sys.exit("file mode needs: feed.py start <draft> --session <dir>  (or set READER_FEED)")
    d = Path(args.session); d.mkdir(parents=True, exist_ok=True)
    text = Path(args.draft).read_text(encoding="utf-8")
    chunks = chunk(text)
    state = {"draft": str(args.draft), "persona": args.persona or "unnamed",
             "chunks": chunks, "cursor": 0, "done": False, "started": time.time()}
    save(d, state)
    (d / "log.jsonl").write_text("")
    print(f"SESSION {d} | persona: {state['persona']} | {len(chunks)} chunks, "
          f"{nwords(text)} words total")
    print(BRIEFING)
    show(state, 0)


def record(d, state, entry, quit_=False):
    if len(entry.strip()) < MIN_LOG_CHARS:
        sys.exit(f"REFUSED: log entry under {MIN_LOG_CHARS} chars. What happened "
                 "in you during that chunk? needle=?, expected what, got what?")
    with (d / "log.jsonl").open("a") as f:
        f.write(json.dumps({"chunk": state["cursor"] + 1, "quit": quit_,
                            "entry": entry.strip(), "t": time.time()}) + "\n")


def _session_or_die(args):
    if not args.session:
        sys.exit("file mode needs the session dir: feed.py next <dir> --log ...  (or set READER_FEED)")


def cmd_next(args):
    base = served_base(args)
    if base:
        return _print_served(_call(base, "next", {"log": args.log}))
    _session_or_die(args)
    d, state = load(args.session)
    if state["done"]:
        sys.exit("Session already finished.")
    record(d, state, args.log)
    state["cursor"] += 1
    if state["cursor"] >= len(state["chunks"]):
        state["done"] = True; save(d, state)
        print("END OF PIECE. The reader finished. Add one final log line for the "
              "ending itself via: feed.py quit <session> --log \"final: ...\"")
        return
    save(d, state)
    show(state, state["cursor"])


def cmd_quit(args):
    base = served_base(args)
    if base:
        return _print_served(_call(base, "quit", {"log": args.log}))
    _session_or_die(args)
    d, state = load(args.session)
    finished = state["done"] or state["cursor"] >= len(state["chunks"]) - 1
    record(d, state, args.log, quit_=not finished)
    state["done"] = True
    state["quit_at"] = None if finished else state["cursor"] + 1
    save(d, state)
    if state["quit_at"]:
        print(f"Reader stopped at chunk {state['quit_at']}/{len(state['chunks'])}. "
              "That stop point is the primary finding.")
    else:
        print("Final reaction recorded. Session complete.")


def cmd_transcript(args):
    d, state = load(args.session)
    print(f"READING TRANSCRIPT | persona: {state['persona']} | "
          f"{'finished' if not state.get('quit_at') else 'QUIT at chunk %s' % state['quit_at']}"
          f" of {len(state['chunks'])} chunks")
    entries = [json.loads(l) for l in (d / "log.jsonl").read_text().splitlines() if l.strip()]
    for i, e in enumerate(entries):
        final = (i == len(entries) - 1 and state["done"] and not state.get("quit_at"))
        mark = "QUIT " if e["quit"] else ("FINAL " if final else "")
        print(f"[chunk {e['chunk']}] {mark}{e['entry']}")


def cmd_status(args):
    d, state = load(args.session)
    print(f"persona={state['persona']} "
          f"cursor={min(state['cursor'] + 1, len(state['chunks']))}/"
          f"{len(state['chunks'])} done={state['done']} quit_at={state.get('quit_at')}")


def cmd_progress(args):
    print(json.dumps(_call(args.admin, "progress"), indent=2))


def cmd_close(args):
    print(json.dumps(_call(args.admin, "close")))


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("serve"); s.add_argument("draft"); s.add_argument("--run", required=True)
    s.add_argument("--readers", required=True, help="comma-separated reader names")
    s.add_argument("--persona", action="append", help="name=one-line persona (repeatable)")
    s.add_argument("--port", type=int, default=0)
    s.add_argument("--dwell", type=float, default=0.08,
                   help="seconds per word a reader must spend on a passage before advancing; 0 disables")
    s.add_argument("--idle", type=float, default=1800, help="close after this many idle seconds")
    s.add_argument("--ready-file", help="write addresses as JSON here for the orchestrator")
    s = sub.add_parser("start"); s.add_argument("draft", nargs="?"); s.add_argument("--session"); s.add_argument("--persona"); s.add_argument("--feed")
    for name in ("next", "quit"):
        s = sub.add_parser(name); s.add_argument("session", nargs="?"); s.add_argument("--log", required=True); s.add_argument("--feed")
    for name in ("transcript", "status"):
        s = sub.add_parser(name); s.add_argument("session")
    for name in ("progress", "close"):
        s = sub.add_parser(name); s.add_argument("--admin", required=True)
    args = p.parse_args()
    {"serve": cmd_serve, "start": cmd_start, "next": cmd_next, "quit": cmd_quit,
     "transcript": cmd_transcript, "status": cmd_status,
     "progress": cmd_progress, "close": cmd_close}[args.cmd](args)


if __name__ == "__main__":
    main()
