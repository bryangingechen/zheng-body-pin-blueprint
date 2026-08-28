# Writing a chapter

Conventions for the blueprint modules in this directory. Repo-level policy —
what the blueprint is for, why there is no TeX source, the harness, build costs
— is in the root `AGENTS.md`; read that first if you have not.

`Chapters/Statement.lean` is the worked example. Copy its shape.

`STYLE.md` next to this file is the register: what blueprint prose should sound
like, calibrated against the papers themselves, with the failure modes that have
actually occurred here. Read it before writing prose, and run
`python3 scripts/style-check.py` before committing.

Two fast loops, for two different questions.

**How does it render?** `python3 scripts/preview.py` builds the whole document
without the formalization and writes it to `_out/preview/html-multi`:

| | |
|---|---|
| nothing changed | 6 s |
| one chapter changed | 9 s |
| from scratch | 26 s |

against about ten minutes for `scripts/ci-pages.sh`. It generates a stripped
copy of every chapter under `BodyPinBlueprint/Preview/` — both generated and
gitignored — with the `RB31EndToEnd` imports, `(lean := ...)` options, `name`
roles and elaborated Lean fences removed. Everything else is the real document,
so slugs, numbering, citation rendering, cross-reference text, math, the graph,
the summary and the bibliography are all exactly what the site will show.

It cannot show what it has removed: external declaration panels, hovers,
highlighting in quoted Lean, and node Lean-status — the graph and summary paint
every node unformalized. It also cannot catch a wrong `(lean := ...)` name,
because it strips them rather than resolving them. So the preview is for
looking, never for believing a node is wired up.

**Does it elaborate?** Use the Lean language server rather than `lake build`. The
`lean-lsp` MCP server (`.mcp.json`) keeps the imports loaded, so after one cold
start a chapter re-checks in about 8 seconds instead of 169:

    lean_diagnostic_messages(file_path = "BodyPinBlueprint/Chapters/<Chapter>.lean")

It catches the failure this repo cares most about. Under `strictResolve` a wrong
`(lean := "...")` name is an error, and the server reports it with label, line
and column:

    Label pin_capacity: external Lean name 'RB31E2E.pinCapacityTypo' could not
    be resolved in current namespace/open declarations

That matters because most `lean` names in `correspondence.toml` outside
Chapter 01 are still unverified claims. Check them as you cite them; it now
costs seconds.

Then, before committing:

```bash
python3 tools/verso-harness/scripts/check_blueprint_node_kinds.py --project-root . <chapter.lean>
python3 tools/verso-harness/scripts/check_verso_math_delimiters.py --project-root . <chapter.lean>
python3 tools/verso-harness/scripts/check_blueprint_heading_structure.py --project-root . <chapter.lean>
python3 scripts/check-snippets.py
python3 scripts/style-check.py
lake build BodyPinBlueprint.Chapters.<Chapter>
```

and `bash ./scripts/ci-pages.sh` after a coherent batch. Neither fast loop
replaces it: the language server checks elaboration but renders nothing, and the
preview renders but drops every link to the formalization. Anything you intend
to claim about a finished page has to come from a full build. The harness's LT (source-fidelity) scripts are not in that
list on purpose — see the root `AGENTS.md`, "No TeX source".

---

## Witnesses

Every `paper`-tagged node carries a `tex` witness holding the paper's own words.
Nodes tagged `gap` or `lean-only` carry none: there is nothing to quote.

- Transcribe from `source/paper.txt` (the `pdftotext -layout` output), never by
  eye from a rendered page. "Witness matches the paper" is an explicit review
  item; no script will check it for you.
- A witness sits *immediately* after its node — `check_blueprint_node_kinds.py`
  pairs positionally, not by label. Label it anyway so it attaches to the node
  in the manifest. Commentary goes after the witness, not between.
- The text inside is the paper's; the environment around it is a reconstruction,
  because there is no LaTeX to copy. Where the paper has a numbered environment,
  use that exact kind. Where it defines something in running prose, wrap the
  paper's own sentences in `definition` — the node-kind checker wants a
  graph-visible environment next to a graph-visible node, and a reconstructed
  wrapper is the honest way to give it one. Say so in the chapter's leading
  comment.
- Do not invent `\label{...}`. We do not know the paper's labels, and an
  invented one would make `check_source_label_grounding.py` compare our node ids
  against fiction. No label means no comparison, which is correct here.
- **Never quote the blog.** The author's research note
  (<https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/>) is a
  gloss whose wording differs. A witness is *the thing being formalized*, so it
  comes from the paper. Note material goes in ordinary prose and links — never
  into a witness, and never into an `md` witness slot on a node that already has
  a paper witness.
- Reference PDFs are for checking claims, never for witnesses. See
  `source/references/AGENTS.md` locally.

## Node bodies

**A node body is the statement and nothing else.** It is what the graph and the
hover previews render, so a reader following a dependency edge should land on
the claim, not on an essay about it. Rationale, Lean's representation choices,
what a convention costs, cross-references — all of that is chapter prose after
the witness. A node keeps exactly one located citation, at the end.

**Cite; do not narrate provenance you have not established.** "The paper cites X
at this point, and the definition there agrees" is checkable. "The term comes
from X", "the notation is inherited from X", "this is not a workaround" are
claims about coinage, transmission and intent that a citation does not support
and that we are usually in no position to make. When in doubt, give the
reference and stop.

Preserve the paper's order — section order, paragraph boundaries, the order of
labelled results — unless the chapter deliberately merges two parts of the
paper, in which case say so in the leading comment.

## Labels

Semantic and stable, never paper numbers (numbering shifts between preprint
revisions). The paper number goes in the prose and the correspondence table.

- statements: `bodypin_partition_characterization`, `stress_codim_flags`,
  `flag_selection`, `witt_shear_componentwise`
- Lean-only nodes with no paper counterpart: `lean_` prefix, e.g.
  `lean_nixon_owen_reduction`
- Name **cluster** nodes after the paper's proof step, never after a module
  family, so the label survives a later split onto child nodes.

Every node label matches a labelled `correspondence.toml` entry, one to one,
chapter for chapter. That invariant currently holds at 54 for 54; do not break
it silently.

## Tags carry blueprint state, not proof state

`lake exe vbp query work-queue` should read as a to-do list for the exposition:

- `paper` — numbered result from the paper, mapped to Lean
- `informal-only` — in the paper, deliberately not formalized (all of paper §4)
- `lean-only` — in Lean, no paper counterpart
- `deviation` — mapped, but by a different route; has a register entry
- `gap` — cited by the paper, not formalized, and not ours to prove
  (Asimow–Roth is the only one)
- `unwritten` — node stubbed, prose not drafted. Removing the last `unwritten`
  is the definition of done.

The vocabulary mirrors the `status` values of `correspondence.toml` one for one,
so the table and the rendered graph can be read against each other. Add a tag
only by adding the matching status, and vice versa.

## Citations

- **Every `paper`-tagged node ends with a located citation.**
  `{Informal.citep "zheng2026" (kind := "lemma") (index := "3.4")}[]` renders
  "(Zheng, 2026, Lemma 3.4)" and turns the bibliography page into a reverse
  index, whose usage panel then reads "Chapter 5: Collinearity flags, Lemma 5.5
  - Cites Lemma 3.4". Do not write "Paper Lemma 3.4."; it renders as prose and
  carries no metadata.
- `kind` accepts only `chapter`, `section`, `theorem`, `lemma`, `corollary`,
  `page`, `equation`, `figure`. The paper's definitions, propositions and
  examples have no matching kind — drop `kind` and put the whole locator in
  `index`, as `(index := "Proposition 3.3")`. See `notes/upstream.md` §6.
- **`citep` brings its own parentheses; `citet` does not.**
  `{Informal.citep "laman1970"}[]` gives `(Laman, 1970)`;
  `{Informal.citet "laman1970"}[]` gives `Laman (1970)`. Never wrap a `citep` in
  literal parentheses — `((Laman, 1970))` — and never put a `citet` inside them
  either: `(Laman (1970))`. Parenthetical aside: bare `citep`. Citation as part
  of the sentence: `citet`.
- **In running prose, spell the reference out:** "Section 2.1 of
  {Informal.citet "zheng2026"}[] is two paragraphs". Every chapter opening does
  this. Do not open a sentence with a locator tag.
- Cite the upstream references at the points the paper invokes them. Mathematical
  credit runs through the bibliography, and getting that right matters more than
  anything this repository claims for itself.

## Mentioning Lean

- `(lean := "...")` on a node for the declarations it corresponds to. One to
  three representative names, so the rendered panel stays readable; the module
  inventory lives in `correspondence.toml`.
- **Inline, use the `name` role, not a bare code span.**
  `{name RB31E2E.BodyPinIncidence.privateCoreVertex}`privateCoreVertex`` shows
  the short name, carries the full one, and gives the reader the signature and
  docstring on hover; a plain `` `privateCoreVertex` `` is dead text. Needs
  `open Verso.Genre.Manual.InlineLean` in the chapter header, and it fails the
  build on an unknown constant — which is the point, it keeps prose references
  as honest as `(lean := ...)` ones. Only for real constants: `sorry` and
  `admit` are not, and file paths and option names stay plain code spans.
- Prefer a `(lean := ...)` link to reproducing Lean code, and never reproduce a
  proof. `formalization/` carries no licence, so what is quoted here is limited
  to short definition bodies, quoted because they are what the blueprint is
  describing.
- **A node must state the content of its Lean target, because the panel will
  not.** The external-declaration renderer emits the signature, the docstring,
  and — for a structure or an inductive — its fields or constructors. It cannot
  show a definition's body, and there is no option to make it. So
  `def RB31E2E.EndToEndBodyPinStatement : Prop` renders as exactly that, which
  tells a reader nothing. Every `Prop`-valued definition, every
  `pinCapacity`-style table of values, every graph construction: write the
  content out in the node body. Chapter 01 does this throughout.
- **For a key definition, quote the body as well**, in a plain fenced block
  after the witness, first line a comment giving the source path:

  ````
  ```
  -- RB31EndToEnd/Target.lean
  def EndToEndBodyPinStatement : Prop :=
    ∀ (H : BodyPinIncidence) (extra : H.Body → ℕ),
      H.GenericallyRigidInR3 extra ↔ H.PartitionCondition
  ```
  ````

  A plain block, not ```` ```lean ````: a labelled Lean block is *elaborated*,
  so it would redeclare an imported name, and attaching local Lean code to a
  node also feeds that node's proof-status computation. An unlabelled Lean block
  is rejected outright. The plain block displays verbatim and has no side
  effects.

  `python3 scripts/check-snippets.py` verifies every such block against the file
  it names, chunk by chunk, so a copy cannot silently drift from the pinned
  submodule. Run it with the other checks. Keep quotes to definitions that the
  prose is actually about; each one is a maintenance obligation.
- The panel does carry a source link, pinned to the submodule SHA and anchored
  to the declaration's line range — e.g. `Target.lean#L12-L20`. That is how a
  reader checks our restatement against the real definition, and it is why the
  restatement has to be there to check.

## Imports

Chapters import the **specific** formalization modules they reference
(`import RB31EndToEnd.Rigidity.BarJoint`), never the library root — except where
a node genuinely references the root theorem, which lives in the root module.

The formalization is itself mostly granular: of its 126 modules, 92 import no
Mathlib at all and 29 import specific `Mathlib.*` modules. Five do a blanket
`import Mathlib`, and those five are foundational:

    RB31EndToEnd/Specification.lean
    RB31EndToEnd/Rigidity/BarJoint.lean
    RB31EndToEnd/Linear/Vec3Twist.lean
    RB31EndToEnd/Graph/LooplessMultiGraph.lean
    RB31EndToEnd/Incidence/Arithmetic.lean

Reaching any of them transitively costs all of Mathlib. 86 modules do; **40 do
not**, and they include whole families this blueprint needs — all nine
`Combinatorics/Sparse22/*`, seven `Combinatorics/ProvenanceFlag*`, and much of
`Linear/Direction*` and `Linear/Outside*`.

That split is worth real time. Measured on this machine, warm, for a chapter
containing one line of prose and nothing else:

| Chapter imports | Jobs | Wall |
|---|---|---|
| `Combinatorics/Sparse22/Basic` (blanket-free) | 3517 | **47 s** |
| `Mathlib` | 8471 | 101 s |
| `RB31EndToEnd` (the root module) | 8598 | 169 s |

So a chapter that stays inside the blanket-free set builds roughly four times
faster, and the difference is olean loading rather than anything we write — all
of Chapter 01's content costs about 9 s on top of its 169 s import floor.

Before adding an import, check what it drags in:

```bash
lake env lean --deps RB31EndToEnd.Combinatorics.Sparse22.Basic 2>/dev/null | head
```

Chapter 01 has no choice — it references the root theorem, which lives in the
root module. Chapters 03 to 05 largely do have a choice; take it.

Independently of speed, the rule earns its place through auditability: a
chapter's import list states exactly which part of the formalization its prose
depends on, which is the relationship this whole blueprint exists to document.

## Dependency edges

- `uses` for genuine mathematical dependency; `bpref` for navigational links.
- Proof-only prerequisites go on the `:::proof` block, not the statement.
- Infrastructure edges get `(uses_intent := "technical")` so the main spine
  stays legible under the sparsity and weight-apparatus clusters.
- Do not add standalone prose lines that exist only to display an edge; put it
  in `(uses := ...)` on the node.
- `autoDeps` stays **off** by default: 1,851 declarations would swamp the graph
  before the manual spine exists. Turn it on per file only when deliberately
  deepening one family, review the inferred edges, then decide.
- Keep prose as prose unless the source really gives a graph-visible theorem,
  definition, lemma, corollary or proof-style object. `:::theorem` is not a
  generic wrapper.

## Owners

`:::author` / `owner` is triage metadata — who is writing the node — **not**
mathematical credit. Zheng is not an author of this blueprint and must not
appear as a node owner.

## Figures

Redraw as hand-authored inline SVG with theme-aware `currentColor` strokes. Do
not embed the author's published SVGs: they are flattened path data with
hardcoded `rgb()` colours and no text elements, and they are © Zheng with no
licence.

## Verso markup gotchas (learned the hard way)

- **Bold is `*text*`, not `**text**`.** Verso uses `_` for emphasis and `*` for
  bold. `**x**` triggers the `linter.verso.markup.emph` "Unnecessary '*'"
  warning.
- **Inline math is `$`...`` — one backtick to close**, and it overlaps with
  Markdown code spans. Do not "fix" valid `$`...`` into `$`...`$`. Run
  `check_verso_math_delimiters.py` after editing math.
- **`--` is not an en dash.** Verso passes it through literally, so `body--pin`
  renders as "body--pin". Use `–` in prose. Inside a `tex` witness `--` is
  correct LaTeX and must stay. (The `--` still visible on the site comes from
  upstream Lean docstrings, which are read-only; see `notes/questions.md`.)
- **Titles and headings are plain ASCII.** Every one of them becomes part of a
  URL, and every non-alphanumeric character turns into `___`: "The body–pin
  model" becomes `The-body___pin-model`. The document title in
  `BodyPinBlueprint.lean` is not exempt — it prefixes every section anchor on
  the site. Letters, digits, spaces and hyphens only; save en dashes, colons and
  quotation marks for the prose.
- **Module docstrings in a chapter are Verso documents.** With
  `set_option doc.verso true`, a `/-! ... -/` header block is elaborated as
  Verso markup, so every backticked path in it draws a "Code element could be
  more specific" warning. Use a plain `/- ... -/` comment for chapter headers;
  keep `/-- ... -/` for real docstrings.
- **TeX prelude macros must use `\providecommand`, not `\newcommand`.** The
  prelude is re-evaluated per math span into a persistent KaTeX macro map, so
  `\newcommand` fails from the second span onward and KaTeX then rejects the
  whole span. Keep macros in `TeXPrelude.lean`, keep the list short, and keep
  every entry in use. See `notes/upstream.md` §2.
