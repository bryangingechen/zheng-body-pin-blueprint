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
one-line placeholder naming the result it will state. See `PLAN.md` for the
phase that covers it.

Section 6 of {Informal.citet "zheng2026"}[] assembles the pieces. Its first two
lemmas, on twists and on the fibre of a pin, are stated in {bpref "twist_description"}[the necessity chapter],
where the paper's necessity argument needs them. The twist-equality
relation partitions the bodies, the partition condition supplies a
$`(2,2)`-sparse subgraph, and {bpref "isotropic_ideal_height"}[the height theorem] then bounds the dimension
of the bad locus.
Exceptional pin parameters form a proper closed subset for each nontrivial
partition; avoiding finitely many of them gives generic infinitesimal rigidity,
and {bpref "asimow_roth"}[the Asimow–Roth step] completes the argument.

Lemma 6.3 is proved by a different route in the formalization. The paper
extracts the sparse subgraph with Nash-Williams and Edmonds' matroid-union rank
formula; the formalization uses no matroid API at all.

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
Selecting a $`(2,2)`-sparse subgraph from the partition capacities.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.3")}[] proves it
by matroid union. The formalization proves it directly from a maximum sparse
subset and an explicit tight partition, with no matroid API.
:::

:::lemma_ "orbit_dimension_drop" (parent := "bodypin_spine") (tags := "paper, unwritten")
Dimension drop along free $`\mathbb{G}_m` orbits. {Informal.citep "zheng2026" (kind := "lemma") (index := "6.4")}[]
:::

:::lemma_ "exceptional_pin_parameters" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "pin_fibre, isotropic_ideal_height")
For each nontrivial twist-equality partition, the exceptional pin parameters
lie in a proper closed subset. {Informal.citep "zheng2026" (index := "Proposition 6.5")}[] Rendered as a lemma;
see `lt-source-deviations.toml`.
:::

:::lemma_ "sufficiency_assembly" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "sparse_subgraph_selection, exceptional_pin_parameters, stress_codim")
Specialization from $`\mathbb{C}` to $`\R`, rational certificate descent, and
the final assembly of {bpref "formal_statement"}[Theorem A.1]. {Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

:::lemma_ "lean_chart_layer" (parent := "bodypin_infrastructure") (tags := "lean-only, unwritten")
Universal homogeneous charts, chart ideals and contractions, height elimination
and transfer, provenance swaps: the largest Lean-only cluster in the
development. Documented as one step here; `correspondence.toml` carries the
module inventory.
:::
