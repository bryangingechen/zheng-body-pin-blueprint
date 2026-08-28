#!/usr/bin/env python3
"""Verify that Lean snippets copied into the blueprint still match the submodule.

Chapter prose quotes short definition bodies from `formalization/`, because the
external-declaration panel renders a signature and cannot render a body: `def
RB31E2E.EndToEndBodyPinStatement : Prop` tells a reader nothing. A copy is only
worth having if it is known to be current, so each one carries the source path
as its first line and is checked here against the file it names.

    ```
    -- RB31EndToEnd/Target.lean
    def EndToEndBodyPinStatement : Prop :=
      ...
    ```

A snippet may omit intervening docstrings and unrelated declarations, so each
blank-line-separated chunk is checked on its own rather than the block as a
whole. Every line still has to be genuine upstream text; only the gaps are ours.

The submodule is pinned to a SHA, so a mismatch means either the copy was
mistyped or the pin moved. Either way the copy needs re-reading, not patching.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

# Plain fences and Verso Manual Lean fences alike; the latter are elaborated for
# highlighting, which is why they may carry a leading `open ... in`.
BLOCK = re.compile(r"^```(?:Verso\.Genre\.Manual\.InlineLean\.lean)?[^\n]*\n-- (\S+)\n(.*?)^```$", re.M | re.S)
OPEN_IN = re.compile(r"^open [\w.]+ in\n", re.M)


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    formalization = root / "formalization"
    if not (formalization / "RB31EndToEnd.lean").exists():
        print("formalization/ is not checked out; run: git submodule update --init", file=sys.stderr)
        return 2

    checked = failed = 0
    for chapter in sorted((root / "BodyPinBlueprint" / "Chapters").glob("*.lean")):
        for m in BLOCK.finditer(chapter.read_text(encoding="utf-8")):
            rel, snippet = m.group(1), m.group(2).rstrip("\n")
            line = chapter.read_text(encoding="utf-8")[: m.start()].count("\n") + 1
            where = f"{chapter.relative_to(root)}:{line}"
            src = formalization / rel
            checked += 1
            if not src.exists():
                print(f"{where}: no such source file: {rel}")
                failed += 1
                continue
            text = src.read_text(encoding="utf-8")
            chunks = [OPEN_IN.sub("", c) for c in snippet.split("\n\n")]
            stale = [c for c in chunks if c.strip() and c not in text]
            if stale:
                print(f"{where}: {len(stale)} chunk(s) not verbatim in {rel}")
                for chunk in stale:
                    print(f"    | {chunk.splitlines()[0]}")
                failed += 1

    print(f"\n{checked} snippet(s) checked, {failed} stale.")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
