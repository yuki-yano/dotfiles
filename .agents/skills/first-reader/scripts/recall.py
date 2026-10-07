#!/usr/bin/env python3
"""Build the recall quiz: what survived the reading, tested honestly.

Humans keep gist, not sentences; verbatim memory collapses within seconds
of continued reading. An agent with the draft in context has perfect
verbatim memory, so asking it "what do you remember" is theater. The
honest experiment: hand a FRESH agent only the reading transcript (the
moment log a reader produced during the timed read) and quiz it. What made
it into the log is what registered during reading; what the fresh agent
can reconstruct from the log is the gist that would survive a commute.

Usage: python3 recall.py <session-dir>
Prints the transcript plus the quiz. Contains no draft text beyond what
the reader chose to quote in their own log, which is exactly the point.
"""
import json
import sys
from pathlib import Path


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    d = Path(sys.argv[1])
    state = json.loads((d / "state.json").read_text())
    print("You are answering for a reader who read a piece once, earlier today, "
          "and no longer has it. Below is the moment-by-moment log they kept "
          "while reading. You have nothing else. Answer only from this log; "
          "if the log does not support an answer, say 'nothing survived'.")
    print(f"\npersona: {state['persona']} | "
          f"{'finished the piece' if not state.get('quit_at') else 'quit at chunk %s of %s' % (state['quit_at'], len(state['chunks']))}")
    print("-" * 60)
    for line in (d / "log.jsonl").read_text().splitlines():
        e = json.loads(line)
        print(f"[chunk {e['chunk']}] {'QUIT ' if e['quit'] else ''}{e['entry']}")
    print("-" * 60)
    print("""QUIZ (answer from the log alone):
1. SAYBACK: retell the piece in one sentence, as you'd describe it to a
   colleague. If you can't, say so; that is a finding, not a failure.
2. POINTING: quote any exact words or phrases that stuck. Only what the
   log actually preserved counts.
3. PEAK: the single strongest moment of the read, and why.
4. ENDING: how it ended and how that felt. 'I don't remember the ending'
   is a valid and important answer.
5. CENTER OF GRAVITY: where did the piece feel most alive? Is that the
   same thing the piece claimed to be about?
6. ONE ACTION: is there anything you would now do, check, or tell someone
   because you read this?""")


if __name__ == "__main__":
    main()
