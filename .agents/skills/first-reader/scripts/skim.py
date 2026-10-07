#!/usr/bin/env python3
"""Produce the scanner's view of a draft: what a skimming reader actually
fixates on, and nothing else.

Eyetracking work (Nielsen Norman Group) shows scanners fixate on headings,
the first words of lines and paragraphs, bold spans, numbers, and links,
and skip nearly everything else. This prints exactly that view so a fresh
reader agent can answer the only question a scanner answers: what is this,
and do I commit? Feeding the full text would break the experiment, so this
script deliberately truncates.

Usage: python3 skim.py <draft.md|draft.txt>
"""
import re
import sys
from pathlib import Path

WPM = 238  # average adult silent reading speed (Brysbaert 2019 meta-analysis)
MOBILE_CHARS_PER_LINE = 38
MOBILE_LINES_PER_SCREEN = 14
FIRST_WORDS = 9


def paragraphs(text):
    return [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]


def first_sentence(p):
    m = re.match(r".+?[.!?](?=\s|$)", p, re.S)
    return (m.group(0) if m else p).replace("\n", " ")


def first_words(p, n=FIRST_WORDS):
    words = p.replace("\n", " ").split()
    if len(words) <= n:
        return " ".join(words)
    return " ".join(words[:n]) + " ..."


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    text = Path(sys.argv[1]).read_text(encoding="utf-8")
    paras = paragraphs(text)
    words = len(text.split())
    bold = re.findall(r"\*\*(.+?)\*\*|__(.+?)__", text)
    bold = [a or b for a, b in bold]
    links = re.findall(r"\[([^\]]+)\]\(", text)
    numbers = re.findall(
        r"(?<![\w./-])(?:\$[\d,.]+[kKmMbB]?|\d+(?:[.,]\d+)*%?|\d{4})(?![\w/-])", text
    )
    screens = max(1, round(len(text) / (MOBILE_CHARS_PER_LINE * MOBILE_LINES_PER_SCREEN)))

    print("SCANNER VIEW (what a skimming reader fixates on; the full text is withheld)")
    print(f"stats: {words} words | ~{max(1, round(words / WPM))} min full read | ~{screens} phone screens")
    print(f"fixation tokens: numbers={numbers[:20] if numbers else 'NONE'}")
    if bold:
        print(f"bold spans: {[b[:60] for b in bold[:12]]}")
    if links:
        print(f"link texts: {links[:12]}")
    print("-" * 60)
    body_count = 0
    for p in paras:
        if re.match(r"#{1,6}\s", p):
            print(p.splitlines()[0])
            continue
        if p.startswith(("- ", "* ", "1.", "> ")):
            for line in p.splitlines()[:6]:
                print("  " + first_words(line.lstrip("->*1234567890. ")))
            continue
        body_count += 1
        if body_count <= 2:
            # A scanner does genuinely read the opening lines in full.
            print(first_sentence(p))
        else:
            print(first_words(p))
    print("-" * 60)
    print(
        "Question for the reader: from this view alone, say (1) what you think "
        "this piece is and what it will argue, (2) whether your cast persona "
        "commits to a full read or moves on, and (3) the single element above "
        "that decided it."
    )


if __name__ == "__main__":
    main()
