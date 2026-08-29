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

*This chapter is a stub.* Its nodes are titled, tagged and mapped to the
correspondence table, but the mathematics is not written yet: each body is a
one-line placeholder naming the result it will state.

The other chapters follow the paper's results in order; this chapter is
organized by the formalization instead, and records, in the five sections
below, what corresponds to what — down to which node accounts for each module
reachable from the root theorem.

# The correspondence table

Every numbered result of {Informal.citet "zheng2026"}[] against the Lean
declaration that corresponds to it, with a status: mapped, deviation, informal,
gap, or Lean-only. The machine-readable source is `correspondence.toml`.

# Glossary

The paper and the Lean development do not share names. The vocabulary table
from {bpref "collinearity_flag"}[the flags chapter] is repeated here in full, together with the
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
remains outside is {bpref "asimow_roth"}[the Asimow–Roth step]. {Informal.citep "zheng2026" (kind := "section") (index := "A.2")}[]
:::

# Reverse index

Lean module to blueprint node, for the 125 modules of the development.
A cluster node is later split by promoting a row of this index to a node of
its own; see `PLAN.md`.

One measurement belongs to this index already. Walking the constant
dependencies of the root theorem through the kernel environment shows that,
of the four modules that develop
{bpref "lean_nixon_owen_reduction"}[the construction theorem of the sparsity
chapter], only a few counting facts are reachable: from `TightCompletion.lean`
one equation lemma for a definition made elsewhere; from
`TriangleSequence.lean` two declarations about the four-element vertex set of
a $`K_4`; from `GraphExtension.lean` eight facts about the edges one outside
vertex sends into a tight module; and from `Construction.lean` its edge-set
vocabulary rather than its reduction theorems. `notes/reachability.md` has the
method and the whole table, and `scripts/coverage.py --reachable` rechecks the
walk when the submodule pin moves.
