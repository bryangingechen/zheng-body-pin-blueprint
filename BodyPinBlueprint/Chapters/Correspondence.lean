import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Correspondence and audit  (stub)

No paper counterpart.  Phase 5.  This chapter renders `correspondence.toml`,
the glossary, the deviations register, the trust boundary, and the reverse
index from Lean module to blueprint node.
-/

#doc (Manual) "Correspondence and audit" =>

The rest of this blueprint reads the paper forwards. This chapter reads the
formalization backwards: it asks, of every module reachable from the root
theorem, which node accounts for it.

Five things go here, and none of them are written yet.

# The correspondence table

Every numbered result of {Informal.citet "zheng2026"}[] against the Lean
declaration that discharges it, with a status: mapped, deviation, informal,
gap, or Lean-only. The machine-readable source is `correspondence.toml`.

# Glossary

The paper and the Lean development do not share names. The vocabulary table
from {bpref "collinearity_flag"}[] is repeated here in full, together with the
naming conventions of the development.

# Deviations register

Where a result is mapped but proved by a different route. The register is
`lt-source-deviations.toml`; each entry is fingerprinted against the reviewed
text so that it expires when what it excuses changes.

# Trust boundary

:::lemma_ "trust_boundary" (tags := "paper, unwritten")
What is and is not covered by the formal verification: no `sorry`, no `admit`,
no opaque declarations, no custom axioms; axiom closure exactly
{name propext}`propext`, {name Classical.choice}`Classical.choice`,
{name Quot.sound}`Quot.sound`; Lean 4.29.0 against a pinned mathlib. What
remains outside is {bpref "asimow_roth"}[]. {Informal.citep "zheng2026" (kind := "section") (index := "A.2")}[]
:::

# Reverse index

Lean module to blueprint node, for the 125 modules of the development.
Promoting a row of this index to a node of its own is how a cluster node is
later split; see `PLAN.md`.
