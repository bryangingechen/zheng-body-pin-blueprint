import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.SourceLinks
import BodyPinBlueprint.Bodies
import RB31EndToEnd.Combinatorics.Sparse22.DegreeThreeAugmentation
import RB31EndToEnd.Combinatorics.Sparse22.GraphExtension
import RB31EndToEnd.Combinatorics.Sparse22.Transport

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal
open BodyPinBlueprint

set_option doc.verso true

/-
# Sparse graphs and addable edges

Paper §2.1, together with the combinatorics the formalization needed and the
paper does not mention.

Witness conventions are described in the leading comment of `Statement.lean`.
Section 2.1 states its definitions in running prose, so the definition
witnesses here wrap the paper's own sentences in a reconstructed `definition`
environment; Lemma 2.1 is a numbered environment in the paper and its witness
uses that kind.

The `sparse22` witness joins two places in the paper: (1.3) and the $K_4$
example are from §1, and the sentence defining a tight set opens §2.1.  They are
one definition here because the chapter states sparsity and tightness together,
and because the paper's §2.1 sentence is unreadable without (1.3) beside it.

The paper gives the addable-edge criterion and the uncrossing property in one
sentence each, as two consequences of the same supermodularity argument.  They
are two nodes here because the formalization proves them separately and by
different routes, which is a distinction a reader checking the correspondence
needs to see.

Quoted bodies are named rather than copied; the convention is described in the
leading comment of `Statement.lean`.  Every `def` and `abbrev` a node here names
is quoted, which is the rule in the `AGENTS.md` beside this directory.  The
first fence also quotes `SimpleEdge.vertices`, which no node names: `edgesInside`
is written in field notation on a `SimpleEdge`, so the accessor is part of
reading it.  Names are given in the source's own order, which is the order the
fence renders in.

The imports are the whole `Sparse22` family and nothing else: none of those
nine modules reaches a blanket `import Mathlib`.

The reachability claims near the end come from `scripts/reachable.lean`;
`notes/reachability.md` has the method, and the module-by-module figures are
rendered in the correspondence chapter rather than here.
-/

#doc (Manual) "Sparse graphs and addable edges" =>

Section 2.1 of {Informal.citet "zheng2026"}[] defines the class of graphs on
which the paper's central estimate is proved: a simple graph is
$`(2,2)`-sparse when every nonempty vertex set $`U` spans at most $`2|U| - 2`
edges. The class enters the proof of the main theorem in its sufficiency
direction, that the partition condition implies generic rigidity. That
argument first selects, from the pins of a body–pin graph satisfying the
partition condition, a $`(2,2)`-sparse subgraph of representative pins —
{bpref "sparse_subgraph_selection"}[the selection lemma of Section 6.2] — and
then bounds the self-stresses of sparse graphs:
{bpref "stress_codim"}[the stress–codimension inequality], the estimate at the
centre of the paper, is stated for exactly this class.

The inequality is proved by deleting one vertex at a time. A $`(2,2)`-sparse
graph on $`n` vertices has at most $`2n - 2` edges, so some vertex has degree
at most three, and deleting a vertex leaves a sparse graph; the deletion
argument therefore never leaves the class and always has a vertex of degree at
most three to remove. We first state sparsity and tightness, then the two
consequences of supermodularity that the deletion argument uses, and then
Lemma 2.1, which gives an addable edge among the three neighbours of a
deleted degree-three vertex. In the exceptional case of
{bpref "low_degree_classification"}[the local classification] those three
neighbours are collinear, and the induction continues on the smaller graph
with one such edge added back, which restores the self-stress dimension; when
all three neighbour edges are already present, a collinearity flag is created
instead ({bpref "collinearity_flag"}[the flags chapter]). The last two
sections describe combinatorics that the formalization contains and the paper
never mentions: a construction theorem for $`(2,2)`-tight graphs, and a
transport lemma that moves sparsity along an embedding.

:::group "sparsity_spine"
The paper's sparsity vocabulary: the counting condition, tight sets, and the
two facts about them that the vertex-deletion induction uses.
:::

:::group "sparsity_infrastructure"
Combinatorics with no paper counterpart.
:::

# Sparsity and tight sets

:::definition "sparse22" (parent := "sparsity_spine") (lean := "RB31E2E.Sparse22, RB31E2E.Tight22") (tags := "paper")
A simple graph $`F = (V, E_F)` is $`(2,2)`-sparse when every nonempty
$`U \subseteq V` satisfies $`|E_F(U)| \le 2|U| - 2`, where $`E_F(U)` is the edge
set of the induced subgraph $`F[U]`. A nonempty $`U` attaining equality is
_tight_.
{Informal.citep "zheng2026" (kind := "equation") (index := "1.3")}[]
:::

```tex "sparse22"
\begin{definition}
Let $F = (V, E_F)$ be a simple graph, and for $U \subseteq V$ let $E_F(U)$
denote the edge set of the induced subgraph $F[U]$.  The graph $F$ is
$(2,2)$-sparse if every nonempty set $U \subseteq V$ satisfies
\begin{equation}
  |E_F(U)| \le 2|U| - 2.
  \tag{1.3}
\end{equation}
For example, $K_4$ has $6 = 2 \cdot 4 - 2$ edges, and every proper vertex
subset also satisfies (1.3); thus $K_4$ attains the $(2,2)$-sparsity bound.
Section 3 uses $K_4$ as the completion of a single flag.

A nonempty vertex set $U$ is $(2,2)$-tight if equality holds in (1.3), that is,
if $|E_F(U)| = 2|U| - 2$.
\end{definition}
```

The bound is stated for nonempty $`U` because $`2|U| - 2` is negative at
$`U = \emptyset`. A one-vertex set is tight, since both sides are zero, and
$`K_4` is tight on its whole vertex set. Sparsity passes to any subset of the
edge set, which is {name RB31E2E.Sparse22.mono}`Sparse22.mono`; deleting a
vertex from a sparse graph therefore leaves a sparse graph, as the deletion
step requires.

The formalization states the condition for a finite set of unordered pairs
rather than for a {name SimpleGraph}`SimpleGraph`: a
{name RB31E2E.SimpleEdge}`SimpleEdge` is a {name Sym2}`Sym2` of two distinct
vertices, and a {name RB31E2E.SimpleEdgeSet}`SimpleEdgeSet` is a
{name Finset}`Finset` of those, so parallel pins and loops are absent by
construction and multiplicity belongs to the body–pin layer, where the paper
also keeps it. The accessor
{name RB31E2E.SimpleEdge.vertices}`vertices` is quoted with them because
{name RB31E2E.edgesInside}`edgesInside` is written with it.

```BodyPinBlueprint.bodies
RB31E2E.SimpleEdge
RB31E2E.SimpleEdgeSet
RB31E2E.SimpleEdge.vertices
RB31E2E.edgesInside
RB31E2E.Sparse22
RB31E2E.Tight22
```

The right-hand side is written `2 * (X.card - 1)` over $`\N`, where truncated
subtraction gives $`0` at a one-vertex set. That is the same value as
$`2|U| - 2` over $`\Z` for every nonempty $`U`, and the nonemptiness hypothesis
is kept anyway, so the two readings agree wherever either is stated.

# Two consequences of supermodularity

Both lemmas of this section follow from the supermodularity of the edge-count
function: for any two vertex sets $`A` and $`B`,

$$`
|E_F(A)| + |E_F(B)| \le |E_F(A \cup B)| + |E_F(A \cap B)|,
`

since an edge inside $`A` or inside $`B` is inside $`A \cup B`, and an edge
inside both is inside $`A \cap B`.

:::lemma_ "uncrossing" (parent := "sparsity_spine") (lean := "RB31E2E.card_edgesInside_supermodular, RB31E2E.tight22_union_inter") (tags := "paper") (uses := "sparse22")
The union and the intersection of two tight sets with nonempty intersection are
again tight.
{Informal.citep "zheng2026" (kind := "section") (index := "2.1")}[]
:::

```tex "uncrossing"
\begin{lemma}
Supermodularity of the edge-count function gives the standard uncrossing
property: the union and intersection of two intersecting tight sets are again
tight.
\end{lemma}
```

Suppose $`A` and $`B` are tight and intersect. Adding the two sparsity bounds
on $`A \cup B` and $`A \cap B` to the two tightness equalities on $`A` and
$`B` forces both bounds to be equalities, which is the lemma.
{name RB31E2E.card_edgesInside_supermodular}`card_edgesInside_supermodular` is
the supermodularity inequality and
{name RB31E2E.tight22_union_inter}`tight22_union_inter` is the conclusion.

The intersection has to be nonempty because tightness is defined only for
nonempty sets, and a one-vertex intersection is enough. For disjoint $`A` and
$`B` neither conclusion holds.

:::lemma_ "addable_edge_criterion" (parent := "sparsity_spine") (lean := "RB31E2E.exists_tight22_of_not_sparse22_insert") (tags := "paper, deviation") (uses := "sparse22")
If adding a nonedge $`xy` to a $`(2,2)`-sparse graph violates sparsity, then
some tight set contains both $`x` and $`y`.
{Informal.citep "zheng2026" (kind := "section") (index := "2.1")}[]
:::

```tex "addable_edge_criterion"
\begin{lemma}
The same supermodularity argument gives the addable-edge criterion: if adding a
nonedge $xy$ violates $(2,2)$-sparsity, then some tight set contains both $x$
and $y$.
\end{lemma}
```

The paper obtains this lemma from the same supermodularity argument. The
formal proof is more direct. Let $`X` be a vertex set witnessing the
violation. Then $`X` contains both $`x` and $`y`, since otherwise adding the
edge changes no induced edge count; hence $`|E_F(X)| + 1 > 2|X| - 2`, while
sparsity of $`F` gives $`|E_F(X)| \le 2|X| - 2`, and $`X` is tight.
Supermodularity is never invoked, so
{name RB31E2E.exists_tight22_of_not_sparse22_insert}`exists_tight22_of_not_sparse22_insert`
is proved in the same module as the definitions, independently of uncrossing.

# An addable edge among three vertices

:::lemma_ "addable_edge_triple" (parent := "sparsity_spine") (lean := "RB31E2E.degree_three_neighbour_triangle_complete_or_addable") (tags := "paper") (uses := "sparse22")
Let $`Q` be a simple graph, let $`N = \{x, y, z\} \subseteq V(Q)`, and let
$`Q + vN` be $`Q` with a new vertex $`v` joined to all of $`N`. If $`Q + vN` is
$`(2,2)`-sparse and $`Q[N]` is not a triangle, then some nonedge of $`Q` with
both endpoints in $`N` can be added while preserving $`(2,2)`-sparsity.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.1")}[]
:::

```tex "addable_edge_triple"
\begin{lemma}[An addable edge among three vertices]
Let $Q$ be a simple graph and let $N = \{x, y, z\} \subseteq V(Q)$.  Denote by
$Q + vN$ the graph obtained by adding a new vertex $v$ and the three edges
$vx, vy, vz$.  If $Q + vN$ is $(2,2)$-sparse and $Q[N]$ is not a triangle, then
some nonedge of $Q$ with both endpoints in $N$ can be added to $Q$ while
preserving $(2,2)$-sparsity.
\end{lemma}
```

:::proof "addable_edge_triple" (uses := "uncrossing, addable_edge_criterion")
Suppose no nonedge within $`N` is addable. If $`xy` is the only nonedge, take a
tight set $`A` containing $`x` and $`y`. Either $`z \in A`, and $`A` already
contains $`N`, or $`z \notin A`, and the edges $`xz` and $`yz` make
$`A \cup \{z\}` tight. If $`N` has at least two nonedges, take two that share
an endpoint and a tight set containing the endpoints of each; uncrossing makes
their union a tight set containing $`N`. So in every case some tight set $`B`
contains $`N`. Adding $`v` and the three edges $`vN` to $`B` puts three new
edges on one new vertex, which violates the sparsity bound for $`Q + vN`.
:::

The formalization states the lemma as a dichotomy rather than under a
hypothesis: for a sparse edge set $`F` and a vertex $`v` of degree exactly
three with named neighbours $`a, b, c`, either all three edges between the
neighbours are present in $`F`, or one of the absent ones can be inserted
after deleting $`v`. Taking $`Q = F - v` recovers the paper's formulation. The
induction of {bpref "stress_codim_flags"}[the flags chapter] applies the
dichotomy directly: an inserted edge is a
{bpref "certified_response_edge"}[certified response edge], and on a complete
neighbour triangle a new flag is created.

The formal proof uses only the tight-set combinatorics above; in particular it
does not depend on the construction theorem of the next section. Like the
paper's proof, it splits on how many of the three neighbour edges are missing:
{name RB31E2E.degree_three_neighbour_triangle_complete_or_addable}`degree_three_neighbour_triangle_complete_or_addable`
combines one lemma for a single missing edge and one for two.

# A construction theorem with no paper counterpart

The formalization keeps an edge set on an ambient vertex type together with an
explicit finite set of _active_ vertices, the vertices on which the graph is
currently considered. The remaining statements of this chapter are phrased in
those terms.

:::lemma_ "lean_nixon_owen_reduction" (parent := "sparsity_infrastructure") (lean := "RB31E2E.HasNixonOwenReduction, RB31E2E.isK4Base_or_hasNixonOwenOrGraphExtensionReduction, RB31E2E.exists_tight22_completion") (tags := "lean-only")
On an active vertex set with at least two elements, a simple $`(2,2)`-tight
graph is either the complete graph on four vertices or admits a strictly
smaller legal reduction: one of the four inverse construction moves, or the
contraction of a proper tight module in one graph-extension step. Separately,
every $`(2,2)`-sparse edge set on a vertex type with at least four elements
has a same-vertex $`(2,2)`-tight completion.
:::

```BodyPinBlueprint.bodies
RB31E2E.HasNixonOwenReduction
```

The four `LegalInverse` predicates in that disjunction are inverse Henneberg
one and two, $`K_4`-to-vertex, and $`K_3`-to-edge, each defined directly on
edge sets. {srcFile}`Construction.lean` calls them the Nixon–Owen reductions; the name
is the module's own, and this blueprint has not checked it against a primary
source. A legal reduction strictly decreases the number of active vertices, so
repeated reductions terminate.

The degree-two case of the theorem is proved outright: deleting a degree-two
vertex of a tight graph leaves a smaller tight graph. The degree-three case
ends at a vertex contained in a $`(2,2)`-tight $`K_4`, and a triangle-sequence
argument would continue from there; {srcFile}`GraphExtension.lean` replaces that
continuation with a shorter one, over a proper tight module of maximum
cardinality, since tightness alone forces every outside vertex to send at most
one edge into the module unless that vertex has degree two and gives an
inverse Henneberg-one move.

None of this appears in {Informal.citet "zheng2026"}[]: the paper proves
Lemma 2.1 from uncrossing in a seven-line paragraph, proves Lemmas 3.7 and 3.8
in the same style, and its reference list contains no construction theorem.

Nor does the rest of the formalization depend on this section. Of the modules
that develop it, only a few counting facts are reachable from the root
theorem — facts about the four-element vertex set of a $`K_4` and about the
edges one outside vertex sends into a tight module — while the reduction
disjunction {name RB31E2E.HasNixonOwenReduction}`HasNixonOwenReduction`, the
graph-extension quotient, and the tight completion
{name RB31E2E.exists_tight22_completion}`exists_tight22_completion` are not
reachable at all. Lemmas 2.1, 3.7 and 3.8 therefore rest on the tight-set
arguments above, and this section is a parallel development; the
module-by-module accounting appears in the correspondence chapter.

:::lemma_ "lean_sparsity_transport" (parent := "sparsity_infrastructure") (lean := "RB31E2E.Sparse22Transport.mapEdgeSet, RB31E2E.Sparse22Transport.sparse22_of_mapEdgeSet_subset") (tags := "lean-only") (uses := "sparse22")
Sparsity transports along an injective map of vertices: if every image of a
child edge is an edge of a sparse parent set, the child set is sparse.
:::

```BodyPinBlueprint.bodies
RB31E2E.Sparse22Transport.mapEdgeSet
```

In the formalization, deleting a vertex leaves an edge set on a smaller
vertex type — the subtype of the remaining vertices — rather than on a subset
of one fixed vertex set, and creating a flag changes the type again, by
adjoining an auxiliary vertex. A sparse edge set therefore has to be moved
along an embedding at every step of the induction, and this lemma justifies
each such move.
No corresponding statement appears in the paper, whose graphs share one
ambient vertex set throughout.

The definition is one line, because an embedding of vertices induces an
embedding of unordered pairs, and {name Finset.map}`Finset.map` along an
embedding is injective. The image then has the cardinality of the source, so
both sides of the counting condition transport.
