#!/usr/bin/env python3
"""Check the generated site for things no source check can see.

`scripts/checks.sh` reads the chapters, and everything it knows comes from the
text a chapter was written in. Some of what this repository claims is only true
of the *rendered page*: that a named declaration actually produced a block, that
an elided proof obligation is really gone rather than folded away behind the
`⋯`. Both of those have been wrong on a built page while every source check
passed, and both were found by eye.

    python3 scripts/check-rendered.py                     # after a build
    python3 scripts/check-rendered.py --site-dir DIR

Run after `scripts/ci-pages.sh`, which invokes it. It refuses to read a site the
freshness stamp calls stale, since a check against output that no longer matches
the source is worse than no check: it reports on a page nobody will ever see.

**What it cannot see.** `BodyPinBlueprint.quotedBodyJs` splices a value into its
panel in the reader's browser, so the result of the splice is not in this HTML
at all. The bug that motivated half of this script -- assigning `textContent` to
an element, which flattened its subtree and fused a tactic label with its hidden
goal state -- is invisible here and was found by opening the page. Nothing short
of a headless browser would catch the next one of those.

Exits 1 if anything fails.
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

BLOCK = re.compile(r'<code class="hl lean block".*?</code>', re.S)
# The token Verso puts an id on at a definition site (`Token.Kind.idAttr`), which
# is what says which declaration a block is. `Bodies.lean` asks for it with
# `defSite := true`.
DEFINES = re.compile(r'<span class="const token"[^>]*\bid="([^"]+)"')
# A tactic block: a label the reader can click, and the goal state it reveals.
TACTIC = re.compile(r'<span class="tactic">(.*?)</span><input [^>]*class="tactic-toggle"', re.S)


def stale(site: Path) -> bool:
    done = subprocess.run([sys.executable, str(ROOT / "scripts" / "check-fresh.py")],
                          capture_output=True, text=True)
    for line in done.stdout.splitlines():
        if line.startswith(str(site.relative_to(ROOT))) and "current" in line:
            return False
    return True


def blocks(site: Path) -> dict[str, list[str]]:
    """Every quoted block on the site, by the declaration it defines."""
    found: dict[str, list[str]] = {}
    for page in sorted(site.rglob("index.html")):
        html = page.read_text(encoding="utf-8", errors="replace")
        for block in BLOCK.findall(html):
            match = DEFINES.search(block)
            if match:
                found.setdefault(match.group(1).replace("___", "."), []).append(block)
    return found


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--site-dir", type=Path, default=ROOT / "_out" / "site" / "html-multi")
    args = ap.parse_args()
    site = args.site_dir

    if not site.exists():
        print(f"{site} does not exist; run: bash ./scripts/ci-pages.sh", file=sys.stderr)
        return 2
    if stale(site):
        print(f"{site} is stale; rebuild before believing anything about it", file=sys.stderr)
        return 2

    import coverage

    named: set[str] = set()
    for _chapter, (_cited, quoted) in coverage.chapter_bodies().items():
        named |= quoted

    rendered = blocks(site)
    errors: list[str] = []

    for name in sorted(named - set(rendered)):
        errors.append(
            f"{name} is named in a BodyPinBlueprint.bodies fence but no block on the site "
            "defines it; the fence rendered nothing a reader can see")

    # A `⋯` marks an elided proof obligation. Verso renders a `by` block as a
    # toggle whose label is the block's own text, so an elision that leaves the
    # wrapper standing turns the `⋯` into the control that expands the goal
    # state it was there to remove. `Bodies.lean` drops such a wrapper; this is
    # what says it still does.
    for name, found in sorted(rendered.items()):
        for block in found:
            for label in TACTIC.findall(block):
                if "⋯" in label:
                    errors.append(
                        f"{name}: an elided obligation is still wrapped in a tactic block, so "
                        "its `⋯` expands the goal state instead of omitting it "
                        "(see `annotatable` in BodyPinBlueprint/Bodies.lean)")

    for error in errors:
        print(f"error: {error}")
    if errors:
        print(f"\n{len(errors)} error(s).")
        return 1
    print(f"{len(rendered)} quoted block(s) on the site, all named by a fence; "
          "no elided obligation keeps its goal state.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
