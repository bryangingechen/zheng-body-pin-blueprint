# Upstream findings

Issues and suggestions for `leanprover/verso-blueprint` and
`ejgallego/leanblueprint-to-verso`, found while building this blueprint.

Expectations are low for anything specific to the `v4.29.0` line: it is not in
`branch-policy.json`'s release targets and is no longer backported to. File
findings here as notes rather than issues unless one actually blocks.

---

## 1. Bootstrap template omits `require mathlib`, breaking the mathlib cache

**Where:** `leanblueprint-to-verso`,
`templates/repo-root/lakefile.lean.template`

**What happens:** the template generates only

```lean
require <Formalization> from "<path>"
require VersoBlueprint from git "..." @ "<ref>"
```

With a mathlib-dependent formalization, `lake update` then resolves
VersoBlueprint's dependency tree first, so Verso's `proofwidgets` pin wins over
mathlib's. `lake exe cache get` detects the mismatch and refuses:

```
Warning: your project pins different versions of some dependencies than Mathlib.
This will cause `lake exe cache get` to compute wrong hashes.

  proofwidgets:
    project: 2e58165a9dcd     (v0.0.92, from Verso)
    mathlib: 3c52dee17f0c     (v0.0.95, from mathlib)

error: mathlib: failed to fetch cache
```

Without the cache, `lake build` compiles all of mathlib from source — which for
most consumers is the difference between a usable setup and an unusable one.

**Fix:** add an explicit `require mathlib` as the **last** require, pinned to
the same rev as the formalization submodule. Lake's own diagnostic recommends
this, and it works — after the change, `proofwidgets` resolves to `v0.0.95` and
mathlib sorts first in the generated manifest.

```lean
require <Formalization> from "<path>"
require VersoBlueprint from git "..." @ "<ref>"
require mathlib from git "https://github.com/leanprover-community/mathlib4.git" @ "<rev>"
```

**Note on the ordering semantics**, since it is counterintuitive and worth
getting right in any template comment: declaring `require mathlib` *last* in the
lakefile causes mathlib to be resolved *first*. The natural guess — that
declaring the formalization first is enough to make its transitive mathlib pins
win — is wrong.

**Why the reference blueprints don't hit this:** all three mathlib-dependent
ones (`verso-noperthedron`, `verso-sphere-packing`, `verso-flt`) already carry an
explicit trailing `require mathlib`. So the gap is in the bootstrap path only,
and a new port created by `start_new_port.py` hits it immediately.

**Suggested change:** emit the third require from the template whenever the
formalization's `lake-manifest.json` lists mathlib, with the rev read from that
manifest; or, failing that, have `check_harness.py` warn when the formalization
depends on mathlib and the root lakefile has no direct `require mathlib`.

---

## 2. Bootstrap template's TeX prelude fails KaTeX lint on every math span

**Where:** `leanblueprint-to-verso`,
`templates/repo-root/__PACKAGE_NAME__/TeXPrelude.lean.template`

**What happens:** the generated prelude is

```
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\R}{\mathbb{R}}
\DeclareMathOperator{\Hom}{Hom}
```

The prelude is re-evaluated into a persistent KaTeX macro map, so from the
second math span onward `\newcommand` hits an already-defined macro and KaTeX
rejects the *entire* span:

```
warning: .../Statement.lean:31:46: KaTeX rejected blueprint math.
Reason: \newcommand{\N} attempting to redefine \N; use \renewcommand
```

One warning per math span, and every message names `\N` because evaluation
aborts at the first failure — which makes the real cause hard to see, since the
reported column points at innocent inline math rather than at the prelude.

With `weak.verso.blueprint.math.lint` on (which the same bootstrap enables) a
new port therefore emits a warning for nearly every piece of math it contains,
straight out of the box.

**Fix:** `\providecommand` is idempotent and silences all of them.

**Suggested change:** emit `\providecommand` in the template. Optionally, have
the math linter attribute a prelude-level failure to the prelude rather than to
the math span that happened to trip it.

---

## 3. Environment notes (local, not upstream bugs)

Recording these because they cost time and will recur on this machine:

- Lean `4.29.0` had to be installed by hand; it is old enough not to be present
  by default.
- A leftover `~/.elan/bin/elan-init` made every `elan` / `lean` / `lake`
  invocation fail with `could not remove 'setup' file`. Workaround while it
  persisted: call the toolchain binaries directly at
  `~/.elan/toolchains/leanprover--lean4---v4.29.0/bin`. Resolved by deleting the
  file.
- `ensure_dependency_cache.py` calls `elan which lake` as a fallback after
  `shutil.which("lake")`, and tolerates a non-zero exit — so it survives a
  broken elan shim. Good behaviour; worth keeping.
