import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Bodies
import RB31EndToEnd.Rigidity.GraphNecessity

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Necessity

Paper §6.1 and the first half of §6.4.

The two are together because §6.1 is what §6.4's necessity argument is stated
in, and because §6.1's later paragraphs, on the twist-equality partition, serve
the other direction and stay in the assembly chapter with the rest of §6.2 to
§6.4.

Necessity has no statement of its own in the paper: it is the forward
implication of Theorem 1.1, whose witness is in the statement chapter, and what
§6.4 gives under the heading "Necessity in Theorem 1.1" is an argument.  So the
`necessity` node carries its witness in the proof slot rather than beside the
statement, with the paper's `proof` environment reconstructed around the
paper's own sentences.  Every other witness here is a numbered environment in
the paper except the twist definition, which §6.1 gives in a display and two
sentences of running prose.

Quoted bodies are named rather than copied; the mechanism is described in the
leading comment of `Statement.lean`.  The names here come from four modules --
`Vec3Twist.lean` for the twist and its evaluation, `TwistSystem.lean` for the
three motion predicates, `TwistNecessity.lean` for the grouped operator and
`GraphNecessity.lean` for the determinant polynomial -- and all four arrive
through the single import above, since `GraphNecessity` reaches the other three.
Every `def` and `abbrev` a node here names is quoted, which is the rule in
the `AGENTS.md` beside this directory.
-/

#doc (Manual) "Necessity" =>

Section 6.4 of {Informal.citet "zheng2026"}[] proves necessity in one paragraph.
Assign a common twist to every body in a partition block; the block twists have
$`6(t-1)` degrees of freedom modulo the ambient rigid motions, the cross-block
pins can constrain at most $`\sum_{i<j} \ell_H(P_i, P_j)` of them, and a
partition violating the capacity inequality therefore leaves a nontrivial
block-twist motion. Section 6.1 supplies the vocabulary that argument is stated
in, and its Lemma 6.1 turns the block-twist motion back into a flex of the
expanded graph.

The formalization takes 894 lines in the two modules that prove this direction,
and a further 180 for the pin-capacity rank bounds. Over half of the 894 is not
the counting argument but the passage between the two ways of saying "rigid":
the partition condition is proved from rigidity of the _occurrence-level twist
system_ at one pin placement, and generic rigidity of the expanded graph has to
be brought to that form first. The paper's "a generic realization" does the same
work in three words.

:::group "necessity_spine"
Twists, the pin compatibility equation, and the counting argument.
:::

:::group "necessity_infrastructure"
The passage from a maximum-rank graph placement to a rigid twist system.
:::

# Twists and the compatibility equation

:::definition "twist_system" (parent := "necessity_spine") (lean := "RB31E2E.Twist, RB31E2E.Twist.eval, RB31E2E.IsTwistMotion, RB31E2E.TwistRigidAt") (tags := "paper")
A twist is a pair $`X = (\omega, b) \in \mathfrak{t}_3 = k^3 \oplus k^3`, and
the velocity it induces at a point $`p` is $`u_X(p) = b + \omega \times p`.
{Informal.citep "zheng2026" (kind := "section") (index := "6.1")}[]
:::

```tex "twist_system"
\begin{definition}
Let
\[
  \mathfrak{t}_3 = k^3 \oplus k^3, \qquad X = (\omega, b), \qquad
  u_X(p) = b + \omega \times p.
\]
Here $\mathfrak{t}_3$ is the space of rigid-body twists in three dimensions;
$X$ represents an instantaneous rigid-body motion, and $u_X(p)$ is the velocity
induced by this motion at $p$.
\end{definition}
```

Both halves of the display are declarations. A twist is the pair itself, with
the angular part first and the translational part second, and the velocity is
its evaluation at a point.

```BodyPinBlueprint.bodies
RB31E2E.Twist
RB31E2E.Twist.eval
```

The formalization states the twist system on a type of pin occurrences with two
endpoint maps, not on a graph. A twist assignment $`X : W \to \mathfrak{t}_3` is
a motion when every pin receives the same velocity from both of its bodies, it
is diagonal when it is constant, and a pin placement is _twist rigid_ when every
motion at it is diagonal.

```BodyPinBlueprint.bodies
RB31E2E.IsTwistMotion
RB31E2E.IsDiagonalTwist
RB31E2E.TwistRigidAt
```

Keeping the occurrence type means that two pins joining the same pair of bodies
impose two constraints rather than one; the capacities $`3, 5, 6` count
occurrences, not pairs of bodies. The endpoint maps are arbitrary functions, so
nothing in this layer depends on a graph library.

:::lemma_ "twist_description" (parent := "necessity_spine") (lean := "RB31E2E.BodyPinIncidence.exists_unique_twist_of_tetrahedronMotion, RB31E2E.BodyPinIncidence.twistMotionToBarMotion_bijective_of_allCores") (tags := "paper") (uses := "twist_system, bodypin_expansion")
Suppose every body contains four affinely independent private vertices. Then
every infinitesimal bar–joint motion of a body is induced by a unique twist; a
shared pin $`p_e` between bodies $`u` and $`v` is compatible exactly when
$`(b_u - b_v) + (\omega_u - \omega_v) \times p_e = 0`; and the
infinitesimal-motion kernel of $`G_H` is linearly isomorphic to the space of
twist tuples satisfying all of those equations, the diagonal twists
corresponding to the six-dimensional space of ambient rigid motions.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.1")}[]
:::

```tex "twist_description"
\begin{lemma}[Twist description of motions within a body]
Suppose that every body $B_w$ contains four affinely independent vertices
belonging only to $B_w$.  Then:
\begin{enumerate}
  \item[(a)] every infinitesimal bar--joint motion of $B_w$ is induced by a
    unique twist $X_w \in \mathfrak{t}_3$;
  \item[(b)] a pin $p_e$ shared by the bodies $u$ and $v$ is compatible if and
    only if
    \begin{equation}
      (b_u - b_v) + (\omega_u - \omega_v) \times p_e = 0;
      \tag{6.1}
    \end{equation}
  \item[(c)] the infinitesimal-motion kernel of $G_H$ is linearly isomorphic to
    the space of twist tuples satisfying all equations (6.1).  If
    $W \ne \emptyset$, the diagonal twists are precisely the six-dimensional
    space of ambient rigid motions; if $W = \emptyset$, both spaces are
    zero-dimensional.
\end{enumerate}
\end{lemma}
```

The four private vertices that {bpref "bodypin_expansion"}[the expansion] gives
every body are used in part (a). A complete graph on four affinely independent
points is infinitesimally rigid, so its velocities come from a twist; every
other vertex of the body is joined to all four, and subtracting the velocity
that twist prescribes leaves a vector orthogonal to a spanning set.

The formalization proves (a) as
{name RB31E2E.BodyPinIncidence.exists_unique_twist_of_tetrahedronMotion}`exists_unique_twist_of_tetrahedronMotion`,
by way of a skew-symmetry argument: the linear map recording the motion of the
tetrahedron is skew, hence a cross product. Part (c) becomes a bijection
between twist motions and bar motions,
{name RB31E2E.BodyPinIncidence.twistMotionToBarMotion_bijective_of_allCores}`twistMotionToBarMotion_bijective_of_allCores`,
rather than an abstract isomorphism of kernels, and it is stated under the
hypothesis {name RB31E2E.BodyPinIncidence.AllCoresAffinelyIndependent}`AllCoresAffinelyIndependent`
that names the paper's "four affinely independent vertices belonging only to
$`B_w`" at every body at once.

:::lemma_ "pin_fibre" (parent := "necessity_spine") (lean := "RB31E2E.Twist.three_pin_solutions_collinear, RB31E2E.Twist.splitKlein_eq_zero_of_pin_solution, RB31E2E.Twist.pin_sub_eq_smul_angular") (tags := "paper") (uses := "twist_system")
For $`X = (\omega, b) \ne 0`, the equation $`b + \omega \times p = 0` has a
solution if and only if $`\omega \ne 0` and $`q(X) = 0`; the solution set is
then an affine line with direction $`k\omega`. In particular any three distinct
pins compatible with the same nonzero relative twist are collinear.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.2")}[]
:::

```tex "pin_fibre"
\begin{lemma}[The fiber of a pin]
Let $X = (\omega, b) \ne 0$.  The equation
\begin{equation}
  b + \omega \times p = 0
  \tag{6.2}
\end{equation}
has a solution if and only if $\omega \ne 0$ and $q(X) = 0$.  When it is
nonempty, the solution set is an affine line with direction $k\omega$.  In
particular, any three distinct pins compatible with the same nonzero relative
twist are collinear.
\end{lemma}
```

Here $`q(\omega, b) = \omega \cdot b` is the Split–Klein quadratic form of
{bpref "split_klein_form"}[the Split–Klein chapter]. This lemma introduces the
condition $`q(X) = 0`, and the sufficiency direction is a height estimate for
the ideal that such conditions generate along the edges.

The three consequences of the lemma are separate declarations in the
formalization, and only the ones the assembly needs are proved. Solvability
forces isotropy; a nonzero twist with a solution has nonzero angular part; and
two solutions of the same equation differ by a multiple of $`\omega`, which
gives collinearity of three of them without ever naming the line.

A bundle of three or more pins between two blocks therefore constrains no more
than a bundle of exactly three does. The lemma is used again in
{bpref "exceptional_pin_parameters"}[the assembly chapter], to show that a pin
placement making three pins of one bundle collinear is a proper closed
condition.

# The counting argument

:::lemma_ "necessity" (parent := "necessity_spine") (lean := "RB31E2E.BodyPinIncidence.partitionCondition_of_genericallyRigidInR3, RB31E2E.BodyPinIncidence.partitionCondition_of_twistRigidAt") (tags := "paper") (uses := "partition_condition, generic_rigidity_max_rank")
If $`G_H` is generically rigid in $`\R^3`, then every partition of the bodies
satisfies the capacity inequality.
{Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

The pin capacities bound the rank of the constraints a bundle of pins imposes
on a single relative twist. One pin is three linear conditions on a
six-dimensional twist; two pins leave the rotation about the line through them,
so five; and no number of pins can remove more than the six dimensions there
are. Those three bounds are
{name RB31E2E.Twist.finrank_range_evalLinear_le_three}`finrank_range_evalLinear_le_three`,
{name RB31E2E.Twist.finrank_range_twoPinLinear_le_five}`finrank_range_twoPinLinear_le_five`
and {name RB31E2E.Twist.finrank_range_le_six}`finrank_range_le_six`, assembled
into {name RB31E2E.Twist.finrank_range_bundleLinear_le_pinCapacity}`finrank_range_bundleLinear_le_pinCapacity`,
which is the capacity table of {bpref "pin_capacity"}[the capacity definition]
read as a rank bound.

:::proof "necessity" (uses := "twist_description")
Suppose a partition $`\mathcal{P} = \{P_1, \dots, P_t\}` violates the capacity
inequality. Assign a common block twist $`X_i` to every body in $`P_i`. Modulo
the six-dimensional diagonal subspace the space of block twists has dimension
$`6(t-1)`, while the total rank of the cross-block constraints is at most
$`\sum_{i<j} \ell_H(P_i, P_j) < 6(t-1)`. Some nontrivial tuple of block twists
therefore satisfies every cross-block compatibility equation, and giving every
body in a block that block's twist satisfies the within-block equations as
well. By {bpref "twist_description"}[the twist description] this is a nontrivial infinitesimal flex of
$`G_H`, so $`G_H` is not generically rigid.
:::

```tex "necessity" (slot := "proof")
\begin{proof}
Suppose that a partition $\mathcal{P} = \{P_1, \dots, P_t\}$ violates equation
(1.2).  Assign a common block twist $X_i$ to all bodies in $P_i$.  Modulo the
six-dimensional diagonal subspace, the space of block twists has dimension
$6(t-1)$.  For a fixed pair of partition blocks, one pin has constraint rank at
most 3; with two pins, the relative rotation about the line through them
remains, so the rank is at most 5; three or more pins have rank at most 6.
Consequently, the total rank of all cross-block constraints is at most
\[
  \sum_{i<j} \ell_H(P_i, P_j) < 6(t-1).
\]
There is therefore a nontrivial tuple of block twists satisfying all cross-block
pin compatibility equations.  Assigning the same twist to every original body
within a partition block also makes every within-block pin compatible.
Lemma 6.1 then gives a nontrivial infinitesimal flex of $G_H$.  Thus $G_H$
cannot be generically rigid.
\end{proof}
```

The paper argues by contraposition, from a violating partition to a flex. The
formalization proves the implication in the direction it is stated, so there is
no violating partition to start from and no flex to construct. Twist rigidity at
a pin placement makes the grouped
cross-block operator injective, so its rank is the full $`6(t-1)`; the same
rank is at most the sum of the bundle capacities; and the inequality is the
composite of those two.

Reading the two arguments against each other, the paper's "there is therefore a
nontrivial tuple" is the formalization's injectivity, and the paper's ranks are
its {name Module.finrank}`finrank` of a range. The grounding step, "modulo the
six-dimensional diagonal subspace", is done in the formalization by fixing one
block's twist to zero rather than by quotienting.

# From a rigid graph to a rigid twist system

:::lemma_ "lean_block_bundle_operator" (parent := "necessity_infrastructure") (lean := "RB31E2E.BodyPinIncidence.groupedGroundedBlockOperator, RB31E2E.BodyPinIncidence.six_mul_pred_le_groupedGroundedBlockOperator_rank, RB31E2E.BodyPinIncidence.groupedGroundedBlockOperator_rank_le_partitionCapacity") (tags := "lean-only") (uses := "twist_system, pin_capacity") (uses_intent := "technical")
The cross-block compatibility constraints of a grounded block assignment,
grouped by unordered block pair. Twist rigidity makes it injective, so its rank
is at least $`6(t-1)`; the rank of a product of linear maps is at most the sum
of the coordinate ranks, so it is at most the partition capacity.
:::

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.groupedGroundedBlockOperator
```

The definition quoted above shows how the grounding is done.
{name RB31E2E.extendGroundedLinear}`extendGroundedLinear` is the map that fills
the root block's twist in as zero, so the source of the operator is indexed by
{name RB31E2E.OffRoot}`OffRoot` — one twist per block except the chosen one —
and that subtype is the fixed representative standing in for the quotient.

The grouping introduces a sign that the paper's paragraph does not mention. The
constraints of a bundle are all expressed through a single relative twist, the
one belonging to the bundle's chosen orientation, and each pin occurrence
carries a sign recording whether its own stored orientation agrees. Signed and
unsigned evaluations have the same kernel, so the $`3, 5, 6` bounds apply to the
signed form unchanged.

:::lemma_ "lean_genericity" (parent := "necessity_infrastructure") (lean := "RB31E2E.BarJoint.isOpen_setOf_le_rigidityRank, RB31E2E.BodyPinIncidence.exists_allCores_rigidityRank_eq_genericRigidityRank, RB31E2E.BodyPinIncidence.coreLineDetPolynomial") (tags := "lean-only") (uses := "generic_rigidity_max_rank, twist_description") (uses_intent := "technical")
A placement attaining the maximum rigidity rank can be chosen so that every
body's four private core vertices are affinely independent; at such a placement,
equality with the complete-graph rank forces the twist system itself to be
rigid.
:::

The paper's necessity argument begins "a generic realization", and every
realization it needs is generic. The formalization has no genericity theory, by
the design decision recorded on {bpref "generic_rigidity_max_rank"}[the maximum-rank definition], so it has to
produce the placement by hand. That construction is the rest of this section.

It is a one-parameter avoidance argument. A lower bound on the
rigidity rank is an open condition on placements, because the rigidity operator
depends continuously and linearly on the coordinates. Take a placement
$`p` attaining the maximum rank and the standard placement $`q` whose bodies
carry the tetrahedron $`0, e_1, e_2, e_3`, and move along the segment from
$`p` to $`q`. Degeneracy of one body's core along that segment is the vanishing
of an explicit univariate determinant polynomial, nonzero because it does not
vanish at $`q`. Finitely many finite root sets cannot cover an interval, so some
placement near $`p` is in the rank-open set and has all cores nondegenerate.

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.coreLineDetPolynomial
```

The polynomial is a determinant and nothing else; the content is in
{name RB31E2E.BodyPinIncidence.coreLinePolynomialMatrix}`coreLinePolynomialMatrix`,
whose three columns are the displacements of a body's other three core vertices
from the first, each interpolated linearly along the segment. Evaluating at a
parameter therefore gives the determinant of the displacement matrix at that
placement, which is nonzero exactly when the four points are affinely
independent. The avoidance argument is then about the roots of one univariate
real polynomial per body.

The rest is short. At that placement the graph rank equals the
complete-graph rank, so the two infinitesimal-motion kernels agree; a complete
framework containing one nondegenerate tetrahedron has only global Euclidean
motions; so every twist motion is diagonal, and the twist system is rigid at the
pin coordinates. The empty-body case is separate and immediate: every twist
assignment on an empty type is diagonal.
