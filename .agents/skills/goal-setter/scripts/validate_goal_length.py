#!/usr/bin/env python3
"""Validate a /goal condition against the real runtime length limits.

Both runtimes accept at most 4,000 "characters" but count differently
(verified against Codex source and Claude Code 2.1.173):

  * Codex counts Unicode codepoints of the trimmed objective
    (``validate_thread_goal_objective``: ``value.chars().count() > 4_000``).
  * Claude Code counts UTF-16 code units (JavaScript ``String.length``),
    so astral characters — emoji, rare CJK ideographs — count as 2.

Exactly 4,000 passes in both; 4,001 fails. Japanese and other BMP text
counts 1 per character in both runtimes.

This script reports both counts and fails when the stricter one (UTF-16
code units) exceeds the cap, so a passing goal is safe to activate on
either runtime. Pass ``--runtime codex`` to enforce only the codepoint
count.

Validate once: if the goal passes, activate it. Do not loop on small
trims to chase a lower number. If it fails, restructure (cut clauses or
move durable detail to sidecars) instead of shaving characters.

Input may be a file path or stdin, and may include a surrounding code
fence and/or the leading ``/goal `` prefix; both are stripped before
counting, matching what the runtimes validate.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

HARD_CAP = 4000


def extract_objective(text: str) -> str:
    text = text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].strip().startswith("```"):
            lines = lines[:-1]
        text = "\n".join(lines).strip()
    if text.startswith("/goal") and (len(text) == 5 or text[5] in (" ", "\t", "\n")):
        text = text[5:].strip()
    return text


def utf16_units(text: str) -> int:
    return sum(2 if ord(ch) > 0xFFFF else 1 for ch in text)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Validate /goal condition length.")
    parser.add_argument("file", nargs="?", help="File containing the goal condition. Reads stdin when omitted.")
    parser.add_argument(
        "--runtime",
        choices=["both", "codex", "claude-code"],
        default="both",
        help="Which runtime's counting rule to enforce (default: both, i.e. the stricter count).",
    )
    parser.add_argument(
        "--max-chars",
        type=int,
        default=HARD_CAP,
        help=f"Hard cap (default {HARD_CAP}, the runtime limit; both runtimes allow exactly this count).",
    )
    args = parser.parse_args(argv)

    raw = Path(args.file).read_text(encoding="utf-8") if args.file else sys.stdin.read()
    objective = extract_objective(raw)

    codepoints = len(objective)
    units = utf16_units(objective)
    print(f"codepoints={codepoints}")
    print(f"utf16_units={units}")
    print(f"max={args.max_chars}")

    if not objective:
        print("FAIL: goal condition is empty after stripping fences and the /goal prefix.")
        return 1

    if args.runtime == "codex":
        enforced = codepoints
    elif args.runtime == "claude-code":
        enforced = units
    else:
        enforced = max(codepoints, units)

    if enforced > args.max_chars:
        print(f"FAIL: {enforced} > {args.max_chars}. Restructure the goal (cut clauses or move durable detail to sidecars); do not loop on small trims.")
        return 1

    print("PASS: activate it; do not keep shortening.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
