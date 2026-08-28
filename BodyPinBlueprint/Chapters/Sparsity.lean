import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import RB31EndToEnd.Combinatorics.Sparse22.DegreeThreeAugmentation
import RB31EndToEnd.Combinatorics.Sparse22.GraphExtension
import RB31EndToEnd.Combinatorics.Sparse22.Transport

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

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

The quoted Lean block is preceded by a hidden `-show` block carrying the
section `variable` and the `open` it needs to elaborate.  Scopes carry from one
block to the next, so the visible block is verbatim with no scaffolding in it at
all.  It quotes `SimpleEdge.vertices` along with the two abbreviations and the three
definitions, in the source's own order, because `edgesInside` uses field
notation on a `SimpleEdge`: redeclaring the type without its accessor leaves
the upstream accessor expecting the upstream type, and the notation fails.

The imports are the whole `Sparse22` family and nothing else: none of those
nine modules reaches a blanket `import Mathlib`.

The reachability figures quoted at the end come from `scripts/reachable.lean`;
`notes/reachability.md` has the method and the whole table.
-/

#doc (Manual) "Sparse graphs and addable edges" =>

Section 2.1 of {Informal.citet "zheng2026"}[] is two paragraphs and one lemma.
It fixes the class of graphs the rest of the argument runs on, records the two
consequences of supermodularity that the induction needs, and shows that a
degree-three vertex whose three neighbours do not already form a triangle
leaves an addable edge behind. Every later chapter deletes a vertex from a
$`(2,2)`-sparse graph and then puts an edge back, so these are the two moves
the induction is built from.

The formalization covers the same ground in nine modules and 3,789 lines. Three
of them, 481 lines, carry the statements of Section 2.1. One more, 382 lines,
belongs to {bpref "sparse_subgraph_selection"}[the selection lemma of Section 6.2]. The
remaining 2,926 have no counterpart anywhere in the paper, and the last two
sections of this chapter say what they are.

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
edge set, which is
{name RB31E2E.Sparse22.mono}`Sparse22.mono` and is what lets the induction
delete a vertex and still have a sparse graph.

The formalization carries the condition on a finite set of unordered pairs
rather than on a `SimpleGraph`. A
{name RB31E2E.SimpleEdge}`SimpleEdge` is a `Sym2` of two distinct vertices and a
{name RB31E2E.SimpleEdgeSet}`SimpleEdgeSet` is a `Finset` of those, so parallel
pins and loops are absent by construction and multiplicity stays in the
body–pin layer where the paper also keeps it. The accessor
{name RB31E2E.SimpleEdge.vertices}`vertices` is quoted with them because
{name RB31E2E.edgesInside}`edgesInside` uses it.

```Verso.Genre.Manual.InlineLean.lean -show
variable {V : Type*} [DecidableEq V]
open RB31E2E hiding SimpleEdge SimpleEdgeSet edgesInside Sparse22 Tight22
```

```Verso.Genre.Manual.InlineLean.lean
-- RB31EndToEnd/Combinatorics/Sparse22/Basic.lean
abbrev SimpleEdge (V : Type*) := {e : Sym2 V // ¬e.IsDiag}

abbrev SimpleEdgeSet (V : Type*) := Finset (SimpleEdge V)

namespace SimpleEdge

def vertices (e : SimpleEdge V) : Finset V :=
  e.1.toFinset

end SimpleEdge

def edgesInside (F : SimpleEdgeSet V) (X : Finset V) : SimpleEdgeSet V :=
  F.filter fun e => e.vertices ⊆ X

def Sparse22 (F : SimpleEdgeSet V) : Prop :=
  ∀ X : Finset V, X.Nonempty → (edgesInside F X).card ≤ 2 * (X.card - 1)

def Tight22 (F : SimpleEdgeSet V) (X : Finset V) : Prop :=
  X.Nonempty ∧ (edgesInside F X).card = 2 * (X.card - 1)
```

The right-hand side is written `2 * (X.card - 1)` over $`\N`, where truncated
subtraction gives $`0` at a one-vertex set. That is the same value as
$`2|U| - 2` over $`\Z` for every nonempty $`U`, and the nonemptiness hypothesis
is kept anyway, so the two readings agree wherever either is stated.

# Two consequences of supermodularity

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

The supermodularity in question is
$`|E_F(A)| + |E_F(B)| \le |E_F(A \cup B)| + |E_F(A \cap B)|`, and it holds for
every pair of vertex sets: an edge inside $`A` or inside $`B` is inside
$`A \cup B`, and an edge inside both is inside $`A \cap B`. Adding the two
sparsity bounds on $`A \cup B` and $`A \cap B` to the two tightness equalities
on $`A` and $`B` forces both bounds to be equalities.
{name RB31E2E.card_edgesInside_supermodular}`card_edgesInside_supermodular` is
the inequality and
{name RB31E2E.tight22_union_inter}`tight22_union_inter` is the conclusion.

Nonempty intersection is required, and a one-vertex intersection is enough:
$`A \cap B` has to be a legitimate argument of the tightness condition. For
disjoint $`A` and $`B` neither conclusion holds, and the formalization records
that in the module comment rather than in a hypothesis name.

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

The paper obtains this from supermodularity, as the sentence says. The
formalization does not: it takes the vertex set $`X` witnessing the violation,
observes that $`X` must contain both endpoints, since otherwise the induced
edge counts before and after are equal, and reads tightness of $`X` off the
arithmetic. Supermodularity is never invoked, and
{name RB31E2E.exists_tight22_of_not_sparse22_insert}`exists_tight22_of_not_sparse22_insert`
is proved in the same module as the definitions, before uncrossing exists. The
divergence is recorded in `lt-source-deviations.toml`.

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
three with named neighbours $`a, b, c`, either all three neighbour edges are
present in $`F`, or one of the absent ones can be inserted after deleting $`v`.
Taking $`Q = F - v` recovers the paper's formulation, and the disjunction is
what the caller in the flag induction actually branches on.

The formal proof is a tight-set obstruction argument that does not go through
the construction theorem below, and does not need the graph to be tight or a
completion to have been chosen. The module comment of
`DegreeThreeAugmentation.lean` says so, and records why: the flag induction
needs the local fact before any completion is available.

The paper's proof splits on how many of the three neighbour pairs are missing;
so does the formalization, in the two lemmas that
{name RB31E2E.degree_three_neighbour_triangle_complete_or_addable}`degree_three_neighbour_triangle_complete_or_addable`
assembles, one for a single missing pair and one for two.

# The construction theorem the formalization carries

:::lemma_ "lean_nixon_owen_reduction" (parent := "sparsity_infrastructure") (lean := "RB31E2E.HasNixonOwenReduction, RB31E2E.isK4Base_or_hasNixonOwenOrGraphExtensionReduction, RB31E2E.exists_tight22_completion") (tags := "lean-only")
On at least two active vertices, a simple $`(2,2)`-tight graph is either the
complete graph on four vertices or admits a strictly smaller legal reduction:
one of the four inverse construction moves, or the contraction of a proper tight
module in one graph-extension step. Separately, every $`(2,2)`-sparse edge set
on a vertex type with at least four elements has a same-vertex $`(2,2)`-tight
completion.
:::

The four inverse moves are inverse Henneberg one and two, $`K_4`-to-vertex, and
$`K_3`-to-edge; `Construction.lean` calls them the Nixon–Owen reductions. The
formalization gives each of them literal edge-set semantics, on an ambient edge
set together with an explicit active vertex set, and closes the low-degree
branches. The long triangle-sequence branch is replaced by a shorter argument
on a maximum-cardinality proper tight module: tightness alone forces every
outside vertex to send at most one edge into the module, unless that vertex
already has degree two and supplies an inverse Henneberg-one move.

None of that appears in {Informal.citet "zheng2026"}[], which proves Lemma 2.1
from uncrossing in a seven-line paragraph and Lemmas 3.7 and 3.8 in the same
style. The paper's reference list does not contain the construction theorem
either.

Nor does the rest of the formalization use it. Walking the constant
dependencies of the root theorem through the kernel environment reaches nothing
from `TightCompletion.lean` but one equation lemma for a definition made
elsewhere; two declarations from `TriangleSequence.lean`, both about the
four-element vertex set of a named $`K_4`; eight from `GraphExtension.lean`,
all of them facts about the edges one outside vertex brings into a tight
module; and from `Construction.lean` its edge-set vocabulary rather than its
reduction theorems. The reduction
disjunction {name RB31E2E.HasNixonOwenReduction}`HasNixonOwenReduction`, the
graph-extension quotient, and the tight completion
{name RB31E2E.exists_tight22_completion}`exists_tight22_completion` are not
reachable from the root theorem at all.

So these 2,811 lines are not what Lemmas 2.1, 3.7 and 3.8 rest on. They are a
parallel development of a construction theorem, and what the main line takes
from them is vocabulary and four or five counting facts.
`lt-source-deviations.toml` records the divergence, `notes/reachability.md`
records the measurement, and `scripts/coverage.py --reachable` is what rechecks
it against a moved submodule pin.

:::lemma_ "lean_sparsity_transport" (parent := "sparsity_infrastructure") (lean := "RB31E2E.Sparse22Transport.mapEdgeSet, RB31E2E.Sparse22Transport.sparse22_of_mapEdgeSet_subset") (tags := "lean-only") (uses := "sparse22")
Sparsity transports along an injective map of vertices: if every image of a
child edge is an edge of a sparse parent set, the child set is sparse.
:::

Deletion and flag registration change the type of the live vertices rather than
removing elements from a fixed set, so a sparse edge set has to be moved along
an embedding at every step of the induction. The paper never has to say
anything here, because its graphs share one ambient vertex set throughout.
