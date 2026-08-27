import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import RB31EndToEnd

open Verso.Genre
open Verso.Genre.Manual
open Informal

set_option doc.verso true

#doc (Manual) "Statement of the theorem" =>

:::group "statement_data"
The combinatorial data of a body--pin framework, and the two sides of the
equivalence.
:::

:::definition "bodypin_incidence" (parent := "statement_data") (lean := "RB31E2E.BodyPinIncidence") (tags := "paper, unwritten")
A body--pin multigraph is a finite loopless multigraph $`H = (W, E)`: the
vertices are rigid bodies and the edges are pins, with parallel pins allowed as
distinct elements of $`E`.

The Lean formalization keeps pins as *occurrences* rather than as a multiset of
unordered pairs: a pin type together with two endpoint maps, plus looplessness.
No provenance is lost, and parallel pins stay distinguishable.
:::

:::definition "pin_capacity" (parent := "statement_data") (lean := "RB31E2E.pinCapacity") (tags := "paper, unwritten")
The capped rank contribution of a bundle of $`n` pins joining two blocks is
$`c(0) = 0`, $`c(1) = 3`, $`c(2) = 5`, and $`c(n) = 6` for $`n \ge 3`.

One shared pin forces two bodies to agree at a point, which is three
constraints. Two distinct shared pins leave a relative rotation about the line
through them, so five. Three noncollinear shared pins remove all six relative
degrees of freedom.
:::

:::definition "partition_condition" (parent := "statement_data") (lean := "RB31E2E.BodyPinIncidence.PartitionCondition") (tags := "paper, unwritten") (uses := "pin_capacity")
The partition condition asks that every partition of the bodies into $`t`
nonempty blocks satisfy

$$`
\sum_{1 \le i < j \le t} c(m_{ij}) \ge 6(t - 1),
`

where $`m_{ij}` counts the pins joining blocks $`i` and $`j`.

Lean indexes partitions by surjections $`\pi : W \twoheadrightarrow [t]` rather
than by set partitions, which makes the empty body set and the one-block case
fall out of the definition instead of needing separate treatment.
:::

:::definition "generic_rigidity_max_rank" (parent := "statement_data") (lean := "RB31E2E.BarJoint.rigidityOperator, RB31E2E.BarJoint.genericRigidityRank, RB31E2E.BarJoint.IsGenericallyRigidInR3") (tags := "paper, unwritten")
Generic rigidity is formalized in *maximum-rank* form. The generic rank of a
graph is the greatest rank actually attained by the real rigidity operator over
all placements, and a graph is generically rigid in $`\mathbb{R}^3` when that
rank equals the generic rank of the complete graph on the same vertex set.

No generic configuration is chosen in the statement. The step from attained
maximum rank to generic rigidity in the usual sense is the Asimow--Roth theorem,
which the paper cites and the formalization does not prove.
:::

:::theorem "bodypin_partition_characterization" (parent := "statement_data") (lean := "RB31E2E.endToEndBodyPinStatement, RB31E2E.EndToEndBodyPinStatement") (tags := "paper, unwritten") (uses := "bodypin_incidence, partition_condition, generic_rigidity_max_rank")
*Body--pin partition characterization.* For every finite loopless body--pin
multigraph and every choice of additional private vertices per body, the
expanded graph is generically rigid in $`\mathbb{R}^3` if and only if the
partition condition holds.

This is Theorem 1.1 of the paper, in the maximum-rank form of Theorem A.1. It is
the root theorem of the formalization: a closed proposition, universally
quantified, proved in both directions.
:::

:::theorem "reduction_to_sufficiency" (parent := "statement_data") (lean := "RB31E2E.endToEndBodyPinStatement_iff_sufficiency") (tags := "lean-only, unwritten") (uses := "bodypin_partition_characterization")
Because necessity is already a theorem, the full equivalence is equivalent to
its sufficiency direction alone.

This reduction has no counterpart in the paper; it is how the Lean development
organizes the two directions.
:::
