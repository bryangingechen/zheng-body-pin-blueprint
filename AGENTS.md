# Start here

Read in this order before doing anything:

1. `PLAN.md` — what this blueprint is for, chapter structure, decisions and
   their reasons, phases, and what to do next.
2. `correspondence.toml` — the paper -> Lean mapping. The spine of the project.
3. The "Project-Specific Conventions" section further down this file.
4. `notes/` — `attribution.md` (provenance), `upstream.md` (harness/verso
   findings), `questions.md` (open reading questions).

`BodyPinBlueprint/Chapters/Statement.lean` is the worked example: copy its shape.

Quick sanity check that the repo is healthy:

```bash
python3 tools/verso-harness/scripts/check_harness.py --project-root .
bash ./scripts/ci-pages.sh          # ~5 min warm, ~45 min cold
```

---

# Leanblueprint To Verso Harness Notes

- This repo uses the local helper at `tools/verso-harness`.
- Keep a root `verso-harness.toml` checked in and treat it as the source of
  truth for package layout, LT chapter scope, and the TeX source path.
- Keep `lakefile.lean` aligned with that warning policy, especially
  `harness.strict_external_code`.
- Use `harness.docstring_warnings` to decide whether standard harness workflows
  should surface missing-docstring warnings. The default is to keep them
  hidden until the repo is ready to work through them explicitly.
- Before porting or maintaining blueprint files, read:
  - `tools/verso-harness/references/layout.md`
  - `tools/verso-harness/references/lt-method.md`
  - `tools/verso-harness/references/porting.md`
  - `tools/verso-harness/references/maintenance.md`
  - `tools/verso-harness/references/retrofit.md`
  - `tools/verso-harness/references/beam-validation.md`
- Start maintenance with `python3 tools/verso-harness/scripts/status_harness.py --project-root .`
  so you can see helper, upstream, and `VersoBlueprint` drift first.
- Use `python3 tools/verso-harness/scripts/check_harness.py --project-root .`
  to audit the local harness layout after that status pass.
- Treat the legacy TeX or `leanblueprint` source as the prose source of truth.
- Record the real TeX chapter source locator for this repo. The common legacy
  layout is `./blueprint/src/chapter/*.tex`, but some projects use a single
  file such as `./blueprint/src/chapter/main.tex`; verify it before porting.
- Point `tex_source_glob` at the maintained upstream tree, not a copied
  snapshot. If it also matches inactive files, map every direct-port chapter
  to its current files in `[lt.source_files]`.
- Treat chapters in `lt.default_chapters` as the direct-port LT scope.
- The default deliverable for direct-port chapters is an LT pass. Do not trust
  older LT labels by themselves; every translated informal block now needs an
  adjacent local `tex` witness.
- Preserve section order, paragraph boundaries, labeled theorem order, and
  important dependency edges when translating to Verso.
- Treat the host formalization as the source of truth.
- Prefer `(lean := "...")` links to real declarations rather than duplicating
  Lean code in blueprint modules.
- Preserve TeX `\uses{...}` edges as Verso dependency metadata on the relevant
  node or proof. Prefer block options such as `(uses := "foo, bar")`; use
  inline `{uses "foo"}[]` only when the source reference is naturally part of
  the translated prose.
- Translate TeX `\ref{...}` references to blueprint nodes as inline
  `{bpref "..."}[]` links when the source is only pointing at the node and
  should not add a dependency edge. Do not upgrade these to `uses` unless the
  source has `\uses{...}` or this repo explicitly wants a graph dependency.
- Do not introduce standalone prose lines that exist only to display
  dependency edges; put those edges in `(uses := ...)` on the node instead.
- Keep prose as prose unless the source really gives a graph-visible theorem,
  definition, lemma, corollary, or proof-style object.
- Preserve TeX environment kind faithfully. Use `:::lemma_` for TeX
  `\begin{lemma}`, `:::corollary` for `\begin{corollary}`, `:::definition` for
  `\begin{definition}`, `:::proof` for `\begin{proof}`, and reserve
  `:::theorem` for `\begin{theorem}`.
- Do not use `:::theorem` as a generic wrapper for source material that should
  remain prose or another node kind.
- When the source block still needs to stay visible, prefer a labeled local
  `tex` block over rewriting it into placeholder prose.
- Treat metadata cleanup as a second phase of LT rather than as a substitute
  for LT. First localize the text with a `tex` witness, then tighten
  `(lean := "...")`, `(uses := ...)`, inline `{uses "..."}[]` where it is
  natural in prose, and `{bpref "..."}[]`.
- Port coherent chapter blocks rather than scattering small edits across
  unrelated chapters.
- Keep shared TeX macros in one `TeXPrelude.lean` module.
- Prefer the harness pattern where `VersoBlueprint` drives the `verso`
  dependency unless this repo has a concrete reason to pin `verso` directly.
- Generated consumers keep the version-appropriate Verso math-lint option
  enabled, disable the noisy `VersoManual` inline-code line-length warning, and
  default the version-appropriate strict-resolve option from
  `harness.strict_external_code`.
- After editing direct-port chapters, run:
  - `python3 tools/verso-harness/scripts/check_lt_source_pairs.py --project-root . <chapter.lean>`
  - `python3 tools/verso-harness/scripts/check_lt_source_freshness.py --project-root . --require-current <chapter.lean>`
  - `python3 tools/verso-harness/scripts/check_lt_similarity.py --project-root . <chapter.lean>`
- Use `python3 tools/verso-harness/scripts/check_blueprint_node_kinds.py --project-root . <chapter.lean>`
- Use `python3 tools/verso-harness/scripts/check_source_label_grounding.py --project-root . <chapter.lean>`
- Use `python3 tools/verso-harness/scripts/check_verso_math_delimiters.py --project-root . <chapter.lean>`
- Use `python3 tools/verso-harness/scripts/lt_audit.py --project-root . <chapter.lean>`
  when you want the source-pair check, similarity report, focused build, and
  optional extra checks such as `--node-kinds`, `--math-sanity`, or pages
  smoke test in one command.
- Use `python3 tools/verso-harness/scripts/lt_audit.py --project-root . --native-warnings <chapter.lean>`
  when you also want consumer-owned Lean, Verso, and VersoBlueprint warnings to
  fail the focused chapter build while upstream and dependency warnings are
  summarized separately.
- Use `python3 tools/verso-harness/scripts/lt_audit.py --project-root . --native-warnings --native-warnings-scope all <chapter.lean>`
  when you want the stricter transitive warning-fail behavior.
- Use `python3 tools/verso-harness/scripts/lt_audit.py --project-root . --no-native-warnings <chapter.lean>`
  to suppress warning-fail mode for one run when the repo default enables it.
- After a coherent batch, run `bash ./scripts/ci-pages.sh`.
- Keep the root build green. If a Lean link would pull in imports that are not
  harness-clean on the current toolchain, leave the node informal and note the
  dependency in prose instead.
- If using `lean-beam`, avoid parallel `sync` calls against the same project
  root unless the target repo is known to tolerate it.
- If using sub-agents, prefer one agent per chapter or per clearly disjoint file set.
- Do not split one chapter across multiple agents unless one side is read-only.
- Merge chapter edits before running shared validation steps.

---

# Project-Specific Conventions (this repo)

These override or extend the harness defaults above. This repository is an
**unofficial** blueprint for someone else's paper and formalization; read
`README.md` for the scope statement before writing prose.

## What this blueprint is for

The upstream formalization is **already complete** — no `sorry`, no custom
axioms, axiom closure exactly `propext`, `Classical.choice`, `Quot.sound`. So
this is not a coordination blueprint. Its job is to let a reader check,
statement by statement, that the Lean development proves *the paper's theorem*,
and to make visible where the Lean route departs from the written argument.
Coverage and correspondence are the deliverable; progress percentage is not.

## No TeX source (permanent)

The paper was distributed as a PDF; no LaTeX source exists to obtain. Therefore:

- `lt.default_chapters` stays `[]` and `tex_source_glob` is a placeholder.
- The harness LT pipeline (`check_lt_source_pairs`, `check_lt_similarity`,
  `check_lt_source_freshness`) does **not** apply. Do not try to make it run.
- Source-independent harness checks **do** apply and should be used:
  `check_harness.py`, `check_blueprint_node_kinds.py`,
  `check_verso_math_delimiters.py`, `check_blueprint_heading_structure.py`.
- `tex` witness blocks are hand-transcribed from the paper. Transcribe from the
  PDF text layer, not by eye, and treat "witness matches the paper" as an
  explicit review item — no script will check it for you.

## Witnesses quote the paper, never the blog

The author also published an informal research note:
<https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/>. It is a
gloss on the paper and its wording differs. A `tex` witness is *the thing being
formalized*, so it must come from the paper. Blog material goes in ordinary
prose and links only — never into a witness block, and never into an `md`
witness slot on a node that also has a paper witness.

## Labels

Semantic and stable, never paper numbers (numbering shifts between preprint
revisions). The paper number goes in the node title, the prose, and the
correspondence table.

- statements: `bodypin_partition_characterization`, `stress_codim_flags`,
  `flag_selection`, `witt_shear_componentwise`
- Lean-only nodes with no paper counterpart: `lean_` prefix, e.g.
  `lean_nixon_owen_reduction`
- Name **cluster** nodes after the paper's proof step, never after a module
  family, so the label survives a later split onto child nodes.

## Tags carry blueprint state, not proof state

`lake exe vbp query work-queue` should read as a to-do list for the exposition:

- `paper` — numbered result from the paper, mapped to Lean
- `informal-only` — in the paper, deliberately not formalized (all of paper §4)
- `lean-only` — in Lean, no paper counterpart
- `deviation` — mapped, but by a different route; has a register entry
- `unwritten` — node stubbed, prose not drafted. Removing the last `unwritten`
  is the definition of done.

## Imports

Chapters import the **specific** formalization modules they reference
(`import RB31EndToEnd.Rigidity.BarJoint`), never the library root — except
where a node genuinely references the root theorem, which lives in the root
module.

Two honest caveats on the cost argument. Five of the formalization's 125
modules (`Specification`, `Rigidity/BarJoint`, `Linear/Vec3Twist`,
`Graph/LooplessMultiGraph`, `Incidence/Arithmetic`) do a blanket
`import Mathlib`, and they are the foundational ones — so *any* chapter
referencing *any* formalization declaration transitively imports all of Mathlib.
That floor is upstream's choice and cannot be avoided here. What granularity
does buy is not loading the formalization's own 126 oleans, which are heavy.

The rule's more durable justification is therefore auditability rather than
speed: a chapter's import list states exactly which part of the formalization
its prose depends on, which is the relationship this whole blueprint exists to
document.

## Dependency edges

- `uses` for genuine mathematical dependency; `bpref` for navigational links.
- Proof-only prerequisites go on the `:::proof` block, not the statement.
- Infrastructure edges get `(uses_intent := "technical")` so the main spine
  stays legible under the sparsity and weight-apparatus clusters.
- `autoDeps` stays **off** by default: 1,851 declarations would swamp the graph
  before the manual spine exists. Turn it on per-file only when deliberately
  deepening one family, review the inferred edges, then decide.

## Attribution

- `:::author` / `owner` is triage metadata (who is writing the node), **not**
  mathematical credit. Zheng is not an author of this blueprint and must not
  appear as a node owner.
- Mathematical credit runs through the bibliography: cite the paper on every
  `paper`-tagged node, and cite the upstream references at the points the paper
  invokes them. Getting those right matters more than claiming anything here.
- Record provenance facts in `notes/attribution.md` as you find them.

## Figures

Redraw as hand-authored inline SVG with theme-aware `currentColor` strokes. Do
not embed the author's published SVGs: they are flattened path data with
hardcoded `rgb()` colours and no text elements, and they are © Zheng with no
licence.

## The formalization is read-only

`formalization/` is a pinned submodule of someone else's repository, which
carries **no licence**. Never vendor its sources, copy proof snippets into this
repo, or commit changes inside the submodule.

## Verso markup gotchas (learned the hard way)

- **Bold is `*text*`, not `**text**`.** Verso uses `_` for emphasis and `*` for
  bold. `**x**` triggers the `linter.verso.markup.emph` "Unnecessary '*'"
  warning.
- **Inline math is `$`...`` — one backtick to close**, and it overlaps with
  Markdown code spans. Do not "fix" valid `$`...`` into `$`...`$`. Run
  `check_verso_math_delimiters.py` after editing math.
- **TeX prelude macros must use `\providecommand`, not `\newcommand`.** The
  prelude is re-evaluated per math span into a persistent KaTeX macro map, so
  `\newcommand` fails from the second span onward and KaTeX then rejects the
  whole span. See `notes/upstream.md` §2.

## Build costs (measured 2026-08-27, M-series mac, cold)

- `lake update` + mathlib cache fetch: ~1 min (8,232 cached files).
- `lake build RB31EndToEnd`: **~37 min**, 8,374 jobs, 126 modules. Slowest
  individual modules 90–110 s (`UniversalDistinctChartContraction`,
  `GroundedTwistSplit`, `WittShearDistinctPrime`); most of the final assembly
  spine 55–75 s each. Cost is spread evenly rather than concentrated, so there
  is no single file worth optimising around.
- `lake exe vbp build` (cold, includes building Verso itself): ~8.5 min.
- Once the library is built, iterating on one chapter is cheap — which is the
  practical reason for the import-granularity rule above. Only CI pays the full
  cost, so the workflow's dependency cache matters.
