import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography

open Verso.Genre
open Verso.Genre.Manual
open Informal

set_option doc.verso true

/-
# Assembling the body-pin theorem  (stub)

Paper §6 from the twist-equality partition onwards, plus the universal and
provenance chart layer.  Phase 4.  Lemmas 6.1 and 6.2 are in `Necessity.lean`
with the rest of §6.1.
-/

#doc (Manual) "Assembling the body-pin theorem" =>

*This chapter is a stub.* Its nodes are titled, tagged and mapped to the
correspondence table, but the mathematics is not written yet: each body is a
one-line placeholder naming the result it will state.

Section 6 of {Informal.citet "zheng2026"}[] proves the sufficiency direction:
the partition condition implies generic rigidity. Its first two lemmas, on
twists and on the fibre of a pin, are stated in
{bpref "twist_description"}[the necessity chapter], which also uses them. In
outline: equality of block twists partitions the bodies; since the partition
condition holds, Lemma 6.3 selects from the pins a $`(2,2)`-sparse subgraph of
representatives; and {bpref "isotropic_ideal_height"}[the height theorem]
bounds the dimension of the locus of pin placements that admit a nontrivial
compatible twist assignment. For each nontrivial twist-equality partition, the
_exceptional pin parameters_ of {bpref "exceptional_pin_parameters"}[Proposition 6.5]
therefore lie in a proper closed subset, so a placement avoiding the finitely
many such subsets is infinitesimally rigid, and
{bpref "asimow_roth"}[the Asimow–Roth theorem] then gives Theorem 1.1.

Lemma 6.3 is proved by a different route in the formalization: the paper
extracts the sparse subgraph with Nash-Williams and Edmonds' matroid-union
rank formula, and the formalization develops no matroid theory.

:::group "bodypin_spine"
The paper's assembly argument.
:::

:::group "bodypin_infrastructure"
The universal and provenance chart layer.
:::

:::definition "twist_equality_partition" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "twist_description")
The partition of the bodies induced by equality of block twists. {Informal.citep "zheng2026" (kind := "section") (index := "6.1")}[]
:::

:::lemma_ "sparse_subgraph_selection" (parent := "bodypin_spine") (tags := "paper, deviation, unwritten") (uses := "twist_equality_partition, partition_condition")
Selecting a $`(2,2)`-sparse subgraph from the partition capacities. The paper
proves it by matroid union; the formalization proves it directly, from a
maximum sparse subset and an explicit tight partition.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.3")}[]
:::

:::lemma_ "orbit_dimension_drop" (parent := "bodypin_spine") (tags := "paper, unwritten")
Dimension drop along free $`\mathbb{G}_m` orbits. {Informal.citep "zheng2026" (kind := "lemma") (index := "6.4")}[]
:::

:::lemma_ "exceptional_pin_parameters" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "pin_fibre, isotropic_ideal_height")
For each nontrivial twist-equality partition, the exceptional pin parameters
lie in a proper closed subset; rendered as a lemma rather than a proposition.
{Informal.citep "zheng2026" (index := "Proposition 6.5")}[]
:::

:::lemma_ "sufficiency_assembly" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "sparse_subgraph_selection, exceptional_pin_parameters, stress_codim")
Specialization from $`\mathbb{C}` to $`\R`, rational certificate descent, and
the final assembly of {bpref "formal_statement"}[Theorem A.1]. {Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

:::lemma_ "lean_chart_layer" (parent := "bodypin_infrastructure") (tags := "lean-only, unwritten")
Universal homogeneous charts, chart ideals and contractions, height elimination
and transfer, provenance swaps: the largest Lean-only cluster in the
development, documented as one node here. The module inventory is in the
correspondence chapter.
:::
