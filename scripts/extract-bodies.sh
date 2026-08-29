#!/usr/bin/env bash
#
# Extract declaration bodies from the pinned formalization.
#
# The external-declaration panel renders a signature and cannot render a value
# (notes/upstream.md section 8). SubVerso's `subverso-extract-mod` re-elaborates
# a module and emits, per command, the names it defines and its highlighted
# code; `BodyPinBlueprint/Bodies.lean` reads that back and the ```bodies fence
# renders it. Nothing is copied into this repository and no copy can go stale.
#
# Only modules holding a `def` or an `abbrev` a node names are extracted -- 15
# of the 125 that correspondence.toml lists, because a theorem's value is its
# proof and the panel already renders a structure's fields. That list is
# computed by scripts/body-modules.lean, which needs the formalization loaded;
# it is cached in _out/body-modules.json and only has to be rerun when the
# submodule pin moves or a node names a new declaration.
#
# About 85 seconds per module cold, six seconds warm: Lake traces the output on
# the module's olean, so this is a no-op until the pin moves. Roughly 21 minutes
# from cold. Background it.

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

names="_out/body-names.txt"
map="_out/body-modules.json"

step() { printf '\n[extract-bodies] %s\n' "$*" >&2; }

step "collecting the declarations the chapters name"
python3 - "$names" <<'PY'
import re, sys, pathlib

# Two sources, and both matter. A `(lean := ...)` name is what a node claims to
# correspond to, and its module is worth extracting on the chance that a body is
# wanted; body-modules.lean drops the theorems among them. A name inside a
# ```BodyPinBlueprint.bodies fence is a *demand*: the chapter will not elaborate
# unless that module has been extracted. Collecting only the first kind worked
# by coincidence -- every body quoted so far sat in a module some node also
# cited -- and would fail as soon as one did not.
CITED = re.compile(r'\(lean\s*:=\s*"([^"]+)"\)')
FENCE = re.compile(r"^```BodyPinBlueprint\.bodies[^\n]*\n(.*?)^```$", re.M | re.S)

out = set()
for p in sorted(pathlib.Path("BodyPinBlueprint/Chapters").glob("*.lean")):
    text = p.read_text(encoding="utf-8")
    for m in CITED.finditer(text):
        out.update(n.strip() for n in m.group(1).split(",") if n.strip())
    for m in FENCE.finditer(text):
        out.update(
            line.strip()
            for line in m.group(1).splitlines()
            if line.strip() and not line.lstrip().startswith("--")
        )
path = pathlib.Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
text = "\n".join(sorted(out)) + "\n"
# Write only on a change. The module map below is rebuilt when this file is
# newer than it, so rewriting an identical list would spend three minutes
# reloading oleans on every build.
if not path.exists() or path.read_text(encoding="utf-8") != text:
    path.write_text(text, encoding="utf-8")
    print(f"{len(out)} declarations (list changed)")
else:
    print(f"{len(out)} declarations (unchanged)")
PY

if [ ! -f "$map" ] || [ "$names" -nt "$map" ]; then
  step "mapping declarations to modules (about three minutes, loads oleans)"
  lake env lean scripts/body-modules.lean
else
  step "reusing $map"
fi

mods=$(python3 -c "
import json, sys
print('\n'.join(json.load(open('$map'))['bodyModules']))
")

count=$(printf '%s\n' "$mods" | grep -c . || true)
step "extracting $count module(s)"
i=0
for m in $mods; do
  i=$((i + 1))
  printf '[extract-bodies] (%d/%d) %s\n' "$i" "$count" "$m" >&2
  lake build "$m:highlighted"
done

step "done; JSON is under .lake/build/highlighted/"
