#!/usr/bin/env python3
"""Grep blueprint prose for the register tells listed in BodyPinBlueprint/STYLE.md.

Two severities, because two different things are being checked.

`error` is for the two constructions the guide bans outright -- *X is what makes
Y* and *X is where Y happens*. They were counted 28 times across this document
and zero times in the 50,748 words of the four human-written reference papers,
and a plain rewrite exists in every case. `--strict` exits 1 on one of these,
and `checks.sh` passes `--strict`.

`warn` is everything else: idiom, proof-engineering vocabulary, the synonyms the
banned constructions migrated into, headings that read as sentences. Those match
strings, not sentences, so a hit is sometimes correct -- "the bridge between two
bodies" would be a false positive. A *new* warning is worth a second look; a
warning that is correct can stay. A warning family that reaches zero legitimate
uses across the document gets promoted to an error.

`--report` prints per-chapter register metrics -- sentence-length distribution,
connective and signposting densities -- against baselines measured over the
human-written references only (`source/references/*.txt`; `source/paper.txt` is
machine-written and is the authority on content, not register -- see STYLE.md,
"Two sources, two authorities"). The report never gates.

Scans only rendered prose: the body of each `#doc`, minus `tex` witness blocks
(which quote the paper and are not ours to restyle) and minus node metadata.
Inline math and code are collapsed to one-token placeholders, so tells cannot
match inside them and each counts as one word in the sentence statistics.

    python3 scripts/style-check.py              # report tells, exit 0
    python3 scripts/style-check.py --report     # register metrics, exit 0
    python3 scripts/style-check.py --strict     # exit 1 on any `error`
    python3 scripts/style-check.py --pedantic   # exit 1 on any hit at all
"""
from __future__ import annotations

import argparse
import re
import statistics
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

    # -- The synonyms the two bans migrated into.  Same move, same fix; warnings
    # while the rewrite is in progress (STYLE.md, "The habit to break").
    ("warn", "dodged role-naming: 'X exists to do Y'", r"\bexists? to\b"),
    ("warn", "dodged role-naming: 'X is how Y is done'", r"\b(is|are) how\b"),
    ("warn", "dodged role-naming: 'the mechanism is'", r"\bthe mechanism is\b"),
    ("warn", "dodged role-naming: 'the value Y needs'", r"\bthe value [a-z $]{0,40}\bneeds\b"),
    ("warn", "scorekeeping flourish: 'does the same work'", r"\bdo(es)? the same work\b"),

    # -- Register.
    ("warn", "mission statement", r"\b(this blueprint (exists|is for)|job of this blueprint|the (first|whole) job|the deliverable)\b"),
    ("warn", "'what X buys'", r"\bbuys?\b"),
    ("warn", "rhetorical closer", r"\b(is the point|which is the point|that is the point)\b"),
    ("warn", "metaphor", r"\b(seams?|bridge between|engine of|the spine|depth dial|on-ramps?|escape hatch)\b"),
    # Colloquial idiom.  Every one of these was written here and removed; none
    # occurs anywhere in the human-written references.
    ("warn", "colloquial idiom",
     r"\b(earns? (its|their) place|part company|put to work|on the nose|for free|"
     r"waves? through|does one thing|headline|leaves? [a-z ]{0,24}\bbehind|"
     r"covers? the same ground|with no graph in)\b"),
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

# A paragraph-final sentence this short is either a step ("Necessity follows.")
# or drama ("The rest is short.").  STYLE.md, Duty 4: state a step or fuse it.
CLIPPED_CLOSER_WORDS = 6

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

# ---------------------------------------------------------------------------
# Register baselines, measured over the four human-written reference papers
# only (50,748 words; jacksonJordanVillanyi2026 + kiralyTanigawa2019 +
# asimowRoth1978/1979).  source/ is gitignored, so the numbers are baked in
# here rather than recomputed; provenance: survey of 2026-08-29, sentences
# segmented with inline math collapsed to one token, n = 1,904.
# ---------------------------------------------------------------------------
BASELINE_SENTENCES = {"mean": 24.6, "median": 19.0, "short": 0.22, "long": 0.27}

# phrase -> occurrences per 1,000 words in the references
BASELINE_PER_KW = {
    "thus": 1.87,
    "hence": 1.89,
    "suppose": 1.20,
    "note that": 0.67,
    "we may assume": 0.49,
    "therefore": 0.35,
    "it follows": 0.18,
    "so that": 0.16,
    "in particular": 0.12,
    "the following": 1.24,
    "for example": 0.28,
    "we will show": 0.24,
    "we first": 0.24,
    "we now": 0.20,
    "recall that": 0.08,
    "in this section": 0.12,
}
CONNECTIVES = ["thus", "hence", "suppose", "note that", "we may assume",
               "therefore", "it follows", "so that", "in particular"]
SIGNPOSTS = ["the following", "for example", "we will show", "we first",
             "we now", "recall that", "in this section"]


def prose(path: Path) -> str:
    body = path.read_text(encoding="utf-8").partition("#doc")[2]
    body = re.sub(r"```.*?```", "", body, flags=re.S)          # code and witnesses
    body = re.sub(r"^:::.*$", "", body, flags=re.M)             # directive open/close lines
    # Verso roles: `{role args}[text]` keeps its prose text; `{role args}`
    # followed by an inline-code span is a declaration reference -- one token.
    body = re.sub(r"\{[^{}]*\}\[([^\]]*)\]", r"\1", body)
    body = re.sub(r"\{[^{}]*\}`[^`]*`", "NAME", body)
    body = re.sub(r"\$\$?`[^`]*`", "MATH", body)                # inline/display math
    body = re.sub(r"`[^`\n]+`", "CODE", body)                   # remaining inline code
    return body


def paragraphs(text: str) -> list[str]:
    """Prose paragraphs: blank-line separated, lists and tables skipped."""
    out = []
    for para in text.split("\n\n"):
        para = para.strip()
        if not para:
            continue
        if any(l.lstrip().startswith(("-", "|", "#")) for l in para.splitlines()):
            continue                    # list, table, or heading
        out.append(" ".join(para.split()))
    return out


def sentences(para: str) -> list[str]:
    """Crude but adequate: split after . ? ! except common abbreviations."""
    guarded = re.sub(r"\b(i\.e|e\.g|cf|vs|Dr|Prof|no)\.\s", lambda m: m.group(0).replace(". ", ". "), para)
    parts = re.split(r"(?<=[.?!])\s+", guarded)
    return [p.replace(" ", " ").strip() for p in parts if p.strip()]


def report(paths: list[Path], root: Path) -> None:
    print(f"{'chapter':<28} {'sent':>5} {'mean':>5} {'med':>4} {'<=10w':>6} {'>=30w':>6}")
    b = BASELINE_SENTENCES
    print(f"{'references baseline':<28} {'':>5} {b['mean']:>5.1f} {b['median']:>4.0f} "
          f"{b['short']:>6.0%} {b['long']:>6.0%}")
    all_sents: list[int] = []
    all_words = 0
    all_text: list[str] = []
    for path in paths:
        rel = path.relative_to(root) if path.is_relative_to(root) else path
        text = prose(path)
        paras = paragraphs(text)
        lens = [len(s.split()) for p in paras for s in sentences(p)]
        words = sum(lens)
        all_sents += lens
        all_words += words
        all_text.append(" ".join(paras))
        if not lens:
            continue
        short = sum(1 for n in lens if n <= 10) / len(lens)
        long_ = sum(1 for n in lens if n >= 30) / len(lens)
        print(f"{str(rel.name):<28} {len(lens):>5} {statistics.mean(lens):>5.1f} "
              f"{statistics.median(lens):>4.0f} {short:>6.0%} {long_:>6.0%}")
    if all_sents:
        short = sum(1 for n in all_sents if n <= 10) / len(all_sents)
        long_ = sum(1 for n in all_sents if n >= 30) / len(all_sents)
        print(f"{'TOTAL':<28} {len(all_sents):>5} {statistics.mean(all_sents):>5.1f} "
              f"{statistics.median(all_sents):>4.0f} {short:>6.0%} {long_:>6.0%}")

    text = " ".join(all_text).lower()
    kw = all_words / 1000 if all_words else 1
    print(f"\nconnectives and signposts, per 1,000 words ({all_words} words of prose):")
    print(f"{'phrase':<18} {'count':>5} {'/1kw':>6} {'refs':>6}")
    for phrase in CONNECTIVES + SIGNPOSTS:
        n = len(re.findall(r"\b" + re.escape(phrase) + r"\b", text))
        print(f"{phrase:<18} {n:>5} {n / kw:>6.2f} {BASELINE_PER_KW[phrase]:>6.2f}")
    print("\nThe report never gates; it makes drift visible. See STYLE.md, Duties.")


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
        if seen_doc and re.match(r"#+ ", line):
            out.append((i, line.lstrip("#").strip()))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", type=Path)
    ap.add_argument("--strict", action="store_true", help="exit 1 on any error-level hit")
    ap.add_argument("--pedantic", action="store_true", help="exit 1 on any hit at all")
    ap.add_argument("--report", action="store_true", help="print register metrics, exit 0")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    paths = args.paths or [root / "BodyPinBlueprint.lean", *sorted((root / "BodyPinBlueprint/Chapters").glob("*.lean"))]

    if args.report:
        report(paths, root)
        return 0

    errors = warns = 0
    for path in paths:
        rel = path.relative_to(root) if path.is_relative_to(root) else path
        text = prose(path)

        for para in paragraphs(text):
            n = para.count("—")
            if n >= EM_DASH_LIMIT:
                print(f"{rel}: warn: {n} em dashes in one paragraph: ...{para[:90]}...")
                warns += 1
            sents = sentences(para)
            # An identifier caption is a paragraph that only names a
            # declaration: "The paper's MATH is NAME."  Fuse or drop it.
            if len(sents) <= 2 and re.search(r"\b(is|are) (NAME|CODE)[.,]", para):
                print(f"{rel}: warn: identifier caption (fuse into a mathematical "
                      f"sentence, or drop): ...{para[:90]}...")
                warns += 1
            # A clipped closer is a paragraph-final sentence with no step in it.
            # Short sentences that state a step are the references' most
            # characteristic move, so a hit here is only *sometimes* wrong.
            if len(sents) >= 2 and len(sents[-1].split()) <= CLIPPED_CLOSER_WORDS:
                print(f"{rel}: warn: clipped closer (a step, or drama?): "
                      f"{sents[-1]!r}")
                warns += 1

        for line, title in headings(path):
            if m := HEADING_VERBS.search(title):
                print(f"{rel}:{line}: warn: heading reads as a sentence "
                      f"(finite verb {m.group(0)!r}): {title!r}")
                warns += 1

        # Sentences are hard-wrapped in the source, so collapse whitespace or a
        # multi-word tell spanning a line break goes unseen.
        flat = re.sub(r"\s+", " ", text)
        for severity, label, pattern in TELLS:
            for m in re.finditer(pattern, flat, re.I):
                ctx = " ".join(flat[max(0, m.start() - 60) : m.start() + 70].split())
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
