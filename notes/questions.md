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
- *Six modules of weight apparatus with nothing reachable.*
  `NullCellule/WeightInitialIdeal.lean`, `WeightComponents.lean`,
  `VertexK4Weight.lean`, `ReplacementIdentities.lean`, and with them
  `NullCellule/Definitions.lean`, `PolynomialModel.lean` and `GroundScale.lean`,
  contribute nothing to the root theorem. Together that is 209 declarations
  named by `lean_weight_apparatus`, `isotropic_difference_ideal`,
  `ungrounded_variety` and `orbit_dimension_drop`. Either those module
  inventories are wrong, as two in the statement chapter turned out to be, or
  there is a second body of work the assembly does not depend on. To settle
  when Phase 4 writes those chapters.

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
