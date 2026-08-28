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

Paper §6, plus the universal and provenance chart layer.  Phase 4.
-/

#doc (Manual) "Assembling the body-pin theorem" =>

Section 6 of {Informal.citet "zheng2026"}[] assembles the pieces. Motions within
a body are twists; a pin is a fibre condition on a pair of twists, and three
pins force collinearity. The twist-equality relation partitions the bodies, the
partition condition supplies a $`(2,2)`-sparse subgraph, and the height theorem
{bpref "isotropic_ideal_height"}[] then bounds the dimension of the bad locus.
Exceptional pin parameters form a proper closed subset for each nontrivial
partition; avoiding finitely many of them gives generic infinitesimal rigidity,
and {bpref "asimow_roth"}[] finishes.

The one deviation worth watching is Lemma 6.3. The paper extracts the sparse
subgraph with Nash-Williams and Edmonds' matroid-union rank formula; the Lean
development uses no matroid API at all.

:::group "bodypin_spine"
The paper's assembly argument.
:::

:::group "bodypin_infrastructure"
The universal and provenance chart layer.
:::

:::lemma_ "twist_description" (parent := "bodypin_spine") (tags := "paper, unwritten")
Motions within a rigid body are exactly the twists. {Informal.citep "zheng2026" (kind := "lemma") (index := "6.1")}[]
:::

:::lemma_ "pin_fibre" (parent := "bodypin_spine") (tags := "paper, unwritten") (uses := "twist_description")
The fibre of a pin, and: three pins shared by two bodies force the three pin
points to be collinear unless the relative twist vanishes. {Informal.citep "zheng2026" (kind := "lemma") (index := "6.2")}[]
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
the final assembly of {bpref "formal_statement"}[]. {Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

:::lemma_ "lean_chart_layer" (parent := "bodypin_infrastructure") (tags := "lean-only, unwritten")
Universal homogeneous charts, chart ideals and contractions, height elimination
and transfer, provenance swaps: the largest Lean-only cluster in the
development. Documented as one step here; `correspondence.toml` carries the
module inventory.
:::
