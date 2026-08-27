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
| 01 | `Statement` | §1, A.1 | 12 | **Written (Phase 1):** 10 nodes, all with witnesses. Asimow–Roth is a `gap`. |
| 02 | `Necessity` | §6.4 first half, §6.1 | 8 | **Stubbed:** 2 nodes. One paragraph on paper, 894 Lean lines. |
| 03 | `Sparsity` | §2.1 + Lean-only | 10 | **Stubbed:** 4 nodes. ~3,500 lines with no paper counterpart. |
| 04 | `Deletion` | §2.2 | 12 | **Stubbed:** 7 nodes. Exact sequence, ledger, defect Δ. |
| 05 | `Flags` | §3 | 16 | **Stubbed:** 12 nodes. The heart. Vocabulary table first — every Lean name here is renamed. |
| 06 | `Strata` | §4 | 3 | **Stubbed:** 3 nodes. **Deliberately short.** See below. |
| 07 | `SplitKlein` | §5 | 14 | **Stubbed:** 7 nodes. Plus the Lean-only weight apparatus. |
| 08 | `BodyPin` | §6 | 14 | **Stubbed:** 8 nodes. Matroid-union deviation shown beside Lean's substitute. |
| 09 | `Correspondence` | — | 6 | **Stubbed:** 1 node + section skeleton. Table, glossary, deviations, trust boundary, reverse index. |

Stubs carry no `(lean := ...)`. The `lean` names in `correspondence.toml` outside
Chapter 01 are still unverified claims, and `strictResolve` turns a wrong one
into a build error the moment a node cites it — which is the right time to find
out, i.e. when that chapter is written, not now.

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

**Phase 1 — statement, front matter, scaffolding. DONE** (commit `d051f78`).
Chapter 01 written in
full: 10 nodes, each `paper`-tagged one carrying a hand-transcribed `tex`
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

**Phase 2 — necessity, sparsity, deletion. NEXT.** Chapters 02–04. Establishes the two
habits that carry the rest: the adjacent-witness pattern, and cluster nodes for
Lean-only infrastructure. Chapter 03 is the first real test of describing 3,500
lines the paper never mentions. Write `scripts/coverage.py` here.

As of the end of Phase 1 the blueprint's 54 nodes and the 54 labelled entries of
`correspondence.toml` are in exact one-to-one correspondence, chapter for
chapter. That invariant is the first thing `scripts/coverage.py` should check,
and it is cheap to keep true if it is never allowed to break.

*Exit:* deviations register populated; coverage checker in CI.

**Phase 3 — collinearity flags.** Chapter 05. Vocabulary table first, then flag
definitions, forest, selection, pivot, classification, augmentations, Thm 3.9.
Longest chapter, heaviest translation load.
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

Build costs and the slow authoring loop are in `AGENTS.md`. The short version:
~37 min for a cold formalization build, ~5 min for a warm `ci-pages.sh`, and
about 10 min for any rebuild that touches an import everything shares. Batch
edits; use the harness's focused chapter build; do not expect fast feedback.

## Open, not blocking

- Licence on the formalization repository, and whether an arXiv version of the
  paper is planned. Both are questions for the author; see
  `notes/attribution.md`. Bryan has an open thread with him.
- Whether the Incidence/Algebra chart layer ever needs per-module nodes.
- Whether to port to `4.33` once the content exists.
