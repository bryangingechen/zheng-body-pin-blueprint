#!/usr/bin/env python3
"""Grep blueprint prose for the register tells listed in BodyPinBlueprint/STYLE.md.

Two severities, because two different things are being checked.

`error` is for the two constructions the guide bans outright -- *X is what makes
Y* and *X is where Y happens*. They were counted 28 times across this document
and zero times in 66,000 words of the paper and its four reference papers, and
a plain rewrite exists in every case. `--strict` exits 1 on one of these, and
`checks.sh` passes `--strict`.

`warn` is everything else: idiom, proof-engineering vocabulary, headings that
read as sentences. Those match strings, not sentences, so a hit is sometimes
correct -- "the bridge between two bodies" would be a false positive. A *new*
warning is worth a second look; a warning that is correct can stay.

Scans only rendered prose: the body of each `#doc`, minus `tex` witness blocks
(which quote the paper and are not ours to restyle) and minus node metadata.

    python3 scripts/style-check.py              # report, exit 0
    python3 scripts/style-check.py --strict     # exit 1 on any `error`
    python3 scripts/style-check.py --pedantic   # exit 1 on any hit at all
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# (severity, label, pattern)
TELLS: list[tuple[str, str, str]] = [
    # -- Banned outright.  See STYLE.md, "The habit to break".  Both wrap a
    # plain predication in a frame that announces the fact instead of asserting
    # it, and both are always removable.  The pattern does not match an
    # ordinary locative ("the entry is in the register"), only the copula.
    ("error", "role-naming: 'X is what ...' (state the fact; make X the subject)",
     r"\b(is|are|was|were)\s+what\b"),
    ("error", "role-naming: 'X is where ...' (say what happens, and where)",
     r"\b(is|are|was|were)\s+where\b"),

    # -- Register.
    ("warn", "mission statement", r"\b(this blueprint (exists|is for)|job of this blueprint|the (first|whole) job|the deliverable)\b"),
    ("warn", "'what X buys'", r"\bbuys?\b"),
    ("warn", "rhetorical closer", r"\b(is the point|which is the point|that is the point)\b"),
    ("warn", "metaphor", r"\b(seams?|bridge between|engine of|the spine|depth dial|on-ramps?|escape hatch)\b"),
    # Colloquial idiom.  Every one of these was written here and removed; none
    # occurs anywhere in the paper or its references.
    ("warn", "colloquial idiom",
     r"\b(earns? (its|their) place|part company|put to work|on the nose|for free|"
     r"waves? through|does one thing|headline)\b"),
    ("warn", "telling the reader what matters",
     r"\b(worth (knowing|keeping|noting|having|watching)|crucially|the key point|"
     r"note the significance|importantly)\b"),
    # Proof-engineering vocabulary standing in for mathematics.  Legitimate when
    # the subject really is the Lean development -- but then name the module,
    # the declaration or the hypothesis, not the caller.
    ("warn", "proof-engineering idiom (would a mathematician read this for the argument?)",
     r"\b(call sites?|callers?|branches on|case split|excluded middle|stored tag|"
     r"plumbing|boilerplate|discharges?|closes? the [a-z-]+ branch)\b"),
    ("warn", "Lean as an agent", r"\bLean (keeps|follows|makes|proves|indexes|does|uses|has|takes|needs|carries|chooses|prefers)\b"),
    ("warn", "defensive framing", r"\b(not a workaround|far from|it is no accident)\b"),
    ("warn", "filler", r"\b(simply|just|obviously|of course|it is worth noting)\b"),
    ("warn", "second person", r"\byou\b"),
    # Real contractions only. Possessive `'s` -- "the paper's", "Zheng's" -- is
    # correct English and must not be flagged, so this is a fixed list rather
    # than an apostrophe pattern.
    ("warn", "contraction",
     r"\b(it's|isn't|aren't|wasn't|weren't|don't|doesn't|didn't|can't|won't|"
     r"couldn't|shouldn't|wouldn't|haven't|hasn't|hadn't|we'(?:ll|ve|re|d)|"
     r"they'(?:ll|ve|re|d)|that's|there's|here's|let's)\b"),
]

EM_DASH_LIMIT = 3   # a matched pair framing one aside is fine; three is a pile-up

# A heading names a subject; it does not make a statement about one.  A finite
# verb in one is the reliable sign that it wants a full stop -- "The construction
# theorem the formalization carries".  Participles and gerunds are fine
# ("Deleting one vertex", "Assembling the body-pin theorem"), so they are absent
# from this list.
HEADING_VERBS = re.compile(
    r"\b(is|are|was|were|has|have|had|does|do|did|can|will|should|must|may|"
    r"carries|carry|uses|use|needs|need|makes|make|gives|give|shows|show|"
    r"proves|prove|holds|hold|follows|follow|requires|require|provides|provide|"
    r"becomes|become|takes|take|says|say)\b",
    re.I,
)


def prose(path: Path) -> str:
    body = path.read_text(encoding="utf-8").partition("#doc")[2]
    body = re.sub(r"```.*?```", "", body, flags=re.S)          # code and witnesses
    body = re.sub(r"^:::\w+.*$", "", body, flags=re.M)          # directive headers
    return body


def headings(path: Path) -> list[tuple[int, str]]:
    """Section headings and the document title, with 1-based line numbers."""
    out: list[tuple[int, str]] = []
    seen_doc = False
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if line.startswith("#doc"):
            seen_doc = True
            if m := re.search(r'#doc\s*\(\w+\)\s*"([^"]*)"', line):
                out.append((i, m.group(1)))
            continue
        if seen_doc and line.startswith("# "):
            out.append((i, line[2:].strip()))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", type=Path)
    ap.add_argument("--strict", action="store_true", help="exit 1 on any error-level hit")
    ap.add_argument("--pedantic", action="store_true", help="exit 1 on any hit at all")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    paths = args.paths or [root / "BodyPinBlueprint.lean", *sorted((root / "BodyPinBlueprint/Chapters").glob("*.lean"))]

    errors = warns = 0
    for path in paths:
        rel = path.relative_to(root) if path.is_relative_to(root) else path
        text = prose(path)

        for para in text.split("\n\n"):
            if any(l.lstrip().startswith(("-", "|")) for l in para.splitlines()):
                continue                    # list or table: the dash is a separator
            n = para.count("\u2014")
            if n >= EM_DASH_LIMIT:
                print(f"{rel}: warn: {n} em dashes in one paragraph: ...{' '.join(para.split())[:90]}...")
                warns += 1

        for line, title in headings(path):
            if m := HEADING_VERBS.search(title):
                print(f"{rel}:{line}: warn: heading reads as a sentence "
                      f"(finite verb {m.group(0)!r}): {title!r}")
                warns += 1

        for severity, label, pattern in TELLS:
            for m in re.finditer(pattern, text, re.I):
                ctx = " ".join(text[max(0, m.start() - 60) : m.start() + 70].split())
                print(f"{rel}: {severity}: {label}: ...{ctx}...")
                if severity == "error":
                    errors += 1
                else:
                    warns += 1

    total = errors + warns
    print(f"\n{errors} error(s), {warns} warning(s). See BodyPinBlueprint/STYLE.md.")
    if args.pedantic and total:
        return 1
    if args.strict and errors:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
