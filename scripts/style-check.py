#!/usr/bin/env python3
"""Grep blueprint prose for the register tells listed in BodyPinBlueprint/STYLE.md.

Advisory. It matches strings, not sentences, so it cannot tell a real lapse from
a legitimate use -- "the bridge between two bodies" would be a false positive.
A *new* hit is worth a second look; a hit that is correct can stay.

Scans only rendered prose: the body of each `#doc`, minus `tex` witness blocks
(which quote the paper and are not ours to restyle) and minus node metadata.

    python3 scripts/style-check.py              # report, exit 0
    python3 scripts/style-check.py --strict     # exit 1 if anything is found
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

TELLS: list[tuple[str, str]] = [
    ("mission statement", r"\b(this blueprint (exists|is for)|job of this blueprint|the (first|whole) job|the deliverable)\b"),
    ("'what X buys'", r"\bbuys?\b"),
    ("rhetorical closer", r"\b(is the point|which is the point|that is the point)\b"),
    ("metaphor", r"\b(seams?|bridge between|engine of|the spine|depth dial|on-ramps?|escape hatch)\b"),
    ("telling the reader what matters", r"\b(worth (knowing|keeping|noting|having)|crucially|the key point|note the significance|importantly)\b"),
    ("Lean as an agent", r"\bLean (keeps|follows|makes|proves|indexes|does|uses|has|takes|needs|carries|chooses|prefers)\b"),
    ("defensive framing", r"\b(not a workaround|far from|it is no accident)\b"),
    ("filler", r"\b(simply|just|obviously|of course|it is worth noting)\b"),
    ("second person", r"\byou\b"),
    # Real contractions only. Possessive `'s` -- "the paper's", "Zheng's" -- is
    # correct English and must not be flagged, so this is a fixed list rather
    # than an apostrophe pattern.
    ("contraction", r"\b(it's|isn't|aren't|wasn't|weren't|don't|doesn't|didn't|can't|won't|"
                    r"couldn't|shouldn't|wouldn't|haven't|hasn't|hadn't|we'(?:ll|ve|re|d)|"
                    r"they'(?:ll|ve|re|d)|that's|there's|here's|let's)\b"),
]

EM_DASH_LIMIT = 3   # a matched pair framing one aside is fine; three is a pile-up


def prose(path: Path) -> str:
    body = path.read_text(encoding="utf-8").partition("#doc")[2]
    body = re.sub(r"```.*?```", "", body, flags=re.S)          # code and witnesses
    body = re.sub(r"^:::\w+.*$", "", body, flags=re.M)          # directive headers
    return body


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", type=Path)
    ap.add_argument("--strict", action="store_true", help="exit 1 when hits are found")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    paths = args.paths or [root / "BodyPinBlueprint.lean", *sorted((root / "BodyPinBlueprint/Chapters").glob("*.lean"))]

    total = 0
    for path in paths:
        text = prose(path)
        for para in text.split("\n\n"):
            if any(l.lstrip().startswith(("-", "|")) for l in para.splitlines()):
                continue                    # list or table: the dash is a separator
            n = para.count("\u2014")
            if n >= EM_DASH_LIMIT:
                rel = path.relative_to(root) if path.is_absolute() else path
                print(f"{rel}: {n} em dashes in one paragraph: ...{' '.join(para.split())[:90]}...")
                total += 1
        for label, pattern in TELLS:
            for m in re.finditer(pattern, text, re.I):
                line = text[: m.start()].count("\n") + 1
                ctx = " ".join(text[max(0, m.start() - 60) : m.start() + 70].split())
                rel = path.relative_to(root) if path.is_absolute() else path
                print(f"{rel}: {label}: ...{ctx}...")
                total += 1

    print(f"\n{total} possible register issue(s). See BodyPinBlueprint/STYLE.md.")
    return 1 if (args.strict and total) else 0


if __name__ == "__main__":
    raise SystemExit(main())
