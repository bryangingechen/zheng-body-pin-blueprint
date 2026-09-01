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
# Only modules holding a `def` or an `abbrev` a node names are extracted -- 35
# of the 125 that correspondence.toml lists, because a theorem's value is its
# proof and the panel already renders a structure's fields. That list is
# computed by scripts/body-modules.lean, which needs the formalization loaded;
# it is cached in _out/body-modules.json and only has to be rerun when the
# submodule pin moves or a node names a new declaration.
#
# Lake traces each extract on the module's olean, so this is a no-op until the
# pin moves. Measured on CI (run 33516583281 and its two predecessors): about
# 6m30s cold for all 35, a few seconds warm. Background it when cold.

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
  # `lake env lean` sets up a search path and elaborates; it builds nothing. So
  # `import RB31EndToEnd` fails with `unknown module prefix` unless the
  # formalization's oleans are already on disk, which on a fresh checkout --
  # CI's, every time, since `_out/` and the build trees are ignored -- they are
  # not. Build the root module first. It pulls in exactly the modules the map
  # can name (every cited declaration is reachable from it: `missing` is empty),
  # and the extraction loop below needs the same oleans anyway.
  step "building the formalization the map loads"
  lake build RB31EndToEnd

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
targets=$(printf '%s\n' "$mods" | sed 's/$/:highlighted/')

# One invocation, not one per module, and serial within it.
#
# Warm, the whole cost here is Lake loading the workspace, and a loop pays that
# once per module: measured warm, a single module took 5.98 s and all 35
# together took 5.87 s. On CI, where startup is about 3.2 s, the loop spent
# 1m52s doing nothing else.
#
# `LEAN_NUM_THREADS=1` is not optional. Every `:highlighted` job writes a shared
# per-namespace marker -- `.lake/build/highlighted/ns-<hash>`, where the hash is
# of `SUBVERSO_SUPPRESS_NAMESPACES`, so every module in the workspace resolves
# to the same path. SubVerso's lakefile builds it inline inside each module's
# facet rather than as a registered target (`buildFileUnlessUpToDate' nsFile`,
# .lake/packages/subverso/lakefile.lean), so Lake never dedupes or orders those
# writes. The loop hid that by only ever running one at a time; building the
# modules together makes them race, and Lake 5.0.0 has no job-count flag to stop
# it. The symptom is an intermittent
#
#   warning: .../highlighted/ns-<hash>.trace: offset 0: unexpected end of input
#
# on a random module, in roughly two runs in three. Pinning Lean's thread pool
# to one serialises the jobs: 0 warnings in 6 runs, against 4 in the 6 before
# it. Worth reporting upstream -- the facet is simply not parallel-safe.
#
# The cost is that the `subverso-extract-mod` children inherit the variable, so
# a cold extract elaborates single-threaded. That is the case this script is
# already slowest in, but it only happens when the submodule pin moves, and warm
# runs are every CI run. If a cold extract ever gets painful, the fallback is
# the loop this replaced -- serial by construction, and no variable needed.
step "extracting $count module(s)"
LEAN_NUM_THREADS=1 lake build $targets

step "done; JSON is under .lake/build/highlighted/"
