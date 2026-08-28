# Reading questions

Questions arising while mapping the paper onto the formalization. These are
*questions*, not claims of error — the formalization is kernel-checked, so where
prose and Lean seem to disagree the likely answer is that we have misread one of
them. Record page/section references so a question can be re-checked cheaply.

Anything that resolves into a genuine paper-vs-Lean divergence graduates to
`lt-source-deviations.toml`. Anything that resolves into a misreading gets
deleted.

## Open

- (none yet — Phase 0 was scaffolding only)

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

- (none yet)
