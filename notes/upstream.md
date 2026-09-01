# Upstream findings

Issues and suggestions for `leanprover/verso-blueprint`, `leanprover/verso`,
`leanprover/subverso` and `ejgallego/leanblueprint-to-verso`, found while
building this blueprint. Each section says which under **Where:**.

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

## 3. `Citable` has no constructor for a book

**Where:** `verso`, `src/verso-manual/VersoManual/Bibliography.lean`

**What happens:** `Citable` offers exactly four shapes — `article`,
`inProceedings`, `thesis`, `arXiv`. Five of the 31 references in this paper are
monographs (Bruns–Herzog, Bruns–Vetter, Eisenbud, Fulton,
Graver–Servatius–Servatius), and there is nothing to put them in. `thesis` is
wrong; `inProceedings` renders a spurious "In" before the title of a book that
is not a collection.

**Workaround here:** enter them as `article` with the series in the `journal`
slot and the series number in `volume`, which is where author-date styles put
them anyway, so it renders correctly:

> W. Bruns and H. J. Herzog (1998). "Cohen–Macaulay Rings, revised edition".
> *Cambridge Studies in Advanced Mathematics, Cambridge University Press.* **39**.

Two smaller consequences of the same narrowness: `inProceedings` has no `pages`
field, so page ranges for book chapters have to be appended to `series`; and a
preprint or a web-published research note has no natural home at all (this repo
puts them in `article` with `journal := "Preprint"` / `"Research note"`).

**Suggested change:** add a `book` constructor (title, authors, publisher,
series, volume, edition, year, url) and a `misc`/`online` constructor
(title, authors, year, howpublished, url). Both are standard BibTeX entry types
and neither needs new rendering machinery.

---

## 4. Bibliography sorts by the whole author string, but cites by last name

**Where:** `verso`, `src/verso-manual/VersoManual/Bibliography.lean`
(`Citable.sortKey`) versus `VersoBlueprint`, `src/VersoBlueprint/Cite.lean`
(`authorText`).

**What happens:** inline citations abbreviate an author with
`Bibliography.lastName`, which takes the last word of the name — so
`inlines!"L. Asimow"` cites as "Asimow (1978)". But `Citable.sortKey` uses
`slugString` of the *entire* author inline, so the same entry sorts under "L.".
The rendered bibliography therefore comes out ordered by first initial, and an
author with two papers can be split apart by an unrelated third.

Writing the authors surname-first to fix the ordering breaks the citations
instead: `inlines!"Asimow, L."` cites as "L. (1978)". The two are not
simultaneously satisfiable, and citations are the more visible of the two, so
this repo writes initials-first and lives with the ordering.

**Suggested change:** have `sortKey` use `lastName` for each author, falling
back to the full inline when `lastName` returns it unchanged. That makes the two
consistent and needs no change to how entries are written.

---

## 5. No year-suffix disambiguation for same-author, same-year entries

**Where:** `verso`, `src/verso-manual/VersoManual/Bibliography.lean`;
`VersoBlueprint`, `src/VersoBlueprint/Cite.lean` (`pieceText`).

**What happens:** a rendered citation is `s!"{lastName} ({year})"`, with `year :
Int` and no disambiguating suffix. This blueprint cites three distinct Zheng
2026 artifacts — the paper, the research note, and the Lean development — and
all three render as "Zheng (2026)". The links and hover previews differ, but the
visible text does not, which is exactly what the author-date `2026a` / `2026b`
convention exists to fix.

**Workaround here:** name the artifact in the surrounding prose ("the author's
research note", "the paper") so the sentence disambiguates what the citation
cannot. Not a fix; a reader skimming the citations alone still cannot tell them
apart.

**Suggested change:** either add an optional `yearSuffix : Option String` to
each `Citable` shape, or compute suffixes automatically at render time from the
set of registered entries sharing a `(lastName, year)` key — the bibliography
command already has the whole entry list in hand when it renders.

---

## 6. `CitePartKind` has no `definition`, `proposition`, or `example`

**Where:** `VersoBlueprint`, `src/VersoBlueprint/Cite.lean` (`CitePartKind`).

**What happens:** citation locators are typed, and the type offers `chapter`,
`section`, `theorem`, `lemma`, `corollary`, `page`, `equation`, `figure`. A
mathematics paper routinely needs `definition`, `proposition`, `example` and
`remark` as well; `appendix` would help too. This paper has Definitions 3.1 and
3.2, Propositions 3.3 and 6.5, and Examples 2.2, 4.1 and 5.2, none of which can
be typed.

**Workaround here:** drop `kind` and put the whole locator in `index`
(`(index := "Proposition 3.3")`). The rendered citation is identical — the
inline text is just `{locator} {index}` either way. What is lost is the
bibliography usage panel, which falls back from "Cites Proposition 3.3" to the
clumsier "Cites reference Proposition 3.3", and the machine-readable `kind` in
the manifest.

**Suggested change:** add `definition`, `proposition`, `example`, `remark` and
`appendix` to `CitePartKind` and its `parse?`. Each is one line, and the render
path already handles an arbitrary `text`. Alternatively, when `kind` is absent
but `index` begins with a capitalised word, drop the "reference" filler.

---

## 7. Environment notes (local, not upstream bugs)

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

- Chapter modules that set `doc.verso true` have their `/-! ... -/` module
  docstring elaborated as a Verso document, so backticked paths and words in a
  file header draw "Code element could be more specific" warnings. Expected
  behaviour rather than a bug, but it is not obvious. Use `/- ... -/` for
  chapter headers.

## 8. The external-declaration panel cannot show a definition's body

Checked against both `v4.29.0` (our line) and `origin/v4.33.0` (maintained), on
2026-08-28. `src/VersoBlueprint/ExternalDeclRender.lean` assembles the panel
from exactly three things:

- the signature, from `Verso.Genre.Manual.Signature.forName`;
- the docstring, from `findDocString?`;
- for a structure or an inductive, its constructor, parents, fields/methods and
  constructors sections.

The `ConstantInfo` is in scope and carries `value?`, but it is read only for the
`unsafe`/`partial` badge and the keyword. Nothing in either branch renders a
value, there is no option, and the HTML comes out of a `private def
renderExternalDeclWrapper`, so no plugin can reach inside the panel.

This is why every chapter that describes a `Prop`-valued definition has to
restate its content in the node body, and why every `def` and `abbrev` a node
names is quoted in a block of its own -- a rule `scripts/coverage.py` enforces
rather than leaving to a reviewer. See `BodyPinBlueprint/AGENTS.md`.

Two false leads, recorded so they are not chased again. The upstream commit
`00b8458` "record retained-body prototype outcome" is about elaborating a Verso
*directive's* body once and reusing it -- a build-time optimisation at the
Blueprint directive boundary -- not about rendering a Lean definition's value.
And `Source/Data.lean`, new on `4.33`, is the `:::source_document` layer for the
*paper*, not for Lean source.

If it were wanted, the routes are, cheapest first: a Blueprint-local block role
of our own that reads the pinned submodule by the declaration's line range,
which the renderer already computes for the panel's source link, and renders a
panel-shaped box next to it; a patch to VersoBlueprint, which on the 4.29 line
would be ours to carry indefinitely; or post-processing the generated HTML,
which would break the property that a page is what Verso rendered. Upstream
runs a roadmap card system under `doc/roadmap/cards/`, so a feature request has
somewhere to go.

**What this repo does instead**, and it is a fourth route the list above missed:
`BodyPinBlueprint.quotedBodyJs`, inlined into every page's `<head>` through
`RenderConfig.extraJs`, splices each quoted body's *value* onto the end of the
panel's generated signature, and takes the run it came from out of the prose.
That is not post-processing — the generated file still holds the block where the
chapter put it, and the move happens in the reader's browser — so the property
survives.

Splicing rather than replacing is the point. The signature is generated from the
pinned environment and carries the full name, the universe levels, the qualified
types, and every binder a `variable` block supplied; the quoted source carries
the value and, because it is written against those `variable`s, a partial binder
list. `RB31E2E.Sparse22.{u_1} {V : Type u_1} [DecidableEq V] (F :
RB31E2E.SimpleEdgeSet V) : Prop` against `def Sparse22 (F : SimpleEdgeSet V) :
Prop` is the shape of it. Joining them costs nothing; swapping one for the other
would trade a generated guarantee for a hand-made copy.

That solves *placement*. **Sourcing** is solved separately, and by a route none
of the above lists: SubVerso's `subverso-extract-mod`, which is already in the
dependency tree. It re-elaborates a module of the formalization and emits, per
command, a `ModuleItem` carrying `defines : Array Name` and `code : Highlighted`
— Verso's own type, so it renders with the same colours, hovers and links as any
other Lean block. `BodyPinBlueprint/Bodies.lean` reads that back and a
```BodyPinBlueprint.bodies fence names declarations instead of copying them.

Three things make it the right route rather than merely a working one. It needs
no change to the submodule: SubVerso's *anchor* mechanism would want
`-- ANCHOR:` comments in the source, which is out of the question here, but
module extraction needs none. Its `defines` names are fully qualified, so the
join to a panel is exact rather than a dotted-suffix guess. And it is a proper
Lake facet — `module_facet highlighted`, traced on the module's olean, writing
to the *workspace root* build dir — so it caches, and it never writes inside the
submodule. Measured against the eleven hand-quoted declarations that could be
compared, it reproduced every one byte for byte.

The cost is real and is recorded in `AGENTS.md`. It is 35 modules now, not the
15 first measured, and the local per-module figures there have not been
rechecked since; what has been measured is CI, where a cold extract of all 35
took 6m21s and 6m55s on two runs whose job totals were 23m33s and 16m18s. Warm,
with the tree restored and the modules built in one invocation, it is 5.4 s
(run 33519120430, a 7m58s job). Section 10 below is why it runs as a single `lake build`
invocation, and section 11 is what CI had to change to keep the output between
runs.

It joins on the panel's `data-decl`, on the `id` Verso puts on a block's
defining occurrence of a constant (`Token.Kind.idAttr`, which emits one only for
a definition site), and on the `kw-occ-<production>-<position>` binding SubVerso
records on every keyword token — so an upstream restyle that renamed any of
those would stop it. It is written to leave the page alone whenever it cannot
resolve, so what a restyle costs is the feature, not the page.

That last binding is worth stating precisely, because it decided where a fix
belonged. `SubVerso.Highlighting.Code` sets `occ := s!"{name}-{pos}"` from the
*enclosing syntax node*, so a rendered token says which parser production it
belongs to and where that production began: the `where` of a `def ... where` is
`kw-occ-Lean.Parser.Command.whereStructInst-3348`, and the `where` that opens a
`structure`'s fields is `kw-occ-null-596`. The real parse is therefore in the
page, and a boundary that depends on it needs no reparse in Lean. But SubVerso
emits a `keyword` token only for an atom beginning with a letter (`Code.lean`,
`if c.isAlpha then .keyword name occ docs`), so `:=` and `|` arrive with no
binding at all — which is why `quotedBodyJs` reads `where` off the tree and the
other two forms off their tokens. See `BodyPinBlueprint/Style.lean`.

## 9. The graph's status labels have no per-node override

`Informal.Graph` computes every node's border and fill from the Lean anchors
alone: a node with no `(lean := ...)` whose recorded statement dependencies
are all locally formalized is labelled *ready to formalize* (blue), and a
theorem-like node with proved anchors fills light green until every node in
its transitive `uses` closure also has proved anchors, at which point it
turns dark (*locally formalized + dependencies complete*). There is no node
option to opt out of or re-word these labels — `Block/Model.lean`'s node
fields are owner/tags/priority, and `Graph.lean` reads none of them for
status — so a deliberately informal node in a finished blueprint (this
repository's `asimow_roth`, the strata nodes, `ungrounded_variety`) shows
*ready to formalize* no matter what the prose says.

Not filed upstream as a bug, since the vocabulary is correct for the
coordination blueprints the tool is built for. For this repository the
mitigation is prose: the audit chapter's "Reading the dependency graph"
section says how to read the labels here, and the edges were reviewed so
that the colours at least aggregate the right closure (see
`BodyPinBlueprint/AGENTS.md`, "Dependency edges"). If upstream ever grows a
per-node status override or an "informal by design" flag, that section can
shrink.

---

## 10. SubVerso's `highlighted` module facet is not parallel-safe

**Where:** `subverso`, `lakefile.lean` (`module_facet highlighted`, both the
`Compat.useOldBind` branch and the other).

**What happens:** each module's facet computes

```lean
let suppNS := (← IO.getEnv "SUBVERSO_SUPPRESS_NAMESPACES").getD ""
let nsFile := buildDir / "highlighted" / s!"ns-{hash suppNS}"
```

The marker's name depends only on that environment variable, so every module in
a workspace resolves to the same path. It is then built *inline inside the
module's own job* —

```lean
buildFileUnlessUpToDate' (text := true) nsFile do
  IO.FS.createDirAll (buildDir / "highlighted")
  IO.FS.writeFile nsFile suppNS
```

— rather than being registered as a target, so Lake neither dedupes nor orders
those writes. Observed: building one module and then a different one bumps the
marker's mtime both times, so it is rewritten unconditionally even when nothing
changed.

Serially this is invisible, which is why a loop over `lake build
<module>:highlighted` never showed it. Building several such targets in one
invocation makes the jobs race on the marker and on its `.hash` and `.trace`,
and a reader that catches one mid-write reports

```
warning: .../.lake/build/highlighted/ns-<hash>.trace: offset 0: unexpected end of input
```

against whichever module happened to lose — 4 of 6 batched runs here. Lake
5.0.0 has no job-count flag to serialise it (checked `lake help build`, the
global options, and the binary's strings).

The blast radius, as far as it could be checked, is confined to the marker: each
module writes its own `<Module>.json`, `.hash` and `.trace`, which no other job
touches, and all 35 JSON files parsed after every warning run.

**Workaround here:** `LEAN_NUM_THREADS=1` on the batched invocation pins Lean's
thread pool and serialises Lake's jobs — 0 warnings in 6 runs locally, and 0 on
CI, where the same change took extraction from 1m52s to 5.4 s (run
33519120430). See `scripts/extract-bodies.sh`, which explains the trade: the
`subverso-extract-mod` children inherit the variable, so a cold extract
elaborates single-threaded. That has not been measured — no pin has moved since
— and it is the one number here that is still a prediction.

**Suggested change:** register the marker as a real Lake target so Lake builds
it once and orders the dependency, rather than building it inline in every
module's job. Failing that, skip the write when the file already holds `suppNS`.

---

## 11. The Pages workflow caches the build but not the extracted highlighting

**Where:** `verso-blueprint`, `.github/workflows/blueprint-pages.yml` (v4.29.0).

**What happens:** the reusable workflow restores three caches —
`.lake/packages/*`, `.lake/build/{lib,ir}`, and
`<formalization>/.lake/build/{lib,ir}`. SubVerso's `highlighted` facet writes to
the *workspace root's* `.lake/build/highlighted/`, which none of them cover. So
a blueprint that quotes declaration bodies re-extracts every module on every
run, even when the oleans were restored unchanged and Lake's own traces would
have skipped the work.

And it cannot be fixed from the calling side:

- the workflow takes exactly three inputs — `checkout_submodules`,
  `harness_enabled`, `warm_dependency_cache` — none of them a cache path;
- a job that calls a reusable workflow cannot carry `steps`, so no
  `actions/cache` can run beside `./scripts/ci-pages.sh`;
- a sibling job runs on a different runner and shares no filesystem;
- and the cache service is unreachable from inside the script, because
  `ACTIONS_RUNTIME_TOKEN` and `ACTIONS_CACHE_URL` are not exported to `run:`
  steps. Re-exporting them is what `crazy-max/ghaction-github-runtime` is for,
  and that is an action, so it cannot be added either.

**Workaround here:** `.github/workflows/blueprint.yml` vendors the upstream job
at v4.29.0 and adds `.lake/build/highlighted` to the root build cache. Verified
structurally identical to upstream otherwise, bar the three `if:` input guards,
which all resolve true. Restoring the tree took extraction from 6m55s to 1m52s.
The cost is that `update_ci.py` reports the file as diverged from then on, as it
already did for `scripts/ci-pages.sh`; see that file's header comment for the
re-sync instruction.

Worth knowing if anyone repeats it: **adding the path is not sufficient on its
own.** The exact cache key has to move as well, or `actions/cache` finds the
existing entry already present, skips the save, and the new path is never
cached — the edit looks applied and does nothing. This repo puts
`.github/workflows/blueprint.yml` into the key's `hashFiles` so that any future
edit to `path:` busts the key automatically, and leaves the `restore-keys`
coarse so warm restores still hit.

**Suggested change:** add the highlighting output to the root build cache
upstream — it is the natural companion to `.lake/build/{lib,ir}` for any
blueprint that quotes bodies — or expose an `extra_build_cache_paths` input so
consumers can extend it without vendoring the whole job.

---

## 12. Two smaller things in the same workflow

**Where:** `verso-blueprint`, `.github/workflows/blueprint-pages.yml` (v4.29.0).

- The warm-cache step guards the formalization's `lake exe cache get` on
  `[ -f "<formalization_path>/lakefile.lean" ]`. A formalization with a
  `lakefile.toml` — this one — never matches, so that branch never runs. Harmless
  here (it is a single Lake workspace, there is no `formalization/.lake/packages`,
  and the root `cache get` already covers mathlib), but the guard should accept
  either filename.

- The root and formalization cache keys hash `'*.lean', '**/*.lean'`. The package
  cache is restored earlier in the same job, so once it hits, `**/*.lean` sweeps
  `.lake/packages/` as well — thousands of mathlib files — and the exact key
  differs between a run where the packages were cold and one where they were
  warm. Seen here: the formalization key was `...-v1-4f0564...` on the first
  cold run and `...-v1-77fe43...` on the next, and the coarse `restore-keys`
  prefix is the only reason the second run got its hit. It settles once the
  package cache is stable, but it means the first warm run always saves a fresh
  multi-gigabyte entry against the repository's 10 GB cache budget. Excluding
  `.lake/**` from those globs would make the keys mean what they appear to mean.
