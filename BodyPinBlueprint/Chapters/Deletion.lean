import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Bodies
import RB31EndToEnd.Linear.OutsideExceptionalFullResponse
import RB31EndToEnd.Linear.DirectionResponseVertexDeletion
import RB31EndToEnd.Linear.FiniteRowSystem

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Vertex deletion and self-stress

Paper §2.2, in the paper's order.

Two of the nodes here have no numbered counterpart in the paper: the direction
row and its stress space, which §2.2 introduces in running prose and the
formalization makes the central object of the whole induction; and the retained
coordinate field, which §2.2 sets up in a displayed paragraph before (2.1).
Both witnesses wrap the paper's own sentences in a reconstructed `definition`
environment, for the reason given in `AGENTS.md`.

One witness takes the paper out of order.  The sentence fixing the $r_{xy}$
notation is the last of its paragraph in the paper, after the certified response
edge has been defined; it sits in the `rigidity_row` witness here, because that
is the definition it is about.  The two sentences it skips are the
`certified_response_edge` witness.  Both pieces are verbatim; only the order
between them is ours.

Equation (1.4) already has a node in the statement chapter, in the real form
that Appendix A.1 uses.  The node here is the field-extension form of the same
matrix, which is what §2 onwards works with and what the formalization calls a
direction row.  They are separate nodes because they are separate objects in
the development, not two renderings of one.

Quoted bodies are named rather than copied; the mechanism is described in the
leading comment of `Statement.lean`.  Every `def` and `abbrev` a node here names
is quoted, which is the rule in the `AGENTS.md` beside this directory.  Five
further declarations are quoted that no node names -- `edgeDirection`,
`directionEquilibriumCoordinate` and `DirectionStressSpace`, which the named
ones are built from, and the two payment predicates -- and their blocks stay in
the prose rather than moving into a panel.

This chapter cannot stay inside the Mathlib-blanket-free part of the
formalization: Lemma 2.5's module reaches `Vec3Twist.lean` through the
collinearity predicate, and that file does a blanket `import Mathlib`.  The
import list is still the three specific modules the nodes reference.
-/

#doc (Manual) "Vertex deletion and self-stress" =>

Section 2.2 of {Informal.citet "zheng2026"}[] compares the self-stress space of
a graph with that of the graph with one vertex removed. An exact sequence
splits the difference into two pieces, a four-term ledger accounts for them
against the transcendence degree released by the deleted point, and a local
classification says what can happen when the deleted vertex has degree at most
three.

One case survives the classification unpaid: a degree-three vertex whose three
neighbours are collinear. Everything in {bpref "collinearity_flag"}[the flags chapter] exists to carry
that case through the induction, and the last two lemmas of this chapter are
what makes it usable when it occurs.

:::group "deletion_spine"
The direction matrix over a coefficient field, the exact sequence, the ledger,
and the local classification at a low-degree vertex.
:::

:::group "deletion_infrastructure"
Base-change and field-tower plumbing with no paper counterpart.
:::

# Direction rows over a coefficient field

:::definition "rigidity_row" (parent := "deletion_spine") (lean := "RB31E2E.DirectionStress.directionRow, RB31E2E.DirectionStress.directionEquilibrium, RB31E2E.DirectionStress.directionStressDim") (tags := "paper")
For a configuration $`b : U \to (L')^3` and distinct $`x, y \in U`, the rigidity
row $`r_{xy}(b)` is the vector whose $`x`-block is $`b_x - b_y`, whose
$`y`-block is $`b_y - b_x`, and whose other blocks vanish. The self-stress space
of $`(F, a)` is the left kernel $`\ker D_F(a)^T`.
{Informal.citep "zheng2026" (kind := "section") (index := "2.2")}[]
:::

```tex "rigidity_row"
\begin{definition}
Let $b : U \to (L')^3$ be a configuration over a field $L'$, and let
$x, y \in U$ be distinct.  Denote by $r_{xy}(b) \in ((L')^3)^U$ the rigidity row
of the edge $xy$: its $x$-block is $b_x - b_y$, its $y$-block is $b_y - b_x$,
and all remaining blocks vanish.  When no confusion can arise, we omit the
configuration from the notation: $r_{xy}$ between retained vertices means
$r_{xy}(a_H)$, whereas $r_{vx}$ means $r_{vx}(a)$.
\end{definition}
```

The formalization takes the transpose as primary. A placement is a function
$`V \to (\mathrm{Fin}\ 3 \to k)`, an edge weighting is a function on the edge
set, and the load a weighting produces at one vertex coordinate is the sum of
the direction rows against it.
{name RB31E2E.DirectionStress.directionEquilibrium}`directionEquilibrium` is
that function bundled as a linear map: with its additivity and homogeneity
obligations elided, what is left is one field naming the coordinate function,
which is where the mathematics is. Its kernel is the
self-stress space, and
{name RB31E2E.DirectionStress.directionStressDim}`directionStressDim` is the
dimension the whole induction bounds.

An unordered edge has no distinguished source, so the formalization picks one
and defines the row symmetrically: the chosen source carries
$`a_{\text{source}} - a_{\text{target}}` and the target carries its negative, so
exchanging the two gives back the same function of the vertices. The paper
writes $`r_{xy}` and lets the symmetry pass without comment.

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.edgeDirection
RB31E2E.DirectionStress.directionRow
RB31E2E.DirectionStress.directionEquilibriumCoordinate
RB31E2E.DirectionStress.directionEquilibrium
RB31E2E.DirectionStress.DirectionStressSpace
RB31E2E.DirectionStress.directionStressDim
```

# Deleting one vertex

:::definition "retained_coordinate_field" (parent := "deletion_spine") (lean := "RB31E2E.DirectionStress.retainedCoordinateField, RB31E2E.DirectionStress.outsideExtensionTrdeg") (tags := "paper") (uses := "rigidity_row")
Fix $`v \in V` and set $`H = F - v`. The retained coordinate field
$`L = k(a_{x,i} : x \in V(H))` is generated by the coordinates of the vertices
that survive, $`a_H` is the restriction of $`a` to $`V(H)`, and
$`\delta_v = \operatorname{trdeg}_L K` is the transcendence degree the three
coordinates of $`a_v` contribute over it, so $`0 \le \delta_v \le 3`.
{Informal.citep "zheng2026" (kind := "section") (index := "2.2")}[]
:::

```tex "retained_coordinate_field"
\begin{definition}
Let $F = (V, E(F))$ be a finite simple graph, let $K/k$ be a finitely generated
field extension, and suppose that $a : V \to K^3$ is injective and that $K$ is
generated by all coordinates of $a$.  Fix $v \in V$ and set
\[
  H = F - v, \qquad E_v = \{vu \in E(F) : u \in V(H)\}.
\]
Then $E(F) = E(H) \sqcup E_v$.  After deleting $v$, retain the coordinate field
\[
  L = k(a_{x,i} : x \in V(H), 1 \le i \le 3) \subseteq K.
\]
Define the $L$-valued configuration $a_H : V(H) \to L^3$ by $a_H(x) = a_x$, and
set
\[
  \delta_v = \operatorname{trdeg}_L K.
\]
Since $K = L(a_{v,1}, a_{v,2}, a_{v,3})$, the integer $\delta_v$ is the
transcendence degree contributed by the three coordinates of $a_v$ over the
field generated by the retained coordinates.  Hence $0 \le \delta_v \le 3$.
Under the natural inclusion $L \hookrightarrow K$, the scalar extension of
$a_H$ is $a|_{V(H)}$.
\end{definition}
```

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.retainedCoordinateField
RB31E2E.DirectionStress.outsideExtensionTrdeg
```

The formalization carries $`L` as an
{name IntermediateField}`IntermediateField` of $`K`, generated by the family
{name RB31E2E.DirectionStress.retainedCoordinates}`retainedCoordinates` of the
three coordinates of every vertex other than $`v`, and $`\delta_v` as a
{name Cardinal}`Cardinal`. Neither definition mentions the coordinates of
$`v`: $`L` is what
survives the deletion, and $`\delta_v` is the transcendence degree of the whole
of $`K` over it. The bound
$`\delta_v \le 3` is
{name RB31E2E.DirectionStress.outsideExtensionTrdeg_le_three}`outsideExtensionTrdeg_le_three`,
and it is proved from the hypothesis that the coordinates of $`a` generate
$`K`, not assumed. Finiteness is proved separately, because the ledger below
adds $`\delta_v` to a natural number and needs to know that the conversion
loses nothing.

:::lemma_ "stress_exact_sequence" (parent := "deletion_spine") (lean := "RB31E2E.BlockKernelExact.connectingMap, RB31E2E.DirectionStress.deletedConnectingClass, RB31E2E.DirectionStress.directionStressDim_eq_delete_add_outsideResponseKernelDim") (tags := "paper") (uses := "retained_coordinate_field")
Splitting edge weights along $`E(F) = E(H) \sqcup E_v` and vertex loads along
$`V = V(H) \sqcup \{v\}` puts $`D_F(a)^T` in lower-triangular block form with
diagonal blocks $`A_K` and $`C_v`. The connecting map
$`\partial_v : \ker C_v \to \operatorname{coker} A_K` sends $`\mu` to
$`[B_v \mu]`, and

$$`
0 \longrightarrow \ker A_K \longrightarrow \ker D_F(a)^T \longrightarrow
\ker C_v \xrightarrow{\ \partial_v\ } \operatorname{coker} A_K
`

is exact.
{Informal.citep "zheng2026" (kind := "equation") (index := "2.1–2.3")}[]
:::

```tex "stress_exact_sequence"
\begin{lemma}
The transpose of the rigidity matrix sends edge weights to the resultant loads
at the vertices.  Decomposing edge weights according to
$E(F) = E(H) \sqcup E_v$ and vertex loads according to
$V = V(H) \sqcup \{v\}$ gives
\begin{equation}
  D_F(a)^T = \begin{pmatrix} A_K & B_v \\ 0 & C_v \end{pmatrix},
  \qquad A_K = D_H(a_H)^T \otimes_L K.
  \tag{2.1}
\end{equation}
Here $A_K : K^{E(H)} \to (K^3)^{V(H)}$ is the equilibrium map of $H$.  For a
weighting $\mu = (\mu_{vu})_{vu \in E_v} \in K^{E_v}$ of the star at $v$, the
map $B_v : K^{E_v} \to (K^3)^{V(H)}$ gives the load induced by $\mu$ on $V(H)$.
The load produced by the same weights at the deleted vertex is given by
\begin{equation}
  C_v : K^{E_v} \longrightarrow K^3, \qquad
  C_v(\mu) = \sum_{vu \in E_v} \mu_{vu} (a_v - a_u).
  \tag{2.2}
\end{equation}
A vector $\mu \in \ker C_v$ is already in equilibrium at $v$.  Such a star
weighting extends to a self-stress of $F$ if and only if
$B_v \mu \in \operatorname{im} A_K$.  Define the connecting map
\[
  \partial_v : \ker C_v \longrightarrow \operatorname{coker} A_K, \qquad
  \partial_v(\mu) = [B_v \mu].
\]
Extending a self-stress of $H$ by zero on $E_v$, and restricting an edge
weighting of $F$ to $E_v$, give the exact sequence
\begin{equation}
  0 \longrightarrow \ker A_K \longrightarrow \ker D_F(a)^T \longrightarrow
  \ker C_v \xrightarrow{\ \partial_v\ } \operatorname{coker} A_K.
  \tag{2.3}
\end{equation}
\end{lemma}
```

The formalization proves this twice over, at two levels. The linear algebra is
separated out with no graph in sight: for maps $`A : X \to Y`, $`B : Z \to Y`
and $`C : Z \to W`, the block map $`(x, z) \mapsto (Ax + Bz, Cz)` has a kernel
that surjects onto the kernel of $`z \mapsto [Bz]`, with fibre $`\ker A`. That
gives the dimension count
{name RB31E2E.BlockKernelExact.finrank_blockKernel}`finrank_blockKernel`
directly, rather than as a consequence of exactness.

The graph-level half is then two linear equivalences and a rewriting: edge
weights split along
{name RB31E2E.DirectionStress.edgeDeletionEquiv}`edgeDeletionEquiv`, loads split
along {name RB31E2E.DirectionStress.splitVertexLoads}`splitVertexLoads`, and the
direction equilibrium map becomes the block map on the nose. The paper's
$`\partial_v` is
{name RB31E2E.DirectionStress.deletedConnectingClass}`deletedConnectingClass`,
whose vanishing on a local weight is exactly the statement that the load that
weight puts on the retained vertices lies in the retained row space.

```BodyPinBlueprint.bodies
RB31E2E.BlockKernelExact.connectingMap
RB31E2E.DirectionStress.deletedConnectingClass
```

The first of the two is the paper's $`\mu \mapsto [B_v\mu]` with no graph in
it: apply $`B`, take the class modulo the image of $`A`. The second supplies the
three maps, and its type is where the deletion appears: the kernel of the local
equilibrium at $`v` for the source, and the loads on the vertices away from
$`v`, modulo the image of the retained equilibrium map, for the target.

The exactness of (2.3) is not stated as such anywhere in the formalization.
What is stated is its numerical consequence, $`s = t + u`, and the module
comment says why: no rank identity or exactness assertion is supplied as a
hypothesis, so the dimension formula is what the induction is given.

:::definition "deletion_ledger" (parent := "deletion_spine") (lean := "RB31E2E.CoordinateFieldTower.trdeg_deletion_ledger, RB31E2E.DirectionStress.outsideResponseKernelDim") (tags := "paper, deviation") (uses := "stress_exact_sequence")
Write $`s = \dim_K \ker D_F(a)^T`, $`t = \dim_L \ker D_H(a_H)^T`,
$`u = \dim_K \ker \partial_v` and $`\delta_v = \operatorname{trdeg}_L K`. Then
$`s = t + u` and
$`\operatorname{trdeg}_k K = \operatorname{trdeg}_k L + \delta_v`, so the defect
$`\Delta(F, a) = s + \operatorname{trdeg}_k K - 3|V|` satisfies
$`\Delta(F, a) = \Delta(H, a_H) + (u + \delta_v - 3)`.
{Informal.citep "zheng2026" (kind := "equation") (index := "2.4–2.6")}[]
:::

```tex "deletion_ledger"
\begin{definition}
Write
\begin{equation}
  s = \dim_K \ker D_F(a)^T, \quad t = \dim_L \ker D_H(a_H)^T, \quad
  u = \dim_K \ker \partial_v, \quad \delta_v = \operatorname{trdeg}_L K.
  \tag{2.4}
\end{equation}
The rank of a finite matrix is unchanged by a field extension, so
$\dim_K \ker A_K = t$.  The exact sequence (2.3) and the tower formula for
transcendence degree give
\begin{equation}
  s = t + u, \qquad
  \operatorname{trdeg}_k K = \operatorname{trdeg}_k L + \delta_v.
  \tag{2.5}
\end{equation}
Define the flag-free defect by
\[
  \Delta(F, a) = s + \operatorname{trdeg}_k K - 3|V|,
\]
so that
\begin{equation}
  \Delta(F, a) = \Delta(H, a_H) + (u + \delta_v - 3).
  \tag{2.6}
\end{equation}
Thus the change in the defect under vertex deletion is determined entirely by
the local increment $u + \delta_v$.
\end{definition}
```

Both halves of (2.5) are theorems in the formalization. The paper's $`u` is
{name RB31E2E.DirectionStress.outsideResponseKernelDim}`outsideResponseKernelDim`.

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.outsideResponseKernelDim
```

The stress half is
{name RB31E2E.DirectionStress.directionStressDim_eq_delete_add_outsideResponseKernelDim}`directionStressDim_eq_delete_add_outsideResponseKernelDim`,
and the transcendence-degree half is packaged with the bound
$`\delta_v \le 3` as
{name RB31E2E.CoordinateFieldTower.trdeg_deletion_ledger}`trdeg_deletion_ledger`.

The defect $`\Delta` itself is not. Nothing in the development is named after
it, and no declaration has its shape. The inequality $`\Delta \le 0` appears
instead as a predicate on a branch of the induction,
{name RB31E2E.ProvenanceFlag.FunctionFieldBranch.SemismallBudget}`SemismallBudget`,
in the form $`s + \operatorname{trdeg}_k K + 2|\Gamma| \le 3|V|`; the flag-free
case is its specialization to $`\Gamma = \emptyset`. So (2.6) has no
counterpart as an equation, and the arithmetic it records is done at the point
of use with the local increment. See {bpref "stress_codim_flags"}[the stress-codimension theorem] for the
form the budget actually takes, and `lt-source-deviations.toml` for the
register entry.

The local increment is where the two branches of the induction part company. If
$`u + \delta_v \le 3` the defect does not grow and the induction hypothesis
finishes the step. The formalization makes that inequality a definition and the
exceptional branch its literal negation, so the case split is an excluded middle
rather than a classification with a stored tag.

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.OutsideNonexceptional
RB31E2E.DirectionStress.OutsideExceptional
```

# Certified response edges

:::definition "certified_response_edge" (parent := "deletion_spine") (lean := "RB31E2E.DirectionStress.directionRowSpace, RB31E2E.DirectionStress.stress_augmentation_of_virtual_response") (tags := "paper") (uses := "rigidity_row, sparse22")
A nonedge $`xy` of $`H` whose rigidity row already lies in
$`\operatorname{row}_L D_H(a_H)`, and for which $`H + xy` is still
$`(2,2)`-sparse, is a _certified response edge_. Adding one leaves the row space
unchanged and raises the self-stress dimension by exactly one.
{Informal.citep "zheng2026" (kind := "section") (index := "2.2")}[]
:::

```tex "certified_response_edge"
\begin{definition}
Continue to write $H = F - v$ and retain the notation $L$ and $a_H$.  If
$xy \notin E(H)$ and
\[
  r_{xy}(a_H) \in \operatorname{row}_L D_H(a_H),
\]
then adding $xy$ does not change the row space of the rigidity matrix.  If
$H + xy$ remains $(2,2)$-sparse, we call $xy$ a certified response edge.
\end{definition}
```

Example 2.2 of {Informal.citet "zheng2026"}[] is the case the induction meets.
If $`H[\{x,y,z\}]` has exactly the edges $`xy` and $`yz`, and $`a_x, a_y, a_z`
are distinct and collinear, then $`r_{xy}`, $`r_{yz}` and $`r_{xz}` span the
same two-dimensional space; so $`xz` is a certified response edge whenever it
can be added, and adding it raises the self-stress dimension by one without
raising the rank.

The row space itself is
{name RB31E2E.DirectionStress.directionRowSpace}`directionRowSpace`.

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.directionRowSpace
```

The span runs over the edges of $`F` rather than over all pairs, which is what
makes "the row is already in the row space" a condition on the graph as well as
on the placement. The formalization proves the second
sentence of the definition rather than asserting it. Row-space invariance is
{name RB31E2E.DirectionStress.directionRowSpace_insert_eq_of_mem}`directionRowSpace_insert_eq_of_mem`,
and the increment follows from it and the rank–nullity identity that already
relates stress dimension, rank and edge count. The result is stated twice under
two names, once as the general augmentation lemma and once as
{name RB31E2E.DirectionStress.stress_augmentation_of_virtual_response}`stress_augmentation_of_virtual_response`,
the form the deletion branches call.

The sparsity half of the paper's definition is not part of the Lean statement.
Sparsity of $`H + xy` is what the caller has to supply, and it is supplied by
{bpref "addable_edge_triple"}[the addable-edge lemma]; the augmentation lemma
itself needs only that the edge is absent.

# The local classification

:::lemma_ "low_degree_classification" (parent := "deletion_spine") (lean := "RB31E2E.DirectionStress.outsideExceptional_linear_dichotomy, RB31E2E.DirectionStress.outsideExceptional_classification") (tags := "paper") (uses := "deletion_ledger")
If $`\deg_F(v) \le 3`, then either $`u + \delta_v \le 3`, or $`v` has exactly
three neighbours $`p, q, r` with
$`\delta_v = 3`, $`u = 1`, $`\operatorname{rank} C_v = 2`,
$`\dim_K \ker C_v = 1` and $`\ker \partial_v = \ker C_v`, and in that case
$`a_p, a_q, a_r` are distinct and collinear.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.3")}[]
:::

```tex "low_degree_classification"
\begin{lemma}[Low-degree local classification]
If $\deg_F(v) \le 3$, then one of the following alternatives holds:
\begin{enumerate}
  \item[(i)] the local increment satisfies
    \begin{equation}
      u + \delta_v \le 3;
      \tag{2.7}
    \end{equation}
  \item[(ii)] $v$ has exactly three neighbors $p, q, r$, and
    \begin{equation}
      \delta_v = 3, \quad u = 1, \quad \operatorname{rank} C_v = 2, \quad
      \dim_K \ker C_v = 1, \quad \ker \partial_v = \ker C_v.
      \tag{2.8}
    \end{equation}
    In this case, $a_p, a_q, a_r$ are distinct and collinear.
\end{enumerate}
\end{lemma}
```

:::proof "low_degree_classification" (uses := "retained_coordinate_field")
Since $`K` is generated by $`L` and the three coordinates of $`a_v`, we have
$`\delta_v \le 3`. If $`\deg_F(v) \le 1` then $`C_v` is injective. If
$`\deg_F(v) = 2` and $`\ker C_v \ne 0`, then $`v` and its two neighbours are
collinear; the line through the two $`L`-points is defined over $`L`, so
$`\delta_v \le 1`, and $`u \le 1` gives $`u + \delta_v \le 2`.

Let $`\deg_F(v) = 3`. If $`\operatorname{rank} C_v = 3` then $`u = 0`. If
$`\operatorname{rank} C_v \le 1` the three star directions are collinear, so
$`a_v` and all its neighbours lie on a line defined over $`L`, whence
$`\delta_v \le 1` while $`u \le \dim \ker C_v \le 2`. In the remaining case
$`\operatorname{rank} C_v = 2` and $`u \le 1`, so a failure of (2.7) forces
$`u = 1` and $`\delta_v = 3`. Noncollinear neighbours would put $`a_v` in the
affine plane they span, giving $`\delta_v \le 2`. Finally
$`\ker \partial_v \subseteq \ker C_v` and both are one-dimensional.
:::

The formalization splits this proof along the same lines, but keeps the two
halves in different modules. `OutsideLocalClassification.lean` carries the
numerical part:
rank–nullity for $`C_v` is the degree ledger, the response kernel is a subspace
of $`\ker C_v`, and a failed payment has only two possible numerical shapes.
`OutsideLocalGeometry.lean` carries the geometric part, as two field-generation
statements. Rank one puts the apex on a line through two
retained neighbours, so the extension has transcendence degree at most one;
rank two with three noncollinear retained neighbours puts the apex in their
affine plane, so at most two.

{name RB31E2E.DirectionStress.outsideExceptional_classification}`outsideExceptional_classification`
is the two halves combined, and its conclusion is (2.8) together with
distinctness and collinearity of the three neighbour coordinates, and with
$`\partial_v = 0` rather than $`\ker \partial_v = \ker C_v`. Those two
statements agree here because both kernels are one-dimensional and one contains
the other.

The paper's hypothesis is a bound on the degree of $`v` in $`F`; the Lean
hypothesis is the same bound plus injectivity of the placement, which the paper
carries from the start of the section and the formalization passes explicitly.

# Descent and the three neighbour rows

:::lemma_ "affine_coefficient_descent" (parent := "deletion_spine") (lean := "RB31E2E.AffineSpanDescent.affineCoefficients_mem_span") (tags := "paper")
Let $`L \subseteq K`, let $`R \subseteq L^M` be a subspace, and let
$`x_1, x_2, x_3 \in K` be such that $`1, x_1, x_2, x_3` are linearly independent
over $`L`. If $`c, b_1, b_2, b_3 \in L^M` satisfy
$`c + \sum_j x_j b_j \in R \otimes_L K`, then $`c, b_1, b_2, b_3 \in R`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.4")}[]
:::

```tex "affine_coefficient_descent"
\begin{lemma}[Descent of affine coefficients]
Let $L \subseteq K$ be a field extension, let $M$ be a finite set, and let
$R \subseteq L^M$ be a linear subspace.  Suppose that $x_1, x_2, x_3 \in K$ and
that $1, x_1, x_2, x_3$ are linearly independent over $L$.  If
$c, b_1, b_2, b_3 \in L^M$ satisfy
\[
  c + \sum_{j=1}^{3} x_j b_j \in R \otimes_L K,
\]
then $c, b_1, b_2, b_3 \in R$.
\end{lemma}
```

The Lean statement takes the coefficient family to be indexed by an arbitrary
finite type rather than by $`\{1,2,3\}`, and takes as hypothesis that the family
is algebraically independent over $`L` rather than that $`1` together with it is
linearly independent. Algebraic independence is the stronger assumption and is
what the call site has, since
{bpref "low_degree_classification"}[the exceptional branch] gives
$`\delta_v = 3` for three coordinates.

The proof is the paper's. A coefficient outside $`R` is separated by an
$`L`-linear functional; extending that functional coordinatewise to $`K` kills
the extended row space and leaves an affine relation among $`1` and the
$`x_j`, which independence forbids.

:::lemma_ "neighbour_rigidity_rows" (parent := "deletion_spine") (lean := "RB31E2E.DirectionStress.outsideExceptional_fullResponse") (tags := "paper") (uses := "low_degree_classification")
In the exceptional case, the three rigidity rows on pairs of neighbours belong
to $`\operatorname{row}_L D_H(a_H)`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.5")}[]
:::

```tex "neighbour_rigidity_rows"
\begin{lemma}[Rigidity rows among the three neighbors]
In the exceptional case of Lemma 2.3, the three rigidity rows on pairs of
neighbors belong to $\operatorname{row}_L D_H(a_H)$.
\end{lemma}
```

:::proof "neighbour_rigidity_rows" (uses := "affine_coefficient_descent")
The neighbour coordinates $`a_p, a_q, a_r` lie in $`L^3` and are collinear over
$`K`, hence over $`L`, so there is a unique $`\tau \in L \setminus \{0,1\}` with
$`a_r - a_p = \tau(a_q - a_p)`. Let the star weighting $`\mu` take the values
$`1 - \tau`, $`\tau`, $`-1` on $`vp`, $`vq`, $`vr`. Writing
$`C = (1-\tau) e_p \otimes a_p + \tau e_q \otimes a_q - e_r \otimes a_r` and
$`\Lambda(z) = (1-\tau) e_p \otimes z + \tau e_q \otimes z - e_r \otimes z`, a
calculation gives $`\mu \in \ker C_v = \ker \partial_v`, so
$`C - \Lambda(a_v) \in R_H \otimes_L K` where $`R_H = \operatorname{row}_L D_H(a_H)`.

By (2.8) the three coordinates of $`a_v` are algebraically independent over
$`L`, so {bpref "affine_coefficient_descent"}[descent of affine coefficients] applies and gives
$`C, \Lambda(e_1), \Lambda(e_2), \Lambda(e_3) \in R_H`, hence
$`\Lambda(z) \in R_H` for every $`z \in L^3`. Then
$`C - \Lambda(a_r) = \tau(1-\tau) r_{pq}`,
$`(1-\tau)(C - \Lambda(a_p)) = \tau r_{qr}` and
$`\tau(C - \Lambda(a_q)) = (1-\tau) r_{pr}`, and every scalar is nonzero.
:::

The Lean statement bundles the classification with the conclusion: it returns
the three neighbours, the degree, the transcendence degree, the response
dimension, the collinearity, and membership of all three neighbour rows in the
row space of the deleted graph. Bundling matters at the call site, because the
flag move needs the same three neighbours in all of those roles at once.

One step of the argument is carried out where the paper leaves it implicit. The
paper works with $`a_H` as an $`L`-valued configuration throughout; the
formalization has a single $`K`-valued placement, so it constructs the
$`L`-valued one by sending $`v` to zero and restricting elsewhere, and then has
to move collinearity of the three neighbours down from $`K` to $`L` before the
descent lemma can be applied. That is
{name RB31E2E.DirectionStress.collinear_restrictScalars_for_response}`collinear_restrictScalars_for_response`,
and it is why the module is 872 lines for a lemma the paper proves in a page.

# Base change and field towers

:::lemma_ "lean_base_change" (parent := "deletion_infrastructure") (lean := "RB31E2E.FiniteFamilyBaseChange.finrank_span_range_mapVector, RB31E2E.DirectionStress.directionStressDim_mapPlacement, RB31E2E.DirectionStress.directionStressDim_restrictedLiveEdges") (tags := "lean-only") (uses := "rigidity_row") (uses_intent := "technical")
Rank and stress dimension are unchanged by extending the coefficient field
along $`L \subseteq K`, and by restricting a placement to a subtype of vertices
after a deletion. Seventeen modules of coordinate field towers, finite row
systems and localization arithmetic carry the two facts to the places that need
them.
:::

The paper changes coefficient field constantly and silently. "The rank of a
finite matrix is unchanged by a field extension" is one clause of (2.5);
$`A_K = D_H(a_H)^T \otimes_L K` is one clause of (2.1); the descent lemma
identifies $`R \otimes_L K` with the image of a scalar extension in one line of
its proof. Each of those is a theorem in the formalization, and the deletion
step needs all of them.

The vertex type changes as well as the field. Deleting $`v` from a graph on
$`V` produces a graph on the subtype $`\{u : u \ne v\}`, not a graph on $`V`
with fewer edges, so a stress space has to be transported along the inclusion
and the two presentations proved to have the same dimension. The paper's
$`H = F - v` hides that entirely, and can, because its vertex sets are subsets
of one ambient set.
