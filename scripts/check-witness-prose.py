#!/usr/bin/env python3
"""Check that the words in each `tex` witness occur in the paper. Advisory.

A witness holds the paper's own sentences, hand-transcribed, because there is
no LaTeX source to copy from (`AGENTS.md`, "No TeX source"). Whether a witness
*says what the paper says at that point* is a review item and stays one: this
script cannot judge a transcription, only catch a word that is not in the paper
at all, which is what a typo or an invented clause looks like.

Method: strip TeX commands and environments, keep words of four letters or more
-- so single-letter variable names and short glue words drop out along with the
maths -- and check that every window of four consecutive such words occurs
somewhere in `pdftotext` output of the paper.

Unmatched windows are usually *seams*, not errors: a witness that joins two
separated pieces of the paper produces one unmatched window at the join. Every
such seam should be named in its chapter's leading comment, since it is a
departure from the paper's order. Read what this prints as a list of places to
have documented, not a list of defects.

Needs `source/paper.txt`, which is gitignored, so this is skipped rather than
failed when the paper is not present -- in CI, it always is.

    python3 scripts/check-witness-prose.py
    python3 scripts/check-witness-prose.py --strict   # exit 1 on any unmatched window
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAPER = ROOT / "source" / "paper.txt"
CHAPTERS = ROOT / "BodyPinBlueprint" / "Chapters"

WITNESS = re.compile(r'^```tex "([^"]+)"[^\n]*\n(.*?)^```$', re.M | re.S)
TEX = re.compile(r"\\begin\{[^}]*\}|\\end\{[^}]*\}|\\[a-zA-Z]+")
WINDOW = 4


def content_words(text: str) -> list[str]:
    return [w.lower() for w in re.findall(r"[A-Za-z]{4,}", text)]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    if not PAPER.exists():
        print("source/paper.txt is not present; skipping the witness prose check")
        print("(run: bash ./scripts/check-source.sh)")
        return 0

    paper = " ".join(content_words(PAPER.read_text(encoding="utf-8")))
    total = 0
    for path in sorted(CHAPTERS.glob("*.lean")):
        for label, body in WITNESS.findall(path.read_text(encoding="utf-8")):
            words = content_words(TEX.sub(" ", body))
            unmatched = [
                " ".join(words[i:i + WINDOW])
                for i in range(len(words) - WINDOW + 1)
                if " ".join(words[i:i + WINDOW]) not in paper
            ]
            if unmatched:
                total += len(unmatched)
                print(f"{path.relative_to(ROOT)}: {label}: "
                      f"{len(unmatched)} window(s) not found in the paper")
                for window in unmatched[:4]:
                    print(f"    {window}")

    print(f"\n{total} unmatched window(s). Each is a seam to document or a word to re-read; "
          "see the docstring.")
    return 1 if (args.strict and total) else 0


if __name__ == "__main__":
    raise SystemExit(main())
