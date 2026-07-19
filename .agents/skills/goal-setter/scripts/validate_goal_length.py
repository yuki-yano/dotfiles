#!/usr/bin/env python3
"""ランタイムの上限に照らして /goal の文字数を検証する。

Codex と Claude Code は最大 4,000 文字を受け付けるが、数え方が異なる。

  * Codex は前後の空白を除いた目的の Unicode code point 数を数える。
  * Claude Code は JavaScript の ``String.length`` と同じ UTF-16 code unit 数を
    数えるため、絵文字や一部の CJK 文字は 2 と数える。

両ランタイムとも 4,000 は合格し、4,001 は失敗する。このスクリプトは両方の
件数を表示し、既定では厳しい方が上限を超えた場合に失敗する。
Codex の code point 数だけを検証する場合は ``--runtime codex`` を指定する。

検証は一度だけ行う。
合格後に文字数を減らすためだけの反復はしない。
失敗した場合は細かな字句削減を繰り返さず、句の削除や責務の分離で構成を直す。

入力にはファイルまたは標準入力を使える。コードフェンスと先頭の ``/goal`` は、
ランタイムの検証対象に合わせて文字数を数える前に除去する。
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
    parser = argparse.ArgumentParser(description="/goal の文字数を検証する。")
    parser.add_argument("file", nargs="?", help="Goal を含むファイル。省略時は標準入力から読む。")
    parser.add_argument(
        "--runtime",
        choices=["both", "codex", "claude-code"],
        default="both",
        help="適用するランタイムの数え方。既定値は both（厳しい方）を使う。",
    )
    parser.add_argument(
        "--max-chars",
        type=int,
        default=HARD_CAP,
        help=f"上限値。既定値はランタイム上限の {HARD_CAP}。",
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
        print("FAIL: コードフェンスと /goal 接頭辞を除くと Goal が空です。")
        return 1

    if args.runtime == "codex":
        enforced = codepoints
    elif args.runtime == "claude-code":
        enforced = units
    else:
        enforced = max(codepoints, units)

    if enforced > args.max_chars:
        print(f"FAIL: {enforced} > {args.max_chars}。細かな字句削減を繰り返さず、不要な句の削除や責務の分離で Goal を組み直してください。")
        return 1

    print("PASS: 上限内です。文字数を減らすためだけの修正は不要です。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
