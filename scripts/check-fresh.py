#!/usr/bin/env python3
"""Say whether a generated site corresponds to the current working tree.

The ten-minute gate is worth backgrounding, and this is what makes that safe.
The hazard is not corruption -- it is reading output that no longer matches the
source. It bit this project repeatedly: a chapter edited while `ci-pages.sh` was
in flight produced a site rendered from the *previous* elaboration, which was
then inspected and reported on. The conclusion drawn was wrong twice, and the
HTML looked perfectly normal both times.

So each build stamps its output with a hash of everything that can affect it,
and this reports whether that stamp still matches.

    python3 scripts/check-fresh.py                        # report on both outputs
    python3 scripts/check-fresh.py --write _out/site/html-multi

Exits 1 if any existing output is stale, so it can gate a claim about a page.
"""
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STAMP = ".source-hash"
OUTPUTS = ["_out/site/html-multi", "_out/preview/html-multi"]


# `scripts/preview.py` generates these, and they are gitignored. They cannot
# affect the site, so hashing them would report a freshly built site as stale
# the moment anyone ran the fast preview loop.
GENERATED = {"Preview", "Preview.lean"}


def inputs() -> list[Path]:
    """Everything a rendered page can depend on, except the generated preview copy."""
    files = [p for p in sorted((ROOT / "BodyPinBlueprint").rglob("*.lean"))
             if not GENERATED & set(p.relative_to(ROOT).parts[1:])]
    for name in ("BodyPinBlueprint.lean", "BlueprintMain.lean", "PreviewMain.lean",
                 "lakefile.lean", "lean-toolchain", "verso-harness.toml"):
        p = ROOT / name
        if p.exists():
            files.append(p)
    return files


def source_hash() -> str:
    h = hashlib.sha256()
    for p in inputs():
        h.update(str(p.relative_to(ROOT)).encode())
        h.update(p.read_bytes())
    # the pinned formalization is an input too: moving the submodule changes
    # every rendered signature and source link
    rev = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT / "formalization",
                         capture_output=True, text=True)
    h.update(rev.stdout.strip().encode())
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", type=Path, help="stamp this output directory")
    args = ap.parse_args()

    current = source_hash()
    if args.write:
        args.write.mkdir(parents=True, exist_ok=True)
        (args.write / STAMP).write_text(current, encoding="utf-8")
        print(f"[fresh] stamped {args.write.relative_to(ROOT) if args.write.is_absolute() else args.write}")
        return 0

    stale = 0
    for out in OUTPUTS:
        path = ROOT / out
        if not (path / "index.html").exists():
            print(f"{out}: not built")
            continue
        stamp = path / STAMP
        if not stamp.exists():
            print(f"{out}: UNSTAMPED — built before this check existed, treat as stale")
            stale += 1
        elif stamp.read_text(encoding="utf-8").strip() != current:
            print(f"{out}: STALE — source changed since it was built; do not read it")
            stale += 1
        else:
            print(f"{out}: current")
    return 1 if stale else 0


if __name__ == "__main__":
    raise SystemExit(main())
