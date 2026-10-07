#!/usr/bin/env python3
"""Consult a reader after the run: they answer in character, from their own log.

A real beta reader can be asked follow-ups: "what would have convinced
you?", "where exactly did you check out?", "did you notice the retention
example?" This script packages one reader's persona and moment-by-moment
log with the author's question so a fresh agent can answer AS that reader,
grounded in what actually happened to them during the read, and nothing
else. The draft is never included: like a person the next day, the reader
has their memory of the experience, not the text.

Usage:
  python3 ask.py <run-dir> <reader> "<question>"     one reader (session dir name)
  python3 ask.py <run-dir> skim "<question>"         the skim-gate reader
  python3 ask.py <run-dir> all "<question>"          every reader, one bundle each

Hand each printed bundle to a fresh subagent and relay its answer in the
reader's voice. Readers stay honest: an answer the log cannot support is
"I can't say; I didn't note it at the time."
"""
import json
import sys
from pathlib import Path


def bundle(run, name, question):
    d = Path(run) / name
    if name == "skim":
        note = Path(run) / "skim.txt"
        if not note.exists():
            return None
        return (f"You are the reader who skimmed this piece and decided whether to open it. You saw only the "
                f"scanner's view (headings, first lines, numbers, links), never the full text, and you still have not "
                f"read it. This is what you said at the time:\n\n{note.read_text().strip()}\n\n"
                f"The author asks you: {question}\n\nAnswer in your own voice, in under 120 words, from that decision "
                f"and nothing else. If you would need to have read the piece to answer, say so.")
    if not (d / "state.json").exists():
        return None
    state = json.loads((d / "state.json").read_text())
    entries = [json.loads(l) for l in (d / "log.jsonl").read_text().splitlines() if l.strip()]
    log = "\n".join(f"[passage {e['chunk']}] {'QUIT ' if e.get('quit') else ''}{e['entry']}" for e in entries)
    how = ("stopped at passage %s of %s" % (state["quit_at"], len(state["chunks"]))) if state.get("quit_at") \
        else "finished all %s passages" % len(state["chunks"])
    return (f"You are {state['persona']}. Earlier today you read a piece one passage at a time and {how}. "
            f"You no longer have the text; you have your memory of reading it, which is exactly the notes you kept "
            f"as you went:\n\n{log}\n\nThe author asks you: {question}\n\n"
            f"Answer as yourself, in under 150 words, grounded only in what you noted at the time. Quote your own "
            f"notes where they answer it. Do not invent details of the text you did not note. If the log does not "
            f"support an answer, say 'I can't say; I didn't note it at the time.' Never suggest rewrites; say what "
            f"happened to you and what would have had to be true for it to go differently.")


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    run, who, question = sys.argv[1], sys.argv[2], sys.argv[3]
    names = [who]
    if who == "all":
        names = sorted(p.name for p in Path(run).iterdir() if (p / "state.json").exists())
        if (Path(run) / "skim.txt").exists():
            names.append("skim")
    out = []
    for n in names:
        b = bundle(run, n, question)
        if b is None:
            sys.exit(f"no reader '{n}' under {run}")
        out.append(f"===== reader: {n} =====\n{b}")
    print("\n\n".join(out))


if __name__ == "__main__":
    main()
