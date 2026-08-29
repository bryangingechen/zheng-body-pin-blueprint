# Reading questions

Questions arising while mapping the paper onto the formalization. These are
*questions*, not claims of error — the formalization is kernel-checked, so where
prose and Lean seem to disagree the likely answer is that we have misread one of
them. Record page/section references so a question can be re-checked cheaply.

Anything that resolves into a genuine paper-vs-Lean divergence graduates to
`lt-source-deviations.toml`. Anything that resolves into a misreading gets
deleted.

## Open

- *A construction theorem the assembly never uses.* `Sparse22/Construction.lean`,
  `TriangleSequence.lean`, `GraphExtension.lean` and `TightCompletion.lean`
  develop the four inverse construction moves for simple $(2,2)$-tight graphs
  over 2,811 lines, and nothing outside that directory uses their conclusions:
  `HasNixonOwenReduction`, the graph-extension quotient and
  `exists_tight22_completion` are all unreachable from the root theorem
  (`notes/reachability.md`). What the development takes from those files is
  edge-set vocabulary and eight counting facts. The likely reading is that the
  material was written first, for an inverse-Henneberg route to the flag
  induction, and that the route taken instead was the direct tight-set
  obstruction argument in `DegreeThreeAugmentation.lean`; that is a guess about
  history and is not checkable from here.
- *Naming of that construction theorem.* `Construction.lean` calls the moves
  the Nixon--Owen reductions. The paper cites neither Nixon nor Owen, and the
  blueprint bibliography is the paper's reference list, so nothing is cited for
  it. A web search suggests the $(2,1)$-tight construction is Nixon and Owen's
  and that the $(2,2)$-tight one is usually attributed to Nixon, Owen and
  Power; *neither has been checked against a primary source*, and the
  blueprint therefore reports the module's own name rather than asserting an
  attribution.
- *"Grounded" is the paper's coinage, kept deliberately.* Raised by the
  repository owner 2026-08-29 while Phase 4 was being written: the term is not
  standard, and the question was whether the blueprint should say "pinned"
  instead. Checked against the references: *grounded* occurs zero times in the
  four reference papers, so it is the paper's own word (the formalization's
  module names use it too — `GroundedTwist`, `GroundedDirectionConstraint`,
  `groundedPF`). *Pinned* is worse, twice over: Király–Tanigawa §20.3.4 use
  "pinned framework" as a term of art for structures whose pinned points are
  fully fixed in the ambient space, which is a different operation (grounding
  fixes one root vertex at the origin, removing translations only), and in
  this paper "pin" already names the joints between bodies. Decision: keep the
  paper's word under the standing policy for source coinages (as with
  "provenance flag", "null cellule", "Nixon–Owen") — gloss at first use in
  every chapter that uses it, note in the strata chapter that the term is the
  paper's and distinct from Király–Tanigawa's "pinned", and list it in the
  Chapter 09 glossary.
- *Why the weight apparatus stops where it does.* Settled in Phase 4 that it
  is a parallel development and *where* it stops — the height-comparison
  interface `WeightInitialHeightMonotone` is defined as a proposition and
  neither assumed nor proved, and `FilteredInitialHeight.lean`'s own comment
  says Mathlib's Rees algebra does not provide the flat one-parameter family
  of an arbitrary weight filtration. Still open is the historical guess: the
  0/1/2 weight layers of the edge-to-$K_3$ and vertex-to-$K_4$ replacements
  look like a degeneration route to Theorem 1.3 that was abandoned when the
  Witt-shear route landed, but that is not checkable from here, and the
  chapters report only the reachability facts.

## For the author, if ever useful

- Licence on the formalization repository (see `notes/attribution.md`).
- Whether an arXiv version of the paper is planned (see
  `notes/attribution.md`).
- Five modules do a blanket `import Mathlib`: `Specification.lean`,
  `Rigidity/BarJoint.lean`, `Linear/Vec3Twist.lean`,
  `Graph/LooplessMultiGraph.lean`, `Incidence/Arithmetic.lean`. They are small
  — 667 lines between them — but foundational, so they pull all of Mathlib into
  86 of the 126 modules. The other 40 are blanket-free, and on this machine a
  consumer importing one of those loads in 47 s against 169 s for the root
  module: roughly four times faster, entirely in olean loading. Replacing those
  five blanket imports with the specific `Mathlib.*` modules they use — which is
  what the other 121 files already do — would likely shorten every downstream
  build, including the author's own CI. Offered as an observation, not a
  complaint; we have not checked how much work it is.
- Cosmetic, very low priority: docstrings in `RB31EndToEnd` write "body--pin"
  and "bar--joint" with TeX-style double hyphens. Lean docstrings are rendered
  as Markdown rather than TeX, so these come out literally in any generated
  documentation — including the external-declaration panels of this blueprint,
  where they are the only remaining `--` on the site. Affects at least
  `Specification.lean`, `Target.lean`, `TargetReduction.lean`,
  `Rigidity/BodyPinGraph.lean`.

## Resolved

- *Six modules of weight apparatus with nothing reachable — settled in
  Phase 4.* The question asked whether the inventories naming
  `NullCellule/Definitions.lean`, `PolynomialModel.lean`, `GroundScale.lean`
  and the four pure weight modules were wrong or whether a second body of
  work exists. Both, in parts. Real stories: the literal ideal build
  (`Definitions`/`PolynomialModel`) and the weight apparatus are parallel
  developments, documented as such by the Split–Klein chapter, and
  `GroundScale`'s free-orbit statements are superseded by the homogeneity
  route, documented by the assembly chapter with a register entry for
  Lemma 6.4. Inventory corrections: `GroundScale.lean` moved from
  `ungrounded_variety` (whose proof is a translation product, not the scaling
  orbit) to `orbit_dimension_drop`; `GroundedTwistPolynomial.lean` moved from
  `lean_weight_apparatus` to `isotropic_difference_ideal` (its reachable part
  is the twist-coordinate vocabulary, not weights);
  `SelectedDirectionFibre/Height` and `HomogeneousDenominatorContradiction`
  moved out of `lean_base_change` to the entries whose mathematics they
  carry.
- *Two module inventories in the statement chapter named modules the root
  theorem never reaches.* `bodypin_incidence` listed
  `Graph/LooplessMultiGraph.lean` and `pin_capacity` listed
  `Combinatorics/BodyPinCapacity.lean`. Both were assembled by reading imports,
  and both were wrong: `BodyPinIncidence` is a standalone structure whose
  conversion to `LooplessMultiGraph` is never used, and the capacity facts the
  proof uses are the rank bounds of `Linear/PinRank.lean`. Corrected in
  `correspondence.toml`; the chapter prose was unaffected. Found by
  `scripts/reachable.lean`, which now exists so that a module inventory is
  checkable rather than a reading.
