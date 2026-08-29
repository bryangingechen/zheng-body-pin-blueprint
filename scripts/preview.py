#!/usr/bin/env python3
"""Render the blueprint locally in seconds, without the formalization.

A chapter that imports `RB31EndToEnd` spends about 169 s loading oleans before
elaborating a single word, and the full site build takes roughly ten minutes.
Almost nothing one iterates on needs any of that: slugs, citation rendering,
numbering, cross-reference text, math delimiters, the graph, the summary and the
bibliography are all pure Verso.

So this generates a parallel copy of the document with the formalization
coupling removed, and renders that:

    BodyPinBlueprint/Preview.lean            from BodyPinBlueprint.lean
    BodyPinBlueprint/Preview/<Chapter>.lean  from Chapters/<Chapter>.lean

Both are generated, gitignored, and rebuilt from scratch each run.

WHAT THE PREVIEW CANNOT SHOW, because it has no formalization to link against:

  * external declaration panels -- signatures, docstrings, source links
  * hovers on `name` references, which render as plain code
  * syntax highlighting in quoted Lean bodies, which render as plain text
  * node Lean-status, so the graph and summary colour every node as unformalized
  * anything `strictResolve` would catch: a wrong `(lean := ...)` name is
    stripped here rather than checked

For those, and before committing, run `bash ./scripts/ci-pages.sh`. For a wrong
declaration name specifically, the language server is the fast check -- see
BodyPinBlueprint/AGENTS.md.
"""
from __future__ import annotations

import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PKG = ROOT / "BodyPinBlueprint"
OUT = PKG / "Preview"

STRIP = [
    (re.compile(r"^import RB31EndToEnd.*\n", re.M), ""),          # the 169 s
    (re.compile(r'\s*\(lean := "[^"]*"\)'), ""),                   # external decls
    (re.compile(r"\{name [\w.]+\}(?=`)"), ""),                     # keep the code span
    # A `-show` block is scaffolding that the real build elaborates and never
    # renders. Drop it whole: rewriting its fence like any other would turn the
    # `open ... hiding` lines the reader is not meant to see into visible code.
    (re.compile(r"^```Verso\.Genre\.Manual\.InlineLean\.lean[^\n]*-show[^\n]*\n.*?^```\n\n?",
                re.M | re.S), ""),
    (re.compile(r"^```Verso\.Genre\.Manual\.InlineLean\.lean.*$", re.M), "```"),
    # A ```BodyPinBlueprint.bodies block names declarations whose bodies are read
    # out of `.lake/build/highlighted/`. Both halves of that are missing here:
    # the preview strips the `import RB31EndToEnd` lines, so the names do not
    # resolve, and it renders no declaration panels, which is where a body ends
    # up on the real site. Drop the block whole rather than show a list of names
    # that would misrepresent how much space the bodies take.
    (re.compile(r"^```BodyPinBlueprint\.bodies[^\n]*\n.*?^```\n\n?", re.M | re.S), ""),
]


def strip(text: str) -> str:
    for pattern, repl in STRIP:
        text = pattern.sub(repl, text)
    return text


def main() -> int:
    started = time.monotonic()
    OUT.mkdir(parents=True, exist_ok=True)

    # Write only what changed: an unchanged mtime is what lets lake skip a
    # chapter, which is the difference between a 26 s run and a 6 s one.
    def put(path: Path, text: str) -> bool:
        if path.exists() and path.read_text(encoding="utf-8") == text:
            return False
        path.write_text(text, encoding="utf-8")
        return True

    chapters = sorted((PKG / "Chapters").glob("*.lean"))
    stale = {c.name for c in chapters}
    for gone in OUT.glob("*.lean"):
        if gone.name not in stale:
            gone.unlink()
    written = sum(put(OUT / c.name, strip(c.read_text(encoding="utf-8"))) for c in chapters)

    root = (ROOT / "BodyPinBlueprint.lean").read_text(encoding="utf-8")
    root = strip(root).replace("BodyPinBlueprint.Chapters.", "BodyPinBlueprint.Preview.")
    root = root.replace('#doc (Manual) "', '#doc (Manual) "Preview: ', 1)
    written += put(PKG / "Preview.lean", root)
    print(f"[preview] {written} of {len(chapters) + 1} file(s) changed")

    # `Style` is not in the document's import tree, but PreviewMain runs against
    # it, and `lean --run` wants an olean rather than building one.
    for cmd in (["lake", "build", "BodyPinBlueprint.Preview", "BodyPinBlueprint.Style"],
                ["lake", "env", "lean", "--run", "PreviewMain.lean", "--output", "_out/preview"]):
        result = subprocess.run(cmd, cwd=ROOT)
        if result.returncode:
            print(f"[preview] FAILED: {' '.join(cmd)}", file=sys.stderr)
            return result.returncode

    subprocess.run([sys.executable, "scripts/check-fresh.py", "--write",
                    "_out/preview/html-multi"], cwd=ROOT)
    print(f"[preview] _out/preview/html-multi/index.html  ({time.monotonic() - started:.0f}s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
