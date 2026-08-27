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
bash ./scripts/check-source.sh      # is the right paper revision present?
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
- `tex` witness blocks are hand-transcribed from the paper. Transcribe from
  `source/paper.txt` (the `pdftotext -layout` output), not by eye from a
  rendered page, and treat "witness matches the paper" as an explicit review
  item — no script will check it for you.
- A witness must sit *immediately* after its node: `check_blueprint_node_kinds.py`
  pairs positionally, not by label. Label it anyway, so it attaches to the node
  in the manifest.
- The text inside a witness is the paper's; the environment around it is a
  reconstruction, because there is no LaTeX to copy. Where the paper really has
  a numbered environment, use that exact kind. Where it defines something in
  running prose, wrap the paper's own sentences in `definition` — the node-kind
  checker requires a graph-visible environment next to a graph-visible node, and
  a reconstructed wrapper is the honest way to satisfy it. Say so in the
  chapter's leading comment.
- Do not invent `\label{...}` in a witness. We do not know the paper's labels,
  and an invented one would make `check_source_label_grounding.py` compare our
  node ids against fiction. No label means no comparison, which is correct here.
- Nodes tagged `gap` or `lean-only` carry no witness: there is no paper
  statement to quote. Every `paper`-tagged node has one.
- `source/` is gitignored apart from its README: the paper is not ours to
  redistribute. Run `bash ./scripts/check-source.sh` before writing prose; it
  verifies `source/paper.pdf` against the hash in `correspondence.toml` and
  regenerates the text layer. A hash mismatch means the paper revision changed
  and the correspondence entries need re-checking before they are cited.

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
- `gap` — cited by the paper, not formalized, and not ours to prove
  (Asimow--Roth is the only one)
- `unwritten` — node stubbed, prose not drafted. Removing the last `unwritten`
  is the definition of done.

The tag vocabulary deliberately mirrors the `status` values of
`correspondence.toml` one-for-one, so the table and the rendered graph can be
read against each other. Add a tag only by adding the matching status, and vice
versa.

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
- **Titles and headings are plain ASCII.** Every one of them — the document
  title, chapter titles, in-chapter headings — becomes part of a URL, and every
  non-alphanumeric character turns into `___`: "The body–pin model" becomes
  `The-body___pin-model`, and "Assembly: the body–pin theorem" becomes
  `Assembly___-the-body___pin-theorem`. The document title is not exempt: it
  prefixes every section anchor on the site. Write them with letters, digits,
  spaces and hyphens only, and save en dashes, colons and quotation marks for
  the prose.
- **A node body is the statement and nothing else.** It is what the graph and the
  hover previews show, so a reader following an edge should land on the claim,
  not on an essay about it. Rationale, Lean's representation choices, what a
  convention costs, cross-references — all of that is chapter prose *after* the
  node's `tex` witness. A node keeps one located citation, at the end.
- **Cite; do not narrate provenance you have not established.** "The paper cites
  X at this point, and the definition there agrees" is checkable. "The term
  comes from X", "the notation is inherited from X", "this is not a workaround"
  are claims about coinage, transmission and intent that a citation does not
  support and that we are usually in no position to make. When in doubt, give
  the reference and stop.
- **Mention a Lean declaration with the `name` role, not a bare code span.**
  `{name RB31E2E.BodyPinIncidence.privateCoreVertex}`privateCoreVertex`` renders
  the short name but carries the full one, so the reader gets the signature and
  docstring on hover; a plain `` `privateCoreVertex` `` is dead text. The role
  needs `open Verso.Genre.Manual.InlineLean` in the chapter header, and it fails
  the build on an unknown constant, which is the point — it keeps prose
  references as honest as `(lean := ...)` ones. Only for real constants: `sorry`
  and `admit` are not, and file paths and option names stay plain code spans.
- **Every `paper`-tagged node ends with a located citation, never a bare tag.**
  `{Informal.citep "zheng2026" (kind := "lemma") (index := "3.4")}[]` renders
  "(Zheng, 2026, Lemma 3.4)" — and, more usefully, turns the bibliography page
  into a reverse index, because its usage panel then reads "Chapter 5:
  Collinearity flags, Lemma 5.5 - Cites Lemma 3.4". Do not write
  "Paper Lemma 3.4.": it renders as prose and carries no metadata.
  `kind` accepts only `chapter`, `section`, `theorem`, `lemma`, `corollary`,
  `page`, `equation`, `figure`. The paper's definitions, propositions and
  examples have no matching kind — drop `kind` and put the whole locator in
  `index`, as `(index := "Proposition 3.3")`. See `notes/upstream.md` §6.
- **In running prose, spell the reference out and use `citet`:** "Section 2.1 of
  {Informal.citet "zheng2026"}[] is two paragraphs". Every chapter opening does
  this. Do not open a sentence with a locator tag — "Paper §2.1 of Zheng (2026)"
  is not a sentence.
- **`citep` brings its own parentheses; `citet` does not.**
  `{Informal.citep "laman1970"}[]` renders `(Laman, 1970)` and
  `{Informal.citet "laman1970"}[]` renders `Laman (1970)`. So never wrap a
  `citep` in literal parentheses — that gives `((Laman, 1970))` — and never put
  a `citet` inside them either, which gives `(Laman (1970))`. Parenthetical
  aside: use a bare `citep`. Citation as part of the sentence: use `citet`.
- **`--` is not an en dash.** Verso passes it through literally, so
  `body--pin` renders as "body--pin". Use the character `–` in prose. Inside a
  `tex` witness `--` is correct LaTeX and must stay.
- **Module docstrings in a chapter are Verso documents.** With
  `set_option doc.verso true`, a `/-! ... -/` header block is elaborated as
  Verso markup, so every backticked path or word in it draws a
  "Code element could be more specific" warning. Use a plain `/- ... -/`
  comment for chapter headers; keep `/-- ... -/` for real docstrings.
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
