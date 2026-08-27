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
- Cosmetic, very low priority: docstrings in `RB31EndToEnd` write "body--pin"
  and "bar--joint" with TeX-style double hyphens. Lean docstrings are rendered
  as Markdown rather than TeX, so these come out literally in any generated
  documentation — including the external-declaration panels of this blueprint,
  where they are the only remaining `--` on the site. Affects at least
  `Specification.lean`, `Target.lean`, `TargetReduction.lean`,
  `Rigidity/BodyPinGraph.lean`.

## Resolved

- (none yet)
