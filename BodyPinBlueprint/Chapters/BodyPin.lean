import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.SourceLinks
import BodyPinBlueprint.Bodies
import RB31EndToEnd.Incidence.EqualityPartition
import RB31EndToEnd.Combinatorics.BodyPinFinpartition
import RB31EndToEnd.Combinatorics.Sparse22.OptimalPartition
import RB31EndToEnd.Combinatorics.BodyPinSparseSkeleton
import RB31EndToEnd.NullCellule.GroundScale
import RB31EndToEnd.Algebra.HomogeneousPrimeChartHeight
import RB31EndToEnd.Algebra.HomogeneousDenominatorContradiction
import RB31EndToEnd.Incidence.CollinearityPolynomial
import RB31EndToEnd.Incidence.TripleBundleCertificate
import RB31EndToEnd.Incidence.SmallBundleCertificate
import RB31EndToEnd.Incidence.FiniteBadCover
import RB31EndToEnd.Incidence.FiniteFullProvenancePropernessAssembly
import RB31EndToEnd.Incidence.UniversalFullProvenanceChartContraction
import RB31EndToEnd.Algebra.ComplexRealSpecialization
import RB31EndToEnd.Algebra.FiniteOpenIntersection
import RB31EndToEnd.Algebra.RationalCertificateDescent
import RB31EndToEnd.Rigidity.BodyTwistGenericBridge
import RB31EndToEnd.TargetReduction

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal
open BodyPinBlueprint

set_option doc.verso true

/-
# Assembling the body-pin theorem

Paper §6 from the twist-equality partition onwards, in the paper's order,
plus the universal and provenance chart layer as one cluster node.  Lemmas
6.1 and 6.2 are in `Necessity.lean` with the rest of §6.1.

Witness conventions are described in the leading comment of `Statement.lean`.
Reconstructions particular to this chapter: the twist-equality partition is
defined in running prose, so its witness wraps the paper's sentences in a
`definition` environment; Proposition 6.5 is rendered with `:::lemma_` and a
`\begin{lemma}` witness because the v4.29.0 release line has no proposition
directive (the register records the convention); and the `sufficiency_assembly`
witness is attached to the proof block with `(slot := "proof")`, because §6.4's
sufficiency argument is a proof environment with no separate statement.

One witness joins separated pieces of the paper: `exceptional_pin_parameters`
takes the §6.3 setup (the pin parameter space, the incidence variety, the
projection) and then the Proposition 6.5 statement, skipping the Lemma 6.4
environment that sits between them, which has its own node and witness above.
The `sparse_subgraph_selection` witness is contiguous: it runs from the top of
§6.2 through the Lemma 6.3 statement, including the matroid-union paragraph,
because the registered deviation is about exactly that paragraph.  Bracketed
reference numbers inside witnesses are the paper's own.

`check-witness-prose.py` reports 32 windows in this chapter; each was checked
and each is one of two artifacts.  First, a reconstructed environment title
sits above the quoted text, while in the paper the heading of Lemma 6.3 and
of Proposition 6.5 follows the setup paragraphs quoted with it, so the
title-adjacent windows are unmatched (`sparse_subgraph_selection`,
`exceptional_pin_parameters`).  Second, math survives in the text layer as
words a LaTeX transcription does not have: `r2`, `scross` around (6.5),
`Ppin` around (6.8), and `ZP`, `Ppin` in the §6.4 proof
(`sufficiency_assembly`).  `twist_equality_partition` and
`orbit_dimension_drop` match with no unmatched window.

Quoted bodies are named rather than copied; the mechanism is described in the
leading comment of `Statement.lean`.  Every `def` and `abbrev` a node here
names is quoted.  Further definitions are quoted that no node names —
`equalityBlockValue`, `sparsePartitionTerm`, `sparseSkeletonTarget`,
`minor01`, `IsIncidenceRealization` — because the nodes' statements are
unreadable without them.

Namespaces do not always match file names: `EqualityPartition.lean`
and `GroundScale.lean` declare directly into `RB31E2E`,
`HomogeneousPrimeChartHeight.lean` and
`HomogeneousDenominatorContradiction.lean` into
`RB31E2E.NullCellulePolynomial`, and
`RB31E2E.UniversalHomogeneousChart.FiniteGenericIncidenceProvenancePrimeHeightCondition`
is declared in `UniversalFullProvenanceChartContraction.lean`.
-/

#doc (Manual) "Assembling the body-pin theorem" =>

Section 6 of {Informal.citet "zheng2026"}[] proves the sufficiency direction
of the main theorem: if every partition of the bodies satisfies the capacity
inequality (1.2), the body–pin graph $`G_H` is generically rigid. Its first
two lemmas, on twists and on the fibre of a pin, are stated in
{bpref "twist_description"}[the necessity chapter], which also uses them.
The argument runs as follows. A twist assignment to the bodies partitions
them by equality of values; for a fixed partition with $`t \ge 2` blocks,
{bpref "sparse_subgraph_selection"}[Lemma 6.3] selects from the cross-block
pins a $`(2,2)`-sparse graph of representatives, the height theorem of
{bpref "isotropic_ideal_height"}[the Split–Klein chapter] bounds the
dimension of the compatible twist tuples, and a fibre count together with
{bpref "orbit_dimension_drop"}[the orbit dimension drop] shows that the pin
placements admitting a nontrivial compatible twist assignment with that
equality partition lie in a proper closed subset of the pin parameter space
— {bpref "exceptional_pin_parameters"}[Proposition 6.5]. The bodies have
only finitely many partitions, so a placement avoiding every such subset
exists, and at it the only compatible twists are the global rigid motions;
{bpref "twist_description"}[the twist description] turns that into
infinitesimal rigidity of a real framework, and the
{bpref "asimow_roth"}[Asimow–Roth theorem] then gives Theorem 1.1.

Two deviations run through the whole chapter, so we state them once. The
paper works over $`k = \C` from Section 6.3 onwards and specializes to
$`\R` at the end; the formalization never leaves $`\Q` and $`\R` — its
certificates are nonzero _integer_ polynomials in the pin coordinates, a
nonzero real polynomial has a real non-vanishing point, and no
complex-to-real step occurs. And "the closure of $`\pi_{\mathcal{P}}(I_{\mathcal{P}})` is a proper
closed subset" is expressed without topology: for each partition the
formalization gives one nonzero integer polynomial that vanishes at every
pin placement admitting a bad twist assignment, and avoiding the finitely
many certificates is the non-vanishing of their product.

:::group "bodypin_spine"
The paper's assembly argument: the partition, the selection lemma, the orbit
drop, the properness of the exceptional locus, and the final assembly.
:::

:::group "bodypin_infrastructure"
The universal and provenance chart layer.
:::

# The twist-equality partition

:::definition "twist_equality_partition" (parent := "bodypin_spine") (lean := "RB31E2E.equalitySetoid, RB31E2E.equalityPartition, RB31E2E.equalityBlockValue_injective") (tags := "paper") (uses := "twist_system")
For a twist assignment $`X : W \to \mathfrak{t}_3`, the partition of the
bodies defined by $`u \sim v` if and only if $`X_u = X_v` is the
twist-equality partition. Its $`t` blocks carry pairwise distinct block
values $`X_1, \dots, X_t`; the compatibility equations depend only on twist
differences, so after subtracting a common twist $`X_1 = 0`, and for
$`t \ge 2` the group $`\mathbb{G}_m` acts freely on such tuples by common
scaling, fixing every pin coordinate.
{Informal.citep "zheng2026" (kind := "section") (index := "6.1")}[]
:::

```tex "twist_equality_partition"
\begin{definition}
The partition defined by $u \sim v$ if and only if $X_u = X_v$ is called the
twist-equality partition.  Suppose that it has $t$ blocks, with pairwise
distinct block values $X_1, \ldots, X_t$.  The compatibility equations depend
only on twist differences, so after subtracting a common twist we may assume
that $X_1 = 0$.  If $t \ge 2$, the multiplicative group
$\mathbb{G}_m = k^\times$ acts on the nonzero block values by common scaling:
for $\lambda \in k^\times$, set
\begin{equation}
  \lambda \cdot (X_2, \ldots, X_t) = (\lambda X_2, \ldots, \lambda X_t).
  \tag{6.3}
\end{equation}
This action is free on the locally closed locus on which $X_1 = 0$ and the
block values are pairwise distinct.  The compatibility equations are
homogeneous in the twists, and the action fixes all pin coordinates.  For
example, if four bodies $w_1, w_2, w_3, w_4$ satisfy
$X_{w_1} = X_{w_2} \ne X_{w_3} = X_{w_4}$, then the twist-equality partition
is $\{\{w_1, w_2\}, \{w_3, w_4\}\}$.
\end{definition}
```

The formalization builds the partition as the kernel setoid of the
assignment, so the blocks are the fibres of $`X` and no quotient
representatives appear in later statements:

```BodyPinBlueprint.bodies
RB31E2E.equalitySetoid
RB31E2E.equalityPartition
RB31E2E.equalityBlockValue
```

Each block carries its value through
{name RB31E2E.equalityBlockValue}`equalityBlockValue`, whose representative
is hidden behind the proof that the value does not depend on it, and
{name RB31E2E.equalityBlockValue_injective}`equalityBlockValue_injective` is
the statement that distinct blocks have distinct values. The subtraction of
a common twist is not performed on the partition: the later statements work
with the differences $`X_u - X_v` directly, which is the same normalization.

# Selecting a sparse subgraph

Fix a twist-equality partition with $`t \ge 2` blocks. Contracting each
block to a vertex leaves the simple support graph $`J`, one edge per pair of
blocks joined by at least one pin, with $`m_e` pins on the edge $`e`; when
some pair carries three or more pins, {bpref "pin_fibre"}[the pin-fibre
lemma] forces those pins collinear, which is the first case of
Proposition 6.5 below, so this section assumes $`m_e \in \{1, 2\}` and sets
$`M = \sum_e m_e` and $`R = \max\{0,\ 6(t-1) - 2M\}`. The paper selects the
subgraph with the matroid-union theorem, in the union of two copies of the
graphic matroid of $`J`: independence there means a partition into two
forests, which the forest-decomposition theorem of
{Informal.citet "nashWilliams1964"}[] identifies with the $`(2,2)`-sparsity
counts, and the matroid-union rank formula of
{Informal.citet "edmonds1965"}[] evaluates the maximum size of an
independent set as a minimum over vertex partitions.

:::lemma_ "sparse_subgraph_selection" (parent := "bodypin_spine") (lean := "RB31E2E.exists_sparse22_of_all_partition_terms, RB31E2E.BodyPinIncidence.exists_sparse_nullSkeleton") (tags := "paper, deviation") (uses := "twist_equality_partition, partition_condition, sparse22")
Suppose $`m_e \in \{1, 2\}` for every edge of the support graph $`J` and
that $`H` satisfies the partition inequality (1.2). Then $`J` contains a
spanning $`(2,2)`-sparse subgraph $`F` with exactly $`R` edges.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.3")}[]
:::

```tex "sparse_subgraph_selection"
\begin{lemma}[Selecting a $(2,2)$-sparse subgraph]
Fix a twist-equality partition with $t \ge 2$ blocks.  Contract each block to
one vertex, and join two vertices in the simple support graph $J$ whenever at
least one pin runs between the corresponding blocks.  Let $m_e$ be the number
of pins between that pair of blocks.  If a block pair contains at least three
pins, Lemma 6.2 forces any three of them to be collinear, which is a proper
closed algebraic condition on the pin coordinates.  Henceforth suppose that
$m_e \in \{1, 2\}$, and set
\begin{equation}
  M = \sum_{e \in E(J)} m_e, \qquad R = \max\{0, 6(t-1) - 2M\}.
  \tag{6.4}
\end{equation}

Let $M(J)$ be the graphic matroid of $J$, and let $M(J) \vee M(J)$ be the
union of two copies of this matroid.  An edge set $I \subseteq E(J)$ is
independent in $M(J) \vee M(J)$ if and only if it can be partitioned into two
forests.  By the Nash--Williams forest-decomposition theorem, this is
equivalent to the spanning subgraph $(V(J), I)$ satisfying the
$(2,2)$-sparsity inequalities [25].  Write $r_2(J) = r_{M(J) \vee M(J)}(E(J))$.
Edmonds' matroid-union rank formula gives
\begin{equation}
  r_2(J) = \min_{Q} \bigl(2(t - |Q|) + s_{\mathrm{cross}}(Q)\bigr),
  \tag{6.5}
\end{equation}
where $Q$ ranges over all partitions of $V(J)$ and $s_{\mathrm{cross}}(Q)$ is
the number of edges of $J$ whose endpoints lie in distinct blocks of $Q$ [10].

Suppose that $m_e \in \{1, 2\}$ for every $e \in E(J)$ and that $H$ satisfies
equation (1.2).  Then $J$ contains a spanning $(2,2)$-sparse subgraph $F$
with exactly $R$ edges.
\end{lemma}
```

:::proof "sparse_subgraph_selection"
If $`6(t-1) - 2M \le 0` take $`F` empty, so assume it positive. It is enough
that every term of the rank formula (6.5) is at least $`6(t-1) - 2M`; for a
partition $`Q` with $`r` blocks this is the inequality
$`2M + s_{\mathrm{cross}} \ge 4t + 2r - 6`. The capacity of the block pair
carrying $`m_e \in \{1,2\}` pins is $`2m_e + 1`, so the partition condition
at the twist-equality partition itself gives $`2M + |E(J)| \ge 6(t-1)`. If
$`s_{\mathrm{int}} \le 2(t - r)`, subtracting it gives the inequality. If
$`s_{\mathrm{int}} \ge 2(t - r)`, then $`2M_{\mathrm{int}} \ge
2 s_{\mathrm{int}} \ge 4(t - r)`; lifting $`Q` to a partition of the bodies
with $`r` blocks, each coarse capacity is at most the sum of the fine
capacities it contains, so the partition condition gives
$`2M_{\mathrm{cross}} + s_{\mathrm{cross}} \ge 6(r-1)`, and adding the two
inequalities gives the claim. Hence $`r_2(J) \ge R`, and an independent
$`R`-element set is the required subgraph.
:::

The formalization uses no matroid at all — no Nash–Williams, no Edmonds, no
matroid API in the import closure — and proves the same minimum only in the
direction it needs, by constructing the optimal partition explicitly. Take a
maximum-cardinality $`(2,2)`-sparse subset $`F \subseteq J`. Every omitted
edge, if added, would violate sparsity, so by
{bpref "addable_edge_criterion"}[the addable-edge criterion] some tight set
contains its endpoints. Singletons are tight, and by
{bpref "uncrossing"}[uncrossing] the union of the tight sets through a
vertex is tight, so the _tight hulls_ partition the vertices into maximal
tight blocks with every omitted edge internal to a block. Summing tightness
over the blocks counts the internal edges exactly, and so

```BodyPinBlueprint.bodies
RB31E2E.sparsePartitionTerm
```

is attained by $`F` at that one partition:
{name RB31E2E.IsMaximumSparseSubedge.card_eq_sparsePartitionTerm}`card_eq_sparsePartitionTerm`
gives $`|F| = 2(|V(J)| - |Q|) + s_{\mathrm{cross}}(Q)` for the tight-hull
partition $`Q`. Consequently, if every partition term is at least $`R`, a
maximum sparse subset has at least $`R` edges, and any $`R` of them form the
required subgraph; that is
{name RB31E2E.exists_sparse22_of_all_partition_terms}`exists_sparse22_of_all_partition_terms`,
whose source carries the comment that no graphic-matroid-union interface is
invoked. The paper needs the hard direction of the rank formula, that the
minimum is attained; the formalization needs only this constructive half,
and the converse bound, that every sparse subset is at most every partition
term, is proved in the same module and is not reachable from the root
theorem; the register has the entry.

The body–pin side is
{name RB31E2E.BodyPinIncidence.exists_sparse_nullSkeleton}`exists_sparse_nullSkeleton`:
under the partition condition, with every nonzero cross-block multiplicity
at most two, the support of the cross-block pins contains a sparse subgraph
of exactly the deficit cardinality

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.sparseSkeletonTarget
```

where truncated subtraction over $`\N` gives the paper's
$`\max\{0, \cdot\}`. Its partition-term hypothesis is proved from the
partition condition without contracting to $`J`: the capacity of a one- or
two-pin bundle is exactly $`2m_e + 1`, so the fine partition condition reads
$`6(t-1) \le 2M + |E(J)|`, and an aggregation inequality —
{name RB31E2E.BodyPinIncidence.capacityOn_comp_le_two_mul_crossingFineMass_add_card}`capacityOn_comp_le_two_mul_crossingFineMass_add_card`,
that coarsening the labels never increases capped capacity beyond
$`2M + s` of the fine crossing data — turns the partition condition at each
coarsening into the corresponding Edmonds term.

# The orbit dimension drop

:::lemma_ "orbit_dimension_drop" (parent := "bodypin_spine") (lean := "RB31E2E.NullCellulePolynomial.homogeneousPrime_height_lt_of_irrelevant_mem_not_mem, RB31E2E.NullCellulePolynomial.finiteIrrelevantIdeal_height") (tags := "paper, deviation")
Suppose $`\mathbb{G}_m` acts freely on a quasi-affine variety $`X` of finite
type and a morphism $`\pi : X \to Y` is constant on each orbit. Then
$`\dim \pi(X) \le \dim X - 1`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "6.4")}[]
:::

```tex "orbit_dimension_drop"
\begin{lemma}[Dimension drop along free orbits]
Suppose that $\mathbb{G}_m$ acts freely on a quasi-affine variety $X$ of
finite type and that a morphism $\pi : X \to Y$ is constant on each orbit.
Then
\begin{equation}
  \dim \pi(X) \le \dim X - 1.
  \tag{6.9}
\end{equation}
\end{lemma}
```

The paper proves this from the fibre-dimension theorem: the group is
connected, so it preserves each irreducible component, and every
one-dimensional orbit lies in a fibre of $`\pi`. The formalization proves no
statement of this shape, and the register has the entry. The point-set
content (the common-scaling action is free on every grounded nonzero
assignment, {name RB31E2E.units_commonScale_injective_of_ne_zero}`units_commonScale_injective_of_ne_zero`)
is proved in a module whose own comment defers the conversion into a
dimension inequality, and nothing reachable from the root theorem uses it.
What stands in for the orbit drop is homogeneity. The compatibility
equations are homogeneous in the twist variables, so the bad locus of a
fixed partition is a homogeneous ideal in the twist coordinates over the pin
coefficients, and a homogeneous prime avoiding any element of the irrelevant
ideal — here a distinctness denominator, a product of twist-difference
coordinates and so of positive degree — has height strictly below the
number of twist variables, by
{name RB31E2E.NullCellulePolynomial.homogeneousPrime_height_lt_of_irrelevant_mem_not_mem}`homogeneousPrime_height_lt_of_irrelevant_mem_not_mem`
together with the computation of the irrelevant ideal's height in
{name RB31E2E.NullCellulePolynomial.finiteIrrelevantIdeal_height}`finiteIrrelevantIdeal_height`.
The strict inequality is the paper's $`-1`.

# Exceptional pin parameters

From here the paper takes $`k = \C`: the pin parameter space is
$`P_{\mathrm{pin}} = (\C^3)^E` of dimension $`3N` with $`N = |E|`, and for a
fixed partition $`\mathcal{P}` of the bodies the incidence variety
$`I_{\mathcal{P}}` consists of the grounded, pairwise distinct block twists
together with pin coordinates satisfying every compatibility equation, with
$`\pi_{\mathcal{P}} : I_{\mathcal{P}} \to P_{\mathrm{pin}}` the projection
that forgets the twists.

:::lemma_ "exceptional_pin_parameters" (parent := "bodypin_spine") (lean := "RB31E2E.SparseNullIncidence.PropernessPrinciple, RB31E2E.BodyPinIncidence.hasOnlySmallBundlesAt_or_tripleBundlePartitionCertificate, RB31E2E.BodyPinIncidence.exists_smallBundlePartitionPolynomial") (tags := "paper") (uses := "twist_equality_partition, partition_condition, pin_fibre")
Proposition 6.5: suppose $`H` satisfies the partition inequality (1.2). For
every partition $`\mathcal{P}` of the bodies with $`t \ge 2` blocks, the
closure of $`\pi_{\mathcal{P}}(I_{\mathcal{P}})` is a proper closed subset
of $`P_{\mathrm{pin}}`.
{Informal.citep "zheng2026" (index := "Proposition 6.5")}[]
:::

```tex "exceptional_pin_parameters"
\begin{lemma}[Exceptional parameter image for a fixed partition]
For the remainder of this subsection, take $k = \mathbb{C}$.  Let $N = |E|$.
The parameter space of all pin coordinates is
\begin{equation}
  P_{\mathrm{pin}} = (\mathbb{C}^3)^E, \qquad \dim P_{\mathrm{pin}} = 3N.
  \tag{6.8}
\end{equation}
Fix a partition $\mathcal{P} = \{P_1, \ldots, P_t\}$ of $W$ with $t \ge 2$
blocks, and define $\beta(w) = i$ if and only if $w \in P_i$.  Let
$I_{\mathcal{P}}$ be the quasi-affine incidence variety whose points are
\[
  \bigl((X_i)_{i=1}^t, (p_e)_{e \in E}\bigr), \qquad
  X_i = (\omega_i, b_i) \in \mathfrak{t}_3,
\]
such that $X_1 = 0$, $X_i \ne X_j$ for $i \ne j$, and, for every
$e = uv \in E$,
\[
  (b_{\beta(u)} - b_{\beta(v)}) + (\omega_{\beta(u)} - \omega_{\beta(v)})
    \times p_e = 0.
\]
Let
\[
  \pi_{\mathcal{P}} : I_{\mathcal{P}} \longrightarrow P_{\mathrm{pin}}
\]
be the projection that forgets the twists and retains only the pin
coordinates.

Suppose that $H$ satisfies equation (1.2).  For every partition $\mathcal{P}$
with $t \ge 2$ blocks, the closure of $\pi_{\mathcal{P}}(I_{\mathcal{P}})$ is
then a proper closed subset of $P_{\mathrm{pin}}$.
\end{lemma}
```

:::proof "exceptional_pin_parameters" (uses := "sparse_subgraph_selection, orbit_dimension_drop, isotropic_ideal_height, pin_fibre")
Case 1: some pair of blocks is joined by three or more pins. Their relative
twist is nonzero by the definition of the partition, so by the pin-fibre
lemma any three of those pin points are collinear, and collinear triples
form a proper closed subset of $`(\C^3)^3` cut out by the coordinates of a
cross product; its preimage under the projection to the three pins contains
$`\pi_{\mathcal{P}}(I_{\mathcal{P}})`.

Case 2: every pair is joined by at most two pins. Choose by Lemma 6.3 a
spanning $`(2,2)`-sparse subgraph $`F` with $`R` edges and one
representative pin per edge. The compatibility equation of a representative
pin gives the Split–Klein isotropic-difference equation of its edge, and the
block twists are pairwise distinct, so by
{bpref "ungrounded_variety"}[Corollary 5.4] — formally, by the grounded
height theorem it restates — the twist tuples
have dimension at most $`6(t-1) - R` once one twist is fixed. Each of the
$`M` cross-block pins then adds at most one dimension, since a nonempty pin
fibre is an affine line, and each of the $`N - M` within-block pins has zero
relative twist and adds three; hence
$`\dim I_{\mathcal{P}} \le 6(t-1) - R + M + 3(N - M)`. The scaling action is
free on $`I_{\mathcal{P}}` and $`\pi_{\mathcal{P}}` is constant on orbits,
so the orbit drop gives
$`\dim \pi_{\mathcal{P}}(I_{\mathcal{P}}) \le 3N + (6(t-1) - 2M - R) - 1
\le 3N - 1`, since $`R \ge 6(t-1) - 2M`.
:::

The formalization states properness as a certificate. The universal form is
a single proposition with no body–pin vocabulary in it:

```BodyPinBlueprint.bodies
RB31E2E.SparseNullIncidence.IsIncidenceRealization
RB31E2E.SparseNullIncidence.PropernessPrinciple
```

A realization is a pairwise distinct twist assignment satisfying the
selected occurrence equations, and the principle asserts one nonzero integer
polynomial $`Q` in the pin variables vanishing at every real realization,
whenever the selected edges form a sparse graph of exactly the budget
cardinality $`6(|V|-1) - 2|\mathrm{active}|`. The paper's two cases appear
as a dichotomy at the occurrence level,
{name RB31E2E.BodyPinIncidence.hasOnlySmallBundlesAt_or_tripleBundlePartitionCertificate}`hasOnlySmallBundlesAt_or_tripleBundlePartitionCertificate`:
either every crossing bundle of the partition has at most two pins, or some
bundle's fibre holds three pairwise distinct pins.

In the triple case the certificate is written down directly, as the
$`2 \times 2` minor asserting collinearity of three pin points:

```BodyPinBlueprint.bodies
RB31E2E.PinCollinearity.minor01
```

By {bpref "pin_fibre"}[the pin-fibre lemma] a nonzero common twist forces
the minor to vanish, and the minor is a nonzero polynomial because the three
occurrence labels are distinct — the witness is the explicit assignment
sending the three pins to $`0, e_1, e_2` — so distinctness of provenance
labels, not genericity, gives $`Q \ne 0`. In the small-bundle case
{name RB31E2E.BodyPinIncidence.exists_smallBundlePartitionPolynomial}`exists_smallBundlePartitionPolynomial`
applies the properness principle: the selection lemma above gives the
sparse skeleton at the budget cardinality, and the principle itself is
discharged by the chart layer of the closing section, whose height input is
the theorem of {bpref "isotropic_ideal_height"}[the Split–Klein chapter] and
whose dimension bookkeeping (the fibre count and the orbit drop of the
paper's Case 2) is carried out as height accounting in a graded polynomial
ring rather than as dimensions of varieties.

# The final assembly

:::lemma_ "sufficiency_assembly" (parent := "bodypin_spine") (lean := "RB31E2E.endToEndBodyPinStatement_of_sparseNullIncidenceProperness, RB31E2E.BodyPinIncidence.exists_real_twistRigidAt_of_partitionCertificates, RB31E2E.BodyPinIncidence.genericallyRigidInR3_of_hasRigidTwistRealization") (tags := "paper, deviation") (uses := "sparse_subgraph_selection, exceptional_pin_parameters, stress_codim")
If $`|W| \ge 2` and every partition of the bodies satisfies the capacity
inequality (1.2), then $`G_H` has a real placement attaining the rank of the
complete graph on the same vertex set, so it is generically infinitesimally
rigid; the empty and one-body cases are immediate. With the Asimow–Roth
theorem this completes Theorem 1.1, and in the maximum-rank form it is the
sufficiency half of Theorem A.1.
{Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

:::proof "sufficiency_assembly" (uses := "twist_description")
For each nontrivial partition $`\mathcal{P}` the exceptional locus
$`Z_{\mathcal{P}} = \overline{\pi_{\mathcal{P}}(I_{\mathcal{P}})}` is a
proper closed subset of the irreducible space $`P_{\mathrm{pin}}`, and there
are finitely many partitions, so some $`p^* \in P_{\mathrm{pin}}` avoids
them all. A nondiagonal twist solution at $`p^*` would have a nontrivial
twist-equality partition $`\mathcal{P}` and put $`p^*` into
$`Z_{\mathcal{P}}`; hence at $`p^*` only diagonal twists are compatible.
Fixing one body's twist to zero, the compatibility matrix $`C_H(p^*)` has
full column rank, so some minor of order $`6(|W|-1)` is a nonzero integer
polynomial $`f` in the pin coordinates; multiplying by the pairwise
distinctness polynomial $`\Delta_{\mathrm{dist}}` and choosing a real
non-vanishing point gives a real, pairwise distinct pin placement at which
$`C_H` still has full column rank. Giving each body four affinely
independent private points and avoiding the finitely many previously chosen
points, the twist description shows the resulting real framework has only
trivial infinitesimal motions, so $`G_H` attains the complete-graph rank;
{bpref "asimow_roth"}[the Asimow–Roth theorem] then gives generic rigidity
in the usual sense, which is the step that belongs to
{bpref "bodypin_partition_characterization"}[Theorem 1.1] rather than to
the maximum-rank form proved here.
:::

```tex "sufficiency_assembly" (slot := "proof")
\begin{proof}
If $W = \emptyset$, its unique empty partition satisfies equation (1.2), and
both $G_H$ and the complete graph on the same vertex set are empty.  If
$|W| = 1$, then $W$ has only the one-block partition and $G_H$ is complete.
Thus (i) and (ii) hold in both cases.  Hence assume that $|W| \ge 2$ and
that equation (1.2) holds.  For every nontrivial partition $\mathcal{P}$,
set
\[
  Z_{\mathcal{P}} = \overline{\pi_{\mathcal{P}}(I_{\mathcal{P}})}
    \subsetneq P_{\mathrm{pin}}.
\]
By Proposition 6.5, $Z_{\mathcal{P}}$ is a proper closed subset.  The set
$W$ has only finitely many partitions, and the affine space
$P_{\mathrm{pin}}$ is irreducible.  Therefore
\[
  P_{\mathrm{pin}} \setminus \bigcup_{\mathcal{P}} Z_{\mathcal{P}} \ne
  \emptyset.
\]
Choose $p^* \in P_{\mathrm{pin}} \setminus \bigcup_{\mathcal{P}}
Z_{\mathcal{P}}$.  If the pin configuration $p^*$ admitted a nondiagonal
twist solution, its twist-equality partition would give a nontrivial
$\mathcal{P}$, and hence $p^* \in Z_{\mathcal{P}}$, a contradiction.  Thus
at $p^*$ the only solutions of equation (6.1) are diagonal twists.

Fix the twist of one body to be zero, and denote the resulting
compatibility matrix by $C_H(p)$.  The matrix $C_H(p^*)$ has full column
rank, so it has a nonzero minor of order $6(|W| - 1)$.  The determinant of
this minor is a nonzero polynomial
\[
  f \in \mathbb{Z}[p_{e,i} : e \in E, 1 \le i \le 3].
\]
Set also
\[
  \Delta_{\mathrm{dist}} = \prod_{\{e, e'\} \in \binom{E}{2}}
    \sum_{i=1}^{3} (p_{e,i} - p_{e',i})^2.
\]
$f \Delta_{\mathrm{dist}}$ is nonzero in the real polynomial ring, so there
is a real pin configuration $p$ at which it does not vanish.  The pin
points are then pairwise distinct, and $C_H(p)$ still has full column rank.

Fix this pin configuration $p$.  For each body, choose four affinely
independent private points distinct from all previously chosen points, and
then choose its remaining private points successively while avoiding the
finite set already chosen.  By Lemma 6.1, the resulting real framework has
only trivial infinitesimal motions.  Thus $G_H$ has a realization attaining
the rank of the complete graph on the same vertex set and is generically
infinitesimally rigid.  The Asimow--Roth theorem then gives generic
rigidity in the usual sense [1, 2].
\end{proof}
```

The formal assembly follows the same outline one certificate earlier: the
paper avoids the union of the loci $`Z_{\mathcal{P}}` and only then writes
down the integer polynomial $`f`, while the formalization already holds
one nonzero integer certificate per partition, so
{name RB31E2E.BodyPinIncidence.exists_real_twistRigidAt_of_partitionCertificates}`exists_real_twistRigidAt_of_partitionCertificates`
takes the product over the finitely many partitions, picks a real point
where it does not vanish (a nonzero real polynomial is nonzero somewhere,
{name RB31E2E.ComplexRealSpecialization.exists_real_eval_ne_zero}`exists_real_eval_ne_zero`,
which is the only declaration of {srcFile}`ComplexRealSpecialization.lean`
the root theorem reaches), and concludes that the twist system at that pin
placement is rigid. In particular the paper's passage from $`\C` back to
$`\R`, and the compatibility-matrix minor $`f`, have no formal counterpart:
the certificates are integer polynomials from the start, and twist rigidity
at the chosen placement is the direct conclusion. From twist rigidity,
{name RB31E2E.BodyPinIncidence.genericallyRigidInR3_of_hasRigidTwistRealization}`genericallyRigidInR3_of_hasRigidTwistRealization`
builds the actual placement — the standard tetrahedron
$`0, e_1, e_2, e_3` on each body's four core vertices, remaining private
vertices at the origin — and identifies its motion kernel with the
complete graph's, which is the maximum-rank form of rigidity that
{bpref "formal_statement"}[Theorem A.1] states; necessity, already proved,
turns the implication into the equivalence through
{name RB31E2E.endToEndBodyPinStatement_iff_sufficiency}`endToEndBodyPinStatement_iff_sufficiency`.
The whole sufficiency direction is
{name RB31E2E.endToEndBodyPinStatement_of_sparseNullIncidenceProperness}`endToEndBodyPinStatement_of_sparseNullIncidenceProperness`,
conditional on exactly one proposition, the properness principle above.

# The chart layer

:::lemma_ "lean_chart_layer" (parent := "bodypin_infrastructure") (lean := "RB31E2E.UniversalHomogeneousChart.FiniteGenericIncidenceProvenancePrimeHeightCondition, RB31E2E.SparseNullIncidence.propernessPrinciple_of_finiteGenericFullProvenancePrimeHeights") (tags := "lean-only") (uses := "isotropic_ideal_height, orbit_dimension_drop") (uses_intent := "technical")
Sixteen modules that derive the properness principle from one
commutative-algebra hypothesis: in the nested polynomial ring with pin
coordinates as coefficients and grounded twist coordinates as outer
variables, every homogeneous prime over the chart ideal that avoids the
provenance denominator has full height. The largest Lean-only cluster in
the development, documented as one node; the module inventory is in the
correspondence chapter.
:::

The layer works in a single nested ring
$`\Q[\text{pin variables}][\text{grounded twist variables}]`, where the
standard grading of the outer ring is the twist grading: each Split–Klein
equation is homogeneous of degree two and each pin-compatibility coordinate
homogeneous of degree one, so the free scaling action of the paper's
Lemma 6.4 appears as homogeneity of the chart ideal. Its interface is one
$`\mathrm{Prop}`-valued definition,

```BodyPinBlueprint.bodies
RB31E2E.UniversalHomogeneousChart.FiniteGenericIncidenceProvenancePrimeHeightCondition
```

and the choice of denominator carries the geometry: one nonzero
twist-difference coordinate per ordered pair of distinct bodies removes both
the scaling orbit and every equality-collapse component, replacing the
paper's normalization of a single twist, and one nonzero angular coordinate
per active occurrence makes each pin's two remaining compatibility equations
triangular, so that the active occurrences provably contribute exactly two
units of height each. The selected-null ideal's height, from
{bpref "isotropic_ideal_height"}[the Split–Klein chapter], is the remaining
input; a full-height prime avoiding the denominator is then impossible by
{bpref "orbit_dimension_drop"}[the height-drop lemma], so a power of the
denominator lies in the chart ideal, and clearing denominators and applying
the rational-to-integer descent of
{name RB31E2E.RationalCertificateDescent.exists_integer_certificate_vanishing_on_real_zeros}`exists_integer_certificate_vanishing_on_real_zeros`
leaves the nonzero integer certificate the properness principle asserts.
That derivation is
{name RB31E2E.SparseNullIncidence.propernessPrinciple_of_finiteGenericFullProvenancePrimeHeights}`propernessPrinciple_of_finiteGenericFullProvenancePrimeHeights`,
and no module of the layer asserts a rigidity, properness or height fact of
its own.
