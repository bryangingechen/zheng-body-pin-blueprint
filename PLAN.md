# Blueprint plan

The working plan for this repository. `AGENTS.md` has the conventions; this has
the structure, the decisions and their reasons, and what to do next.

Rendered version (same content, nicer to read, may lag this file):
<https://claude.ai/code/artifact/2ea2bbc5-7dcf-417c-9398-fc63253b92a8>. **This
file is the source of truth.**

## What this blueprint is for

The formalization is already complete — no `sorry`, no custom axioms, axiom
closure exactly `propext`, `Classical.choice`, `Quot.sound`. So this is not a
coordination blueprint. Its job is to let a reader check, statement by
statement, that the Lean development proves *the paper's theorem*, and to make
visible where the Lean route departs from the written argument.

**Coverage and correspondence are the deliverable; progress percentage is not.**

Three consequences: nodes are graded by documentation state rather than proof
state (`AGENTS.md`, tags); the paper's own statements sit as verbatim `tex`
witnesses next to each node; and divergences get a fingerprinted register
(`lt-source-deviations.toml`) rather than a footnote.

## The mathematics, briefly

The paper settles Király–Tanigawa Conjecture 5 (still listed as Conjecture 7.6
by Jackson–Jordán–Villányi as of July 2026): a body–pin graph is generically
rigid in R³ iff every partition of the bodies into *t* blocks satisfies
`Σ ℓ(Pᵢ,Pⱼ) ≥ 6(t−1)`, with pin-bundle capacities 3, 5, 6. It does not route
through the C¹₂ cofactor matroid; it goes directly at the 3-dimensional rigidity
matrix via a stress–codimension theorem for (2,2)-sparse graphs, whose
degree-three deletion step forces a collinear neighbour triple and so requires
carrying *collinearity flags* through the induction.

## Decisions already made

| Decision | Choice | Why |
|---|---|---|
| Release line | verso-blueprint `v4.29.0` | The formalization decides the toolchain (also the harness's own rule, enforced by `check_harness.py`). Costs: no `--pdf`, no `source_document` PDF spans, no `:::proposition`, unmaintained line. Porting to `4.33` later is a separate ticket; the directive surface is nearly identical. |
| Upstream linkage | git submodule + path `require` | Portable (submodule pins a SHA), keeps the pinned proof SHA in this repo's history, gives the coverage script a stable path. Directory is `formalization/`, not `RB31EndToEnd/`, so it cannot shadow module paths. |
| Harness | adopt, in no-TeX mode | No LaTeX source exists. `lt.default_chapters = []` disables the source-fidelity half; everything source-independent stays on. |
| Figures | redraw as inline SVG | The author's published SVGs are flattened path data with hardcoded `rgb()`, no text elements, and © with no licence. |
| Labels | semantic, not paper numbers | Numbering shifts between preprint revisions. |

## Chapter structure

Nine content chapters. Seven track the paper; two do not — one for the sparsity
infrastructure the Lean proof needed and the paper waves through, one for the
audit. Node counts are targets. See `correspondence.toml` for what goes where.

| # | Chapter | Paper | ~Nodes | Notes |
|---|---|---|---|---|
| 01 | `Statement` | §1, A.1 | 12 | **Written (Phase 1):** 9 nodes, all with witnesses. Asimow–Roth is a `gap`. |
| 02 | `Necessity` | §6.1, §6.4 first half | 8 | **Written (Phase 2):** 6 nodes. One paragraph on paper, 894 Lean lines, two thirds of them genericity. |
| 03 | `Sparsity` | §2.1 + Lean-only | 10 | **Written (Phase 2):** 6 nodes. 2,811 lines with no paper counterpart, and the root theorem uses almost none of them. |
| 04 | `Deletion` | §2.2 | 12 | **Written (Phase 2):** 9 nodes. Exact sequence, ledger, the missing defect Δ. |
| 05 | `Flags` | §3 | 16 | **Stubbed:** 12 nodes. The heart. Vocabulary table first — every Lean name here is renamed. |
| 06 | `Strata` | §4 | 3 | **Stubbed:** 3 nodes. **Deliberately short.** See below. |
| 07 | `SplitKlein` | §5 | 14 | **Stubbed:** 7 nodes. Plus the Lean-only weight apparatus. |
| 08 | `BodyPin` | §6.2 onwards | 14 | **Stubbed:** 6 nodes. Matroid-union deviation shown beside Lean's substitute. |
| 09 | `Correspondence` | — | 6 | **Stubbed:** 1 node + section skeleton. Table, glossary, deviations, trust boundary, reverse index. |

Node counts in the fourth column are the original targets. Chapters 02 to 04
came in under them, at 6, 6 and 9 against 8, 10 and 12, because §2.1 and §2.2
have fewer separable statements than the estimate assumed and because the
Lean-only material there is two clusters rather than four. Coverage is what
matters, not the count.

Paper §6.1 moved from Chapter 08 to Chapter 02 during Phase 2: its two lemmas
are what §6.4's necessity argument is stated in, and the chapter table above
already assigned §6.1 to `Necessity`. The twist-equality partition stays in
Chapter 08 with §6.2 to §6.4, which is the only part of §6.1 the sufficiency
direction needs.

Stubs carry no `(lean := ...)`. The `lean` names in `correspondence.toml` for
chapters 05 to 09 are still unverified claims, and `strictResolve` turns a wrong
one into a build error the moment a node cites it — which is the right time to
find out, i.e. when that chapter is written, not now. Three of them turned out
to be wrong about namespaces while Phase 2 was checking neighbouring entries;
the `verified = true` flag in the table is what separates a resolved name from
a claim.

### Chapter 06 is a route comparison, not a summary of §4

Paper §4 recasts the inequality geometrically: determinantal degeneracy loci
`Σₛ(F)`, the universal infinitesimal-motion cone, local complete intersection,
Cohen–Macaulay. **None of it is formalized.** Do not work through the material.
The chapter has exactly one job: state what §4 claims, state that Lean uses the
field-theoretic inequality instead, exhibit the equivalence the paper itself
proves (`(1.5) ⟺ (4.7)`, the only mapped part), and confirm Theorem 1.1 never
depends on the scheme statements. Keep it clearly marked rather than omitting
it — a reader's first question about a scheme-theoretic section with no Lean is
"was this skipped?", and the blueprint should answer that in place.

## Vocabulary: the paper and Lean do not share names

Chapter 05 is unreadable without this. Put it at the top of that chapter and in
the Chapter 09 glossary.

| Paper | Lean |
|---|---|
| collinearity flag | provenance flag |
| support triple `T_γ` | terminals (`State.terminals`) |
| private support vertex | `State.privateVertices` |
| auxiliary vertex `g_γ` | ghost vertex (`ghostEdge`); completion on `V ⊕ Flag` |
| base-graph vertices/edges | live vertices / live edges (`liftLiveEdge`) |
| stress–codimension inequality | semismallness budget (`FunctionFieldBranch.SemismallBudget`) |
| self-stress space, `dim ker Dᵀ` | `DirectionStress.directionStressDim` |
| local increment `u + δᵥ` | payment / payment failure |

## Going deeper later without a relabelling migration

Forty-three modules of provenance charts, universal charts and localization
plumbing sit under Prop 6.5 and Thm 1.3. First pass covers them with cluster
nodes. Four mechanisms make deepening cheap; all are free now and impossible to
retrofit:

1. **Name cluster nodes after the paper's proof step, never a module family.**
   `exceptional_pin_parameters` can split while keeping its label on the step it
   names; `incidence_chart_modules` has nothing to keep.
2. **`:::group` for families.** Structural metadata only, no graph edges, not a
   reference target — so a family gains nodes without breaking anything.
3. **Module inventory lives in `correspondence.toml`, not `lean :=`.** `lean :=`
   holds one to three representative declarations so the rendered panel stays
   readable. Deepening = move `modules` rows to a new entry; the coverage
   contract does not change, and the checker catches anything dropped.
4. **`autoDeps` is the escape hatch.** Off by default. Turn it on for one file
   when deliberately deepening a family, review the inferred edges, then decide.

Chapter 09's reverse index is where the dial is visible: promoting a table row
to its own node is the deepening operation. Whether any family needs it depends
on the audience — auditing wants per-module detail, reading does not — so stay
at cluster level and let demand decide.

## Phases

**Phase 0 — prove the toolchain works. DONE** (commit `c66f218`).
`ci-pages.sh` green (8600 jobs), `check_harness.py` clean, generated site ok.
Six nodes, eight declaration references resolving under `strictResolve`, root
theorem rendering its kernel-checked signature and a *complete* status. Two
upstream template gaps found and written up in `notes/upstream.md`.

**Phase 1 — statement, front matter, scaffolding. DONE** (commits `d051f78`
through `c0d9165`). Chapter 01 written in full: 10 nodes, each `paper`-tagged one carrying a hand-transcribed `tex`
witness. Front matter on the index page — conjecture history, scope statement,
tag legend, provenance caveats, and the research note as the reader's on-ramp.
`README.md` rewritten. `Bibliography.lean` holds all 31 of the paper's
references plus the paper, the note, and the Lean development, and
`{blueprint_bibliography}` renders them. Eight chapters stubbed with titled,
tagged nodes. Prelude trimmed to macros that are actually used.

Two structural decisions taken here, both recorded in `correspondence.toml`:

- **Theorem 1.1 and Theorem A.1 are separate nodes.** They are separate
  statements — one about generic rigidity in the usual sense, one about
  attained maximum rank — and conflating them is exactly the confusion this
  blueprint exists to prevent. `formal_statement` carries the Lean anchor and
  is complete; `bodypin_partition_characterization` depends on it and on
  `asimow_roth`, and so reads as not-fully-formalized. That is the honest
  rendering.
- **A `gap` tag**, so node tags and `correspondence.toml` statuses stay in
  one-to-one correspondence. Asimow–Roth is the only member.

Four of the paper's references were read directly during this phase, which
corrected the Asimow–Roth node: they prove a rank equality at a regular point,
and their "regular point" is exactly the maximum-rank placement the
formalization uses. `notes/attribution.md` records what was checked and what is
still taken on the paper's report.

Conventions were then split by directory — root `AGENTS.md` for repo policy,
`BodyPinBlueprint/AGENTS.md` for chapter authoring, `source/references/AGENTS.md`
for the local reference PDFs — so a task only loads what it needs. The root file
also drops the harness's LT source-fidelity instructions, which cannot apply
without a TeX source and previously had to be read before the section explaining
that they do not apply.

A reader-facing pass then fixed three things that would have misled anyone
checking the blueprint against the paper: blueprint numbering was leaking into
prose that talks about paper results, so every cross-reference is now written
out in words; nothing marked a stub chapter as a stub; and quoted Lean carries
an `open ... in` line that upstream does not have. `BodyPinBlueprint/STYLE.md`
and `scripts/style-check.py` came out of the same pass.

Phase 1's original exit criterion said "deployed to Pages". That has been
deferred deliberately: publishing waits until a first full version of the
blueprint exists, so the site is not deployed and there is no git remote. It
blocks nothing. Everything the workflow would do passes locally — `ci-pages.sh`
green at 8609 jobs, submodule pins correct for a fresh clone — so deployment
should be a matter of adding a remote when the time comes.

**Phase 2 — necessity, sparsity, deletion. DONE.** Chapters 02–04 written in
full: 21 nodes, every `paper`-tagged one carrying a hand-transcribed witness,
four proof blocks, and every `lean` name resolved under `strictResolve`. The two
habits the rest of the blueprint runs on are established: a witness adjacent to
its node, and cluster nodes for Lean-only infrastructure.

`scripts/coverage.py` was written here and is in CI, as its own fast workflow
ahead of the Pages build. It enforces the node/entry correspondence, agreement
between node tags and table statuses, existence of every module named, and that
every fingerprint in `lt-source-deviations.toml` still matches its witness. The
register now has twelve entries, eight of them fingerprinted; the four without
are the ones that cannot have one, and the file says which and why.
`scripts/checks.sh` collects the whole no-build check list.

The phase's real find was that module inventories cannot be assembled by
reading imports. `scripts/reachable.lean` walks the constant dependencies of the
root theorem through the kernel environment and reports what it actually uses:
1,385 of 2,555 declarations, with ten modules contributing nothing. That caught
two wrong module lists in Chapter 01, and it corrected this plan's own
description of the sparsity chapter. The 2,811 lines of construction theorem
under `Sparse22/` are not what Lemmas 2.1, 3.7 and 3.8 rest on — the reduction
disjunction, the graph-extension quotient and the tight completion are
unreachable from the root theorem, and Lemma 2.1's Lean proof is an independent
tight-set obstruction argument. `notes/reachability.md` has the method, the
table, and the seven `NullCellule` modules that Phase 4 will have to account
for.

Three `lean` names in `correspondence.toml` were wrong about namespaces and are
now fixed, two of them in chapters not yet written. Two further deviations were
found and registered: the addable-edge criterion is proved in Lean without
supermodularity, and the paper's defect Δ has no counterpart at all — the
inequality it defines appears only as the flagged semismallness budget.

*Exit met:* deviations register populated; coverage checker in CI.

As of the end of Phase 2 the blueprint's 59 nodes and the 59 labelled entries of
`correspondence.toml` are in exact one-to-one correspondence, chapter for
chapter. `scripts/coverage.py` checks that on every run, so it can no longer
drift silently.

**Phase 3 — collinearity flags.** The declaration-body pass is done, which was
the point of doing it first: Chapter 05 will be written under a settled rule
and an enforced one, so every `def` and `abbrev` it names carries its body and
`scripts/coverage.py` says so without a reviewer.

The prose pass is done as well; it is written up under "Open, not blocking".
`BodyPinBlueprint/STYLE.md` now carries a standard measured against the sources
rather than asserted, and `scripts/style-check.py` fails `checks.sh` on the two
constructions it bans.

**NEXT: Chapter 05.** Vocabulary table first, then flag definitions, forest,
selection, pivot, classification, augmentations, Thm 3.9. Longest chapter,
heaviest translation load.

What the quoting check will ask of Chapter 05 is already visible, because the
table's `lean` names classify without a build. Of the eight the flags entries
claim, `State` is a structure and six are theorems, all exempt by kind;
`State.CompletionSparse` is a `def` and will need a fence. Chapter 07 has one
more, `Twist.splitKlein`. Nothing chapters 05 to 08 currently claim is
unclassifiable, so the scan's warning path is still untested — the first case
will be a node naming a structure projection or a Mathlib constant, and a
warning there is correct rather than a defect. What it must not become is a
habit of ignoring the line.

Two things carried over from Phase 2. `Deletion.lean` describes the semismallness
budget as the only home of the paper's defect, so Chapter 05 has to state it
properly and the deviation entry on `(2.4)-(2.6)` points at it. And Chapter 03's
`lean_nixon_owen_reduction` node claims that Lemmas 3.7 and 3.8 do not rest on
the construction theorem either; the flags chapter is where that gets checked
against the actual proofs rather than against the reachability table.

*Exit:* the induction in `provenanceFlag_semismallness` is readable from the
blueprint alone.

**Phase 4 — route comparison, Split–Klein, assembly.** Chapters 06–08.
*Exit:* every paper-numbered result has a node; no `unwritten` outside Ch 09.

**Phase 5 — audit, figures, polish.** Chapter 09 in full. Redraw the three
figures. Clear coverage warnings. Then decide on porting to the current release
line for PDF output and possible upstream reference-blueprint status.
*Exit:* coverage checker clean; every module reachable from the root theorem
named by some node.

## Practical notes

Build costs and the authoring loop are in `AGENTS.md`. The short version: do not
iterate with `ci-pages.sh`. `bash ./scripts/checks.sh` is the fifteen-second
check list and is what CI runs. `python3 scripts/preview.py` renders the whole
document without the formalization in 6–26 s, and the `lean-lsp` MCP server
re-checks a chapter's elaboration in about 8 s. `ci-pages.sh` is the ten-minute
gate that checks everything the fast loops cannot — declaration panels, hovers,
highlighted Lean, node status — so background it, and never read a rendered page
without `python3 scripts/check-fresh.py` reporting `current` for it.

## Open, not blocking

- Pages deployment, deferred until the first full version of the blueprint
  exists. Needs a git remote and someone with the account.
- Licence on the formalization repository, and whether an arXiv version of the
  paper is planned. Both are questions for the author; see
  `notes/attribution.md`. Bryan has an open thread with him.
- Whether the Incidence/Algebra chart layer ever needs per-module nodes.
- Whether to port to `4.33` once the content exists. Note that it would not buy
  declaration bodies in the panels: neither release line renders them, and
  `notes/upstream.md` §8 has the evidence and the routes if it is ever wanted.
- **Declaration bodies: done.** A body is no longer copied into a chapter. `scripts/extract-bodies.sh` runs SubVerso's
  `subverso-extract-mod` over the 15 modules holding a `def` or an `abbrev` a
  chapter names, and a ```BodyPinBlueprint.bodies fence names declarations
  instead of quoting them. `BodyPinBlueprint.quotedBodyJs` then splices each
  body's *value* onto the end of the panel's generated signature, so the panel
  keeps the full name, universe levels and `variable`-supplied binders and gains
  the value, which is the only part the signature lacks. `notes/upstream.md` §8
  has the mechanism and why it is not post-processing.

  That commit converted all nine existing blocks, across the four chapters that
  quote anything, and added a tenth in Chapter 01: twenty-five declarations at
  the time, fifteen of them spliced into the panel that declares them and ten
  standing in the prose because no node names them. Counted from the built HTML,
  not inferred; the current totals are under the rule below. Every `-show`
  scaffolding block is gone, `scripts/check-snippets.py` reports zero, and it
  stays only so that a copy cannot drift if a fragment ever has to be quoted
  that cannot be extracted. Two habits changed with it: a chapter
  imports `BodyPinBlueprint.Bodies` and the module its names come from, and
  `extract-bodies.sh` collects names from the fences as well as from
  `(lean := ...)`, so naming a declaration is what puts its module on the
  extraction list. That last one was luck until it was fixed — every body quoted
  so far happened to sit in a module some node also cited.

  The value boundary comes from the parse rather than from the text, which was
  the second item on this list and did **not** land where it was planned. The
  plan was to reparse `code.toString` in Lean, where `declValSimple`,
  `declValEqns` and `whereStructInst` name the three forms; that works, but the
  boundary would then have to reach the DOM, and Verso offers no way to mark a
  run inside a rendered block. It is not needed: SubVerso already records on
  every keyword token the production it belongs to, so a rendered `where` says
  `kw-occ-Lean.Parser.Command.whereStructInst-3348` and the real parse is in the
  page. `:=` and `|` carry nothing — SubVerso emits a keyword token only for an
  atom starting with a letter — so no route would have given them a production,
  and they stay token searches. Checked over the extracts rather than on a page:
  of the 118 `def`, `abbrev` and `instance` commands in the fifteen extracted
  modules, the rule moves the boundary on exactly the twelve written with
  `where` and leaves the other 106 alone. It changed nothing visible when it was
  written, and the rule below made it load bearing: `connectingMap` and
  `directionEquilibrium` are both quoted now, both are `LinearMap`s written with
  `where`, and both are spliced, so without it the deletion chapter would render
  two bodies beginning at `toFun z :=`. A `structure` is now refused outright,
  since its `where` and its field defaults read exactly like a value.

  Proof obligations are elided as `⋯`, the way `pp.proofs` does it, in
  `Bodies.lean` and not in the script — `Meta.isProp` needs the environment. A
  `where` field is an obligation exactly when its projection lands in `Prop`,
  which is a question about the projection and not about the text:
  `SimpleGraph.Adj` and `SimpleGraph.symm` are written identically, and what
  separates them is that `Symmetric self.Adj` is a proposition while `Prop` is
  not one. Eliding by syntax would have been wrong in both directions, since
  `rigidityOperator` and `genericRigidityRank` are data given by `by` blocks.
  Field names arrive already resolved by SubVerso, so the parent chain
  (`toFun` and `map_add'` are on `AddHom`, not `LinearMap`) costs nothing.

  This is the one place a parse is needed, and it is the route the second item
  above did not take: a field's `:=` carries no binding, so nothing short of
  reparsing `code.toString` says where one field stops. It runs only for a
  `where` declaration — the only one of the twenty-five the chapters quote — and
  reports a failure rather than swallowing it, since a body that quietly kept
  its proofs would look like one that had none.

  Chapter 01 shows the result: `bodyClique` goes from eight lines to seven with
  `symm` and `loopless` replaced by `⋯`, so what is left is the adjacency
  relation the surrounding paragraph describes, and `bodyPinGraph` beside it is
  the one line that makes "definitionally the supremum of its body cliques"
  checkable. `AGENTS.md`'s rule loosens accordingly: bundling is no longer a
  reason on its own not to quote, though what survives elision still has to earn
  the block.

  Facts worth not re-deriving, several of which corrected a first guess:
  extraction is ~47 min cold, mean 189 s per module, dominated by imports rather
  than module size; `defSite := true` in `Bodies.lean` is load bearing, because
  it is what emits the `id` the splice joins on; the extracted bodies omit the
  binders a `variable` block supplied, the universe levels and the namespace
  qualification, but *not* the explicit arguments — which is why the value is
  spliced onto the generated signature rather than replacing it; and extracted
  blocks carry their docstrings, where hand-quoted ones did not, which is why
  the ten blocks still standing in the prose now open with the author's own
  one-line description of each definition.

- **Every named definition is quoted, and the rule is a check. Done.**
  Decided 2026-08-28, replacing the taste criterion that produced fifteen quoted
  definitions out of thirty-one named ones with no principle separating them.

  *The rule.* Every `def` and `abbrev` a node names gets its body quoted.
  Closed exceptions: a structure or inductive (the panel renders its fields, and
  its `where` reads exactly like a value), a theorem (the value is a proof), and
  an explicit opt-out carrying a one-line reason. Size is measured on the
  **value**, never the declaration, and is never a reason to omit; a long value
  is folded by default instead.

  The sixteen are in — five in Chapter 01, two each in 02 and 03, seven in 04 —
  and every one sat in a module already extracted, so this cost no build time.
  The document now fences forty-one declarations: thirty-one named by a node and
  spliced into its panel, ten standing in the prose because no node names them.
  The opt-out list is empty, and that is the finished state.

  *Two things the measurement corrected, both of which had made the old
  criterion look reasonable.* Raw declaration length is the wrong number: the
  body is spliced onto the panel's generated signature, so the reader gains the
  value alone, and `deletedConnectingClass` is nine lines of which five are a
  type the panel renders better. And elision moves the rest —
  `directionEquilibrium` is eighteen lines raw and four as it appears. On the
  sixteen, the longest value is `HasNixonOwenReduction` at six lines and
  everything else is one to four, so nothing came near the ten lines where
  folding would start to matter.

  *One reason retired, deliberately.* "Its value names something no node
  explains" no longer excuses an omission. Every token in an extracted body
  hovers with its signature and docstring and links to the pinned source, so a
  name the reader can hover is not dead text; `HasNixonOwenReduction` ships with
  its four `LegalInverse` predicates on that basis.

  *The check.* `scripts/coverage.py` fails on a node that names a `def` or an
  `abbrev` with neither a fence in its own chapter nor a `[[body_optout]]` row,
  on a row with no reason, and on a row excusing a declaration no node names. It
  runs in the fifteen-second list and in the fast CI workflow, neither of which
  has a built formalization, so it reads the kind off the pinned submodule's
  source: namespace-tracked, one pass, 1,913 declarations. That reading is not
  taken on trust — `kinds_agree` compares it against `_out/body-modules.json`
  whenever a build has left one, and a disagreement is an error saying the scan
  needs fixing before its verdict can be believed. It agrees with the kernel on
  all seventy-two names the document mentions today. A name the scan cannot
  classify is a warning rather than an error, since a structure projection is a
  legitimate thing for a future node to name and is not a source-level
  declaration; chapters 05 to 09 will produce the first ones.

  *One defect the sixteen exposed, found on the built page.* An elided
  obligation written `map_add' := by ...` kept its `.tactics` wrapper, and Verso
  renders that wrapper as a toggle whose label is the elided text — so the `⋯`
  *was* the control that expanded the goal state the elision existed to remove.
  Nothing showed it before, because `bodyClique` was the only `where`
  declaration quoted and its `loopless` value is `⟨by ...⟩`: the range starts at
  the `⟨`, outside the tactics node, and consumed it whole. `connectingMap` and
  `directionEquilibrium` write the `by` directly and did not. `Bodies.lean` now
  drops a `.tactics` or `.span` wrapper that elision has left with no token to
  annotate. A `by` block that is the declaration's *value* keeps its toggle, as
  `rigidityOperator` and `genericRigidityRank` do; those are data.

  Rereading the prose against the bodies was half the work, and it found the
  duplication it was meant to. `rigidityOperator`'s docstring already said what
  the paragraph beside it said about doubling and comparable ranks;
  `genericRigidityRank`'s already named `rigidityRank_le_velocityFinrank`;
  `groupedGroundedBlockOperator`'s already said why internal pins are dropped.
  Those sentences are gone from the prose, which now says what the bodies do
  not: where the grounding sits inside the operator, that the row space spans
  the edges of $F$ rather than all pairs, and that the active-vertex count in
  front of the Nixon-Owen disjunction is the measure the induction descends on.

- **General prose review, and a stronger style guide. Done.** Raised
  2026-08-29 by Bryan, reading the rendered site: the register was off across
  the document rather than in a few places. Three things were reported — a
  section title phrased as a sentence ("The construction theorem the
  formalization carries"), proof-engineering idiom standing in for mathematics
  ("closes the low-degree branches"), and a page that is simply hard to follow.

  *What the measurement found.* Two constructions — *X is what makes Y* and *X is where Y happens* — occur 28
  times in the 10,449 words of blueprint prose and **zero** times in the 66,307
  words of the paper and its four reference papers. So do the idioms: *earn
  their place*, *part company*, *put to work*, *on the nose*, *for free*,
  *headline* — 0 for 66,307 across all five documents. The sources' whole stock of
  connectives is *thus* (130), *hence* (125), *therefore* (41), *note that* (33)
  and six rarer ones; this document had used *thus* not once. That comparison
  turned a matter of taste into a rule, and it is written into the guide so the
  next writer does not have to re-derive it.

  *The standard.* `BodyPinBlueprint/STYLE.md` was rewritten around one diagnosis:
  the prose kept naming a fact's *role* instead of stating the fact. Both
  constructions above are always removable, and removing one shortens the
  sentence and forces the reason into the open, so they are banned rather than
  budgeted — a budget was considered and rejected once every case turned out to
  have a plain rewrite. The cleft (*What X shows is Y*) keeps a budget, because
  a genuine contrast earns it. Three further sections were added: one on
  proof-engineering idiom, with the test "could a mathematician who has never
  used a proof assistant read this sentence for the argument?"; one on headings
  as noun phrases; and two moves to try before reaching for a frame.

  *The rewrite.* All 28 occurrences are gone, along with every idiom above,
  across the four written chapters, the five stubs and the index page. The
  offending section title is now "A construction theorem with no paper
  counterpart". The paragraph Bryan found hard to follow was hard to follow for
  a reason the register hid: "closes the low-degree branches" and "the long
  triangle-sequence branch is replaced" both refer to a proof structure the
  reader has never been shown, so the section now says which case is proved
  outright, which one ends at a named $K_4$, and what `GraphExtension.lean`
  replaces.

  *Two errors of fact the pass turned up*, neither of them a register problem.
  Chapter 05 opened "This is the chapter the paper is named for" — the paper is
  *Stress Degeneracy of Direction Complexes of (2,2)-Sparse Graphs and
  Three-Dimensional Body–Pin Rigidity*, and it is the research **note** that
  names collinearity flags. And Chapter 07 had twists living in $k \oplus k^3$,
  which is a `pdftotext` line-break artifact of `k 3 ⊕ k3` in the text layer;
  §5 says six-dimensional $k^3 \oplus k^3$. Reading for register is a cheap way
  to find these, because it means reading every sentence for what it asserts.

  *The check.* `scripts/style-check.py` now reports two severities. The two
  banned constructions are **errors**, and `checks.sh` passes `--strict`, so one
  fails the fifteen-second list and CI with it. Everything else is a warning:
  idiom, proof-engineering vocabulary, a heading containing a finite verb, three
  em dashes in a paragraph. `--pedantic` fails on warnings too, which is the
  mode for revising one chapter. Both new checks were verified to fire on the
  exact text that was reported and the document is clean at 0 and 0.

  Encoding the checks before deciding the standard was deliberately avoided: it
  would have flooded four chapters with warnings against a register nobody had
  agreed, and biased the standard towards whatever is easy to grep for.

- **`ci-pages.sh` does not clean its output directory.** Found 2026-08-29 while
  verifying the prose pass: renaming a section heading leaves the old page and
  its search-index shard behind in `_out/site/html-multi`. The rename in the
  sparsity chapter left exactly two orphans — the old
  `The-construction-theorem-the-formalization-carries/index.html` and
  `-verso-search/searchIndex_79.js` — and nothing in the current site links to
  either, so `check-rendered.py` did not see them. They were deleted by hand.
  Harmless locally, but a first Pages deploy would ship a dead duplicate page
  and a stale search entry, so decide before deployment: either `rm -rf` the
  output directory at the top of `ci-pages.sh`, or clean in the workflow.
  Not fixed here because it is a build-script change outside the prose pass and
  cannot be verified without another ten-minute build.

- **Two decisions left open**, neither blocking:
  - *Whether the prose should name each quoted body's source file.* Settled for
    the reader, still open per block. Chapter 01 now says once, where the first
    quoted body appears, that quoted Lean is the pinned formalization's own
    source and that the panel's source link is how to check it against the
    repository it came from. That covers the thirty-one blocks a node names. The
    ten that stay in the prose still have no link of their own, and whether each
    of those deserves its file named in the surrounding sentence is unresolved;
    some sentences name it and some do not.
  - *The block styling itself*, in `BodyPinBlueprint/Style.lean`. The left rule
    is the opinionated part.
