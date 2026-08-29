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

This chapter proves the necessity direction of the main theorem: a generically
rigid body–pin graph satisfies the partition condition. Section 6.4 of
{Informal.citet "zheng2026"}[] gives the argument in one paragraph. Assign a
common twist to every body in a partition block; the block twists have
$`6(t-1)` degrees of freedom modulo the ambient rigid motions, the cross-block
pins can constrain at most $`\sum_{i<j} \ell_H(P_i, P_j)` of them, so a
partition violating the condition leaves a nontrivial block-twist motion.
Section 6.1 defines the twists this argument is stated in, and its Lemma 6.1
turns the block-twist motion back into a flex of the expanded graph.

In the formalization the counting argument itself is short, and most of the
work is the passage between two readings of "rigid": the partition condition
is proved from rigidity of a twist system at one pin placement — the
vocabulary of §6.1, introduced below — while the hypothesis is generic
rigidity of the expanded graph, and the placement connecting the two is
constructed in the last section of this chapter. The paper crosses the same
passage with the words "a generic realization", since a generic placement has
every property the argument needs at once.

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

The two halves of the display are the two declarations quoted here: a twist is
the pair itself, with the angular part first and the translational part
second, and the velocity is its evaluation at a point.

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
points is infinitesimally rigid, so its velocities come from a twist. Every
other vertex $`x` of the body is joined to all four, and the bar constraints
make the difference between the velocity at $`x` and the velocity the twist
prescribes orthogonal to the four directions from $`x` to the tetrahedron;
those directions span $`\R^3`, so the difference is zero.

The formalization proves (a) as
{name RB31E2E.BodyPinIncidence.exists_unique_twist_of_tetrahedronMotion}`exists_unique_twist_of_tetrahedronMotion`,
by a skew-symmetry argument: the linear map recording the motion of the
tetrahedron is skew-symmetric, and a skew-symmetric map of $`k^3` is the cross
product with a fixed vector, the angular part of the twist. Part (c) becomes a bijection
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
{bpref "split_klein_form"}[the Split–Klein chapter]. The condition
$`q(X) = 0` appears here for the first time; in the sufficiency direction, one
such condition per pin generates the ideal whose height
{bpref "isotropic_ideal_height"}[the Split–Klein chapter] computes.

The affine-line description itself is not a Lean statement. The formalization
proves the three consequences the later chapters use, as separate
declarations: solvability of (6.2) forces $`q(X) = 0`; a nonzero twist with a
solution has nonzero angular part; and two solutions of (6.2) differ by a
scalar multiple of $`\omega`, so any three solutions are collinear.

The lemma is used again in
{bpref "exceptional_pin_parameters"}[the assembly chapter], to show that a pin
placement making three pins of one bundle collinear is a proper closed
condition.

# The counting argument

:::lemma_ "necessity" (parent := "necessity_spine") (lean := "RB31E2E.BodyPinIncidence.partitionCondition_of_genericallyRigidInR3, RB31E2E.BodyPinIncidence.partitionCondition_of_twistRigidAt") (tags := "paper") (uses := "partition_condition, generic_rigidity_max_rank")
If $`G_H` is generically rigid in $`\R^3`, then every partition of the bodies
satisfies the partition inequality (1.2).
{Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

The pin capacities bound the rank of the constraints a bundle of pins imposes
on a single relative twist. One pin is three linear conditions on a
six-dimensional twist; two pins leave the rotation about the line through them,
so five; and no number of pins can remove more than all six dimensions of a
twist. Those three bounds are
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
no violating partition to start from and no flex to construct: twist rigidity
at the pin placement makes a block operator, defined in the next section,
injective, so the rank of that operator is the full $`6(t-1)`; the same rank
is at most the sum of the bundle capacities; and the partition inequality
follows by comparing the two.

The two arguments correspond clause by clause. Where the paper produces a
nontrivial tuple, the formalization proves injectivity; where the paper counts
ranks, the formalization computes the {name Module.finrank}`finrank` of a
range; and the paper's grounding step, "modulo the six-dimensional diagonal
subspace", is done by fixing one block's twist to zero rather than by
quotienting.

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

The grounding is visible in the quoted body:
{name RB31E2E.extendGroundedLinear}`extendGroundedLinear` extends an
assignment by giving the root block the zero twist, so the source of the
operator is indexed by {name RB31E2E.OffRoot}`OffRoot`, one twist per block
except the chosen one. Working on this subspace replaces the paper's quotient
by the diagonal.

The grouping introduces a sign that the paper's paragraph does not mention. The
constraints of a bundle are all expressed through a single relative twist, the
one belonging to the bundle's chosen orientation, and each pin occurrence
carries a sign recording whether its own orientation agrees. Signed and
unsigned evaluations have the same kernel, so the $`3, 5, 6` bounds apply to the
signed form unchanged.

:::lemma_ "lean_genericity" (parent := "necessity_infrastructure") (lean := "RB31E2E.BarJoint.isOpen_setOf_le_rigidityRank, RB31E2E.BodyPinIncidence.exists_allCores_rigidityRank_eq_genericRigidityRank, RB31E2E.BodyPinIncidence.coreLineDetPolynomial") (tags := "lean-only") (uses := "generic_rigidity_max_rank, twist_description") (uses_intent := "technical")
A placement attaining the maximum rigidity rank can be chosen so that every
body's four private core vertices are affinely independent; at such a placement,
equality with the complete-graph rank forces the twist system itself to be
rigid.
:::

The paper's necessity argument begins with a generic realization, and
genericity gives at one stroke every property the argument needs. The
formalization has no genericity theory, by the design decision recorded on
{bpref "generic_rigidity_max_rank"}[the maximum-rank definition], so a
placement with the two properties actually used — maximum rigidity rank, and
affine independence of the _core_ of every body, i.e. of its four designated
private vertices — is constructed by a one-parameter avoidance argument.

A lower bound on the rigidity rank is an open condition on placements, because
the rigidity operator depends continuously and linearly on the coordinates.
Take a placement $`p` attaining the maximum rank and the standard placement
$`q` in which every body's core is the tetrahedron $`0, e_1, e_2, e_3`, and
consider the segment from $`p` to $`q`. Degeneracy of one body's core along
the segment is the vanishing of an explicit univariate determinant polynomial,
which is nonzero as a polynomial because its value at the parameter of $`q` is
nonzero. Finitely many finite root sets cannot cover an interval, so some
placement near $`p` attains the maximum rank and has every core affinely
independent.

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.coreLineDetPolynomial
```

The polynomial is the determinant of
{name RB31E2E.BodyPinIncidence.coreLinePolynomialMatrix}`coreLinePolynomialMatrix`,
whose three columns are the displacements of a body's other three core vertices
from the first, each interpolated linearly along the segment. Its value at a
parameter is therefore the determinant of the displacement matrix at that
placement, which is nonzero exactly when the four points are affinely
independent, and the avoidance argument concerns the roots of one univariate
real polynomial per body.

At the placement so constructed, the graph rank equals the complete-graph
rank, so the two infinitesimal-motion kernels agree; a complete framework
containing one nondegenerate tetrahedron admits only the global Euclidean
motions; hence every twist motion is diagonal, and the twist system is rigid
at the pin coordinates. The empty-body case is separate and immediate: every
twist assignment on an empty type is diagonal.
