import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Bodies
import BodyPinBlueprint.Figures
import RB31EndToEnd.Combinatorics.ProvenanceFlag
import RB31EndToEnd.Combinatorics.ProvenanceFlagForest
import RB31EndToEnd.Combinatorics.ProvenanceFlagSelection
import RB31EndToEnd.Combinatorics.ProvenanceFlagDeletion
import RB31EndToEnd.Combinatorics.ProvenanceFlagInsertion
import RB31EndToEnd.Combinatorics.ProvenanceFlagPrivateDeletion
import RB31EndToEnd.Combinatorics.ProvenanceFlagPrivatePivot
import RB31EndToEnd.Combinatorics.ProvenanceFlagOutsideMove
import RB31EndToEnd.Combinatorics.ProvenanceFlagOutsideRegistration
import RB31EndToEnd.Combinatorics.ProvenanceFlagPrivateMove
import RB31EndToEnd.Linear.PrivateLocalClassification
import RB31EndToEnd.Linear.PrivatePivotStress
import RB31EndToEnd.NullCellule.ProvenanceFlagBranch
import RB31EndToEnd.NullCellule.ProvenanceFlagSemismallness
import RB31EndToEnd.NullCellule.ProvenanceFlagSemismallnessFinal
import RB31EndToEnd.NullCellule.ProvenanceFlagGroundedPF
import RB31EndToEnd.NullCellule.GroundedPFEndToEnd

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Collinearity flags

Paper §3, in the paper's order, together with Theorem 1.2: the paper states
that theorem in §1 and proves it at the end of §3.5, by specializing
Theorem 3.9 to the empty flag family, so its node sits at the end of this
chapter.  Its witness is the §1 statement, verbatim and contiguous.

Witness conventions are described in the leading comment of `Statement.lean`.
Two reconstructions particular to this chapter: §3.2 defines the support
multiplicity and the sets O, P, S in running prose, so that witness wraps the
paper's sentences in a `definition` environment; and Proposition 3.3 is
rendered with `:::lemma_` and a `\begin{lemma}` witness, because the v4.29.0
release line has no proposition directive — the register records the
convention.  No witness in this chapter joins separated pieces of the paper.
The unmatched windows that `check-witness-prose.py` reports here were each
checked and are text-layer artifacts, of three kinds: pdftotext sets the
raised hat of a completion Ĝ on its own line, which scrambles the word order
around (3.8), (3.13) and the end of Lemma 3.5; math tokens such as `degG`,
`dimK` and `trdegk` survive as words in the text layer but not in a LaTeX
transcription; and §1 hyphenates "configu-rations" across a line break.

Quoted bodies are named rather than copied; the mechanism is described in the
leading comment of `Statement.lean`.  Every `def` and `abbrev` a node here
names is quoted, which is the rule in the `AGENTS.md` beside this directory.
Several further definitions are quoted that no node names — the completion
edge sets, the live-vertex partition, and the function-field branch
vocabulary — because the nodes' statements are unreadable without them.

Two nodes name structure projections (`State.terminals`, `State.missing`).
A projection is declared by its parent structure rather than by a command of
its own, so the coverage script classifies it through the parent and applies
no quoted-body rule to it.

This chapter cannot stay inside the Mathlib-blanket-free part of the
formalization: the semismallness and grounding modules it documents sit in
`NullCellule/` and reach the blanket imports through the direction-stress
layer.  The import list is still the specific modules the nodes and roles
reference.
-/

#doc (Manual) "Collinearity flags" =>

Section 3 of {Informal.citet "zheng2026"}[] proves the estimate at the centre
of the paper: for a $`(2,2)`-sparse graph $`F` and an injective configuration
$`a : V \to K^3` whose coordinates generate the finitely generated extension
$`K/k`,

$$`
\dim_K \ker D_F(a)^T + \trdeg_k K \le 3|V|.
`

The inequality is proved by deleting one low-degree vertex at a time, and by
{bpref "deletion_ledger"}[the deletion ledger] the change in the defect at
each step is the local increment $`u + \delta_v` less three, so the defect
does not increase exactly when $`u + \delta_v \le 3`. In the exceptional
case of
{bpref "low_degree_classification"}[the local classification] that bound
fails — the deleted vertex has exactly three neighbours, their configuration
points are collinear, and $`u + \delta_v = 4` — but
{bpref "neighbour_rigidity_rows"}[the three rigidity rows on pairs of
neighbours] already lie in the row space of the deleted graph. When one of
the three neighbour edges is absent and can be added, adding it restores the
lost stress dimension and the induction continues. When all three are
present, no edge can be added, and the paper instead strengthens the
statement being proved: the triple is retained as a _collinearity flag_,
together with a chosen missing edge on it and an auxiliary vertex, and the
inequality becomes

$$`
\dim_K \ker D_G(a)^T + \trdeg_k K + 2|\Gamma| \le 3|V|
`

for a graph carrying a family $`\Gamma` of such flags, with a term of two
for each flag, the codimension of the collinearity condition on its triple.
That statement is Theorem 3.9, this chapter's main result; the flag-free
case $`\Gamma = \emptyset` is Theorem 1.2, the inequality above.

We first state the flag vocabulary and the sparsity condition on the
simultaneous completion, then the counting facts about how flags may overlap.
A selection lemma then gives a low-degree vertex that is in no flag or in
exactly one; for the second type there are a pivot and a local
classification; two augmentation lemmas give the edge that is added back in
each exceptional case; and the proof of Theorem 3.9 combines them into the
induction. A closing section describes the transitions between flag states
that the formalization builds and the paper performs inside one proof.

The formalization renames every object of this section, so the two
vocabularies are set side by side once, here, before either is used:

:::table +header
* * The paper
  * The formalization
* * collinearity flag
  * provenance flag
* * support triple $`T_\gamma`
  * terminals ({name RB31E2E.ProvenanceFlag.State.terminals}`terminals`)
* * distinguished missing edge $`d_\gamma`
  * missing terminal edge ({name RB31E2E.ProvenanceFlag.State.missing}`missing`)
* * auxiliary vertex $`g_\gamma`
  * ghost vertex, an inhabitant of the flag type itself
* * base-graph vertices and edges
  * live vertices and live edges
* * simultaneous completion $`\widehat{G}`
  * {name RB31E2E.ProvenanceFlag.State.completionEdges}`completionEdges`, an edge set on $`V \oplus \Gamma`
* * support multiplicity $`h_x`
  * {name RB31E2E.ProvenanceFlag.State.flagMultiplicity}`flagMultiplicity`
* * the sets $`O`, $`P`, $`S`
  * {name RB31E2E.ProvenanceFlag.State.outsideVertices}`outsideVertices`, {name RB31E2E.ProvenanceFlag.State.privateVertices}`privateVertices`, {name RB31E2E.ProvenanceFlag.State.sharedVertices}`sharedVertices`
* * self-stress dimension $`s = \dim_K \ker D_G(a)^T`
  * {name RB31E2E.DirectionStress.directionStressDim}`directionStressDim`
* * the inequality $`\Delta(G, \Gamma, a) \le 0`
  * the semismallness budget ({name RB31E2E.ProvenanceFlag.FunctionFieldBranch.SemismallBudget}`SemismallBudget`)
* * local payment $`u + \delta_v \le 3` or $`\le 1`
  * {name RB31E2E.DirectionStress.OutsideNonexceptional}`OutsideNonexceptional`, {name RB31E2E.DirectionStress.PrivateNonexceptional}`PrivateNonexceptional`
* * certified response edge
  * virtual response edge
:::

:::group "flags_spine"
The paper's flag vocabulary and the results of Section 3: definitions,
overlap counting, selection, pivot, classification, augmentation, and the
stress–codimension theorem.
:::

:::group "flags_infrastructure"
Transitions between flag states, with no paper counterpart.
:::

# Flags and their completions

:::definition "collinearity_flag" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.terminals, RB31E2E.ProvenanceFlag.State.missing, RB31E2E.ProvenanceFlag.ghostEdge") (tags := "paper, deviation")
A collinearity flag on a finite simple graph $`G = (V, E)` is a chain
$`d_\gamma \subsetneq T_\gamma \subsetneq Q_\gamma` together with an
auxiliary vertex $`g_\gamma \notin V`: a three-element support triple
$`T_\gamma \subseteq V` inducing the two-edge path
$`E(G[T_\gamma]) = \binom{T_\gamma}{2} \setminus \{d_\gamma\}`, the
distinguished missing edge $`d_\gamma`, and $`Q_\gamma = T_\gamma \sqcup
\{g_\gamma\}`. A configuration $`a : V \to K^3` realizes the flag if the
points $`\{a_x : x \in T_\gamma\}` are collinear; the $`K_4`-completion
restores $`d_\gamma` and joins $`g_\gamma` to the three support vertices.
{Informal.citep "zheng2026" (index := "Definition 3.1")}[]
:::

```tex "collinearity_flag"
\begin{definition}[Collinearity flag]
Let $G = (V, E)$ be a finite simple graph.  Choose a three-element set
$T_\gamma \subseteq V$ and an edge $d_\gamma \in \binom{T_\gamma}{2}$ such that
\begin{equation}
  E(G[T_\gamma]) = \binom{T_\gamma}{2} \setminus \{d_\gamma\}.
  \tag{3.1}
\end{equation}
Choose an auxiliary vertex $g_\gamma \notin V$, set
$Q_\gamma = T_\gamma \sqcup \{g_\gamma\}$, and consider the chain
\begin{equation}
  d_\gamma \subsetneq T_\gamma \subsetneq Q_\gamma, \qquad
  (|d_\gamma|, |T_\gamma|, |Q_\gamma|) = (2, 3, 4),
  \tag{3.2}
\end{equation}
subject to (3.1).  Together with the auxiliary vertex $g_\gamma$, the chain
(3.2) is called a collinearity flag.  It is a partial flag in the face lattice
of the abstract 3-simplex $\Delta(Q_\gamma)$: $d_\gamma$, $T_\gamma$, and
$Q_\gamma$ specify an edge, a two-dimensional face, and the whole 3-simplex,
respectively.  We call $T_\gamma$ the support triple, $d_\gamma$ the
distinguished missing edge, and $g_\gamma$ the auxiliary vertex.  If
$T_\gamma = \{x, y, z\}$ and $d_\gamma = \{x, z\}$, then (3.1) may also be
written as the induced two-edge path $x - y - z$.  The notation $x - y - z$
specifies only the middle vertex $y$ and does not orient the flag.

A configuration $a : V \to K^3$ over a field $K$ realizes the flag if the
points $\{a_x : x \in T_\gamma\}$ are collinear.  The $K_4$-completion of the
flag restores $d_\gamma$ and adds the three auxiliary edges
$\{g_\gamma x : x \in T_\gamma\}$.
\end{definition}
```

The formalization calls a collinearity flag a _provenance flag_ and has no
object representing one flag on its own. A flag is an inhabitant $`t` of a
finite index type, and its data are the values at $`t` of the fields
{name RB31E2E.ProvenanceFlag.State.terminals}`terminals` and
{name RB31E2E.ProvenanceFlag.State.missing}`missing` of the
system-level structure of the next node, whose remaining fields are
conditions (3.1) and (3.2): each terminal set has three elements, the
missing edge lies inside it, is absent from the live graph, and every other
terminal pair is present.
The auxiliary vertex needs no name of its own, since the completion is built
on the sum type $`V \oplus \Gamma` and the ghost vertex of the flag $`t` is
the right summand $`t` itself. The realization condition is not part of the
combinatorial object; it reappears as the collinearity field of the
function-field branches defined before Theorem 3.9 below.

Figure 2 of {Informal.citet "zheng2026"}[] distinguishes the four kinds of
edge; in the redrawing below, the support triple induces the two-edge path
$`x - y - z` with the dashed arc as the distinguished missing edge
$`d_\gamma = xz`, and the completion restores $`xz` and adds the three
auxiliary edges from $`g_\gamma` to the support vertices. The auxiliary
vertex has no configuration coordinate.

```BodyPinBlueprint.svgFigure (alt := "A collinearity flag as the two-edge path x-y-z with a dashed missing edge from x to z, and its K4 completion, which restores that edge and joins a new vertex g to x, y, and z")
<svg viewBox="0 0 760 255" xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
  <g font-size="12.5">
    <text x="170" y="22" text-anchor="middle" font-weight="600">Flag in the current graph</text>
    <line x1="70" y1="115" x2="170" y2="115" stroke="currentColor" stroke-width="2"/>
    <line x1="170" y1="115" x2="270" y2="115" stroke="currentColor" stroke-width="2"/>
    <path d="M 70 115 Q 170 190 270 115" fill="none" stroke="currentColor" stroke-width="1.6" stroke-dasharray="7 5"/>
    <circle cx="70" cy="115" r="4" fill="currentColor"/>
    <circle cx="170" cy="115" r="4" fill="currentColor"/>
    <circle cx="270" cy="115" r="4" fill="currentColor"/>
    <text x="70" y="102" text-anchor="middle" font-style="italic">x</text>
    <text x="170" y="102" text-anchor="middle" font-style="italic">y</text>
    <text x="270" y="102" text-anchor="middle" font-style="italic">z</text>
    <text x="170" y="178" text-anchor="middle" font-style="italic">d<tspan baseline-shift="sub" font-size="9">γ</tspan></text>
    <text x="170" y="208" text-anchor="middle">a<tspan baseline-shift="sub" font-size="9" font-style="italic">x</tspan>, a<tspan baseline-shift="sub" font-size="9" font-style="italic">y</tspan>, a<tspan baseline-shift="sub" font-size="9" font-style="italic">z</tspan> collinear</text>
    <line x1="305" y1="115" x2="408" y2="115" stroke="currentColor" stroke-width="1.6"/>
    <polygon points="408,109 421,115 408,121" fill="currentColor"/>
    <text x="362" y="98" text-anchor="middle">K<tspan baseline-shift="sub" font-size="9">4</tspan> completion</text>
    <text x="590" y="22" text-anchor="middle" font-weight="600">Completion on Q<tspan baseline-shift="sub" font-size="9" font-style="italic">γ</tspan></text>
    <line class="bpx_fig_auxiliary" x1="590" y1="55" x2="490" y2="140" stroke-width="1.6" stroke-dasharray="2 4"/>
    <line class="bpx_fig_auxiliary" x1="590" y1="55" x2="590" y2="140" stroke-width="1.6" stroke-dasharray="2 4"/>
    <line class="bpx_fig_auxiliary" x1="590" y1="55" x2="690" y2="140" stroke-width="1.6" stroke-dasharray="2 4"/>
    <line x1="490" y1="140" x2="590" y2="140" stroke="currentColor" stroke-width="2"/>
    <line x1="590" y1="140" x2="690" y2="140" stroke="currentColor" stroke-width="2"/>
    <path class="bpx_fig_restored" d="M 490 140 Q 590 210 690 140" fill="none" stroke-width="2.2"/>
    <circle cx="590" cy="55" r="4" fill="currentColor"/>
    <circle cx="490" cy="140" r="4" fill="currentColor"/>
    <circle cx="590" cy="140" r="4" fill="currentColor"/>
    <circle cx="690" cy="140" r="4" fill="currentColor"/>
    <text x="590" y="42" text-anchor="middle" font-style="italic">g<tspan baseline-shift="sub" font-size="9">γ</tspan></text>
    <text x="478" y="136" text-anchor="end" font-style="italic">x</text>
    <text x="602" y="133" text-anchor="start" font-style="italic">y</text>
    <text x="702" y="136" text-anchor="start" font-style="italic">z</text>
    <line x1="60" y1="238" x2="95" y2="238" stroke="currentColor" stroke-width="2"/>
    <text x="102" y="242" text-anchor="start">current</text>
    <line x1="215" y1="238" x2="250" y2="238" stroke="currentColor" stroke-width="1.6" stroke-dasharray="7 5"/>
    <text x="257" y="242" text-anchor="start">missing</text>
    <line class="bpx_fig_restored" x1="370" y1="238" x2="405" y2="238" stroke-width="2.2"/>
    <text class="bpx_fig_restored_text" x="412" y="242" text-anchor="start">restored</text>
    <line class="bpx_fig_auxiliary" x1="530" y1="238" x2="565" y2="238" stroke-width="1.6" stroke-dasharray="2 4"/>
    <text class="bpx_fig_auxiliary_text" x="572" y="242" text-anchor="start">auxiliary star</text>
  </g>
</svg>
```

:::definition "flag_system" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State, RB31E2E.ProvenanceFlag.State.completionEdges, RB31E2E.ProvenanceFlag.State.CompletionSparse") (tags := "paper, deviation") (uses := "collinearity_flag, sparse22")
A system of collinearity flags on a common base graph $`G = (V, E)` is a
family $`(d_\gamma \subsetneq T_\gamma \subsetneq Q_\gamma)_{\gamma \in
\Gamma}` with pairwise distinct auxiliary vertices outside $`V`. Its
simultaneous flag completion $`\widehat{G}` is the graph on
$`V \sqcup \{g_\gamma : \gamma \in \Gamma\}` obtained by restoring every
$`d_\gamma` and attaching every auxiliary star $`\{g_\gamma x : x \in
T_\gamma\}`. The system is a _sparse collinearity-flag system_ if
$`\widehat{G}` is $`(2,2)`-sparse.
{Informal.citep "zheng2026" (index := "Definition 3.2")}[]
:::

```tex "flag_system"
\begin{definition}[Sparse collinearity-flag system]
Let $\Gamma$ be a finite set.  On a common base graph $G = (V, E)$, consider a
family of collinearity flags
\[
  \bigl( d_\gamma \subsetneq T_\gamma \subsetneq Q_\gamma \bigr)_{\gamma \in \Gamma},
\]
whose auxiliary vertices are pairwise distinct and all lie outside $V$.  Such
a family is called a system of collinearity flags.  Its simultaneous flag
completion is the simple graph $\widehat{G}$ on
$V \sqcup \{g_\gamma : \gamma \in \Gamma\}$ with edge set
\begin{equation}
  E(\widehat{G}) = E(G) \cup \bigcup_{\gamma \in \Gamma}
    \bigl( \{d_\gamma\} \cup \{g_\gamma x : x \in T_\gamma\} \bigr),
  \tag{3.3}
\end{equation}
where the set-theoretic unions identify repeated edges automatically.  The
system is a sparse collinearity-flag system if $\widehat{G}$ is $(2,2)$-sparse.

A configuration $a : V \to K^3$ realizes the flag system if it realizes every
flag in the family.  Write $\mathcal{T} = \{T_\gamma : \gamma \in \Gamma\}$,
and let $X^\circ_{\mathcal{T}}$ be the quasi-affine variety in
$(\mathbb{A}^3_k)^V$ consisting of configurations that assign distinct points
to distinct vertices and realize every flag.  The auxiliary vertices have no
configuration coordinates and do not enter $D_G$; they are used only to test
the combinatorial sparsity in (3.3).
\end{definition}
```

The formalization's {name RB31E2E.ProvenanceFlag.State}`State` is this
definition on exact types: the vertex type $`V` contains exactly the base
graph's vertices, called the _live_ vertices, and the flag type contains
exactly the active flags, so no ambient labels, inactive flags, or support
predicates occur. Deleting a vertex or a flag therefore changes the types
themselves, which is why {bpref "lean_sparsity_transport"}[the transport
lemma of the sparsity chapter] is used at every step of the induction. The
completion is a literal edge set on $`V \oplus \Gamma`, assembled from three
packets: the live edges transported along the left injection, one restored
missing edge per flag, and one ghost star per flag.

```BodyPinBlueprint.bodies
RB31E2E.ProvenanceFlag.liftLiveEdge
RB31E2E.ProvenanceFlag.ghostEdge
RB31E2E.ProvenanceFlag.State.liftedLiveEdges
RB31E2E.ProvenanceFlag.State.restoredMissingEdges
RB31E2E.ProvenanceFlag.State.ghostStarEdges
RB31E2E.ProvenanceFlag.State.completionEdges
RB31E2E.ProvenanceFlag.State.CompletionSparse
```

The paper's (3.3) takes a union of edge sets on a disjoint union of vertex
sets and lets repeated edges identify themselves; the formalization takes the
same union of three {name Finset}`Finset`s, and
{name RB31E2E.ProvenanceFlag.State.CompletionSparse}`CompletionSparse` is
{bpref "sparse22"}[the sparsity predicate] applied to the result. No
consequence of sparsity is stored in the structure: the counting facts of the
next section are derived from these fields whenever the induction needs them.
The variety $`X^\circ_{\mathcal{T}}` has no Lean counterpart; its
function-field substitute is defined before Theorem 3.9.

# The incidence forest

Two flags may share support vertices, and the counting of this section
bounds how much. Following the paper, let
$`V_{\mathcal{T}} = \bigcup_{\gamma \in \Gamma} T_\gamma` and let
$`B_{\mathcal{T}}` be the bipartite incidence graph with vertex classes
$`\Gamma` and $`V_{\mathcal{T}}`, in which $`\gamma` is adjacent to $`x` if
and only if $`x \in T_\gamma`.

:::lemma_ "flag_incidence_forest" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.card_terminal_inter_le_one, RB31E2E.ProvenanceFlag.State.two_mul_card_add_one_le_card_terminalUnion, RB31E2E.ProvenanceFlag.State.terminalHyperforest") (tags := "paper, deviation") (uses := "flag_system")
In a sparse collinearity-flag system, every nonempty subfamily of $`j \ge 1`
flags uses $`q \ge 2j + 1` support vertices in total; consequently
$`B_{\mathcal{T}}` is a forest. Moreover $`X^\circ_{\mathcal{T}}` is
irreducible of codimension $`2|\Gamma|` in $`(\mathbb{A}^3_k)^V`.
{Informal.citep "zheng2026" (index := "Proposition 3.3")}[]
:::

```tex "flag_incidence_forest"
\begin{lemma}[The incidence forest of flag supports]
Suppose that a nonempty subfamily of $j \ge 1$ flags uses $q$ support
vertices in total.  Then
\begin{equation}
  q \ge 2j + 1.
  \tag{3.4}
\end{equation}
Consequently, the incidence graph $B_{\mathcal{T}}$ is a forest.  Moreover,
$X^\circ_{\mathcal{T}}$ is irreducible and
\begin{equation}
  \operatorname{codim}_{(\mathbb{A}^3_k)^V} X^\circ_{\mathcal{T}} = 2|\Gamma|.
  \tag{3.5}
\end{equation}
\end{lemma}
```

:::proof "flag_incidence_forest" (uses := "sparse22")
For each $`\gamma`, the set $`T_\gamma \cup \{g_\gamma\}` induces a tight
copy of $`K_4` in $`\widehat{G}`. Two distinct flags share at most one
support vertex: equal triples would put nine edges on five vertices, and two
shared vertices would put eleven on six, both violating sparsity. Any $`j`
flags therefore contribute $`6j` pairwise disjoint edges on $`q + j`
vertices, so $`6j \le 2(q + j) - 2`, which is $`q \ge 2j + 1`. A cycle of
$`j` flag vertices in $`B_{\mathcal{T}}` would use at most $`2j` support
vertices, contradicting that bound, so $`B_{\mathcal{T}}` is a forest.

For the geometric half, the paper puts coordinates on one support triple:
collinearity of three points is the condition
$`\operatorname{rank}[\,u\ v\,] \le 1` on the two difference vectors, an
irreducible determinantal variety of codimension two. Adding flags one at a
time along an incidence tree meets the existing supports in at most one
vertex, so each flag multiplies by the same variety and the codimension grows
by two; products over components, free factors for untouched vertices, and
removing the collision diagonals give (3.5).
:::

The counting half is formalized and the geometric half is not. Distinct
triples sharing at most one live vertex is
{name RB31E2E.ProvenanceFlag.State.card_terminal_inter_le_one}`card_terminal_inter_le_one`,
and (3.4) is
{name RB31E2E.ProvenanceFlag.State.two_mul_card_add_one_le_card_terminalUnion}`two_mul_card_add_one_le_card_terminalUnion`;
both are derived from the actual finite edge unions, with the six-edge count
and the pairwise disjointness proved as {name Finset}`Finset` identities.
The bipartite graph $`B_{\mathcal{T}}` is never constructed: the proof of
the selection lemma below uses only the quantified inequality itself, stated
as {name RB31E2E.ProvenanceFlag.State.TerminalHyperforest}`TerminalHyperforest`
and proved from completion sparsity.

```BodyPinBlueprint.bodies
RB31E2E.ProvenanceFlag.State.terminalUnion
RB31E2E.ProvenanceFlag.State.TerminalHyperforest
```

The variety $`X^\circ_{\mathcal{T}}`, its irreducibility, and the
codimension (3.5) have no Lean counterpart, in the same way that
{bpref "direction_complex"}[the scheme-theoretic statements of the strata
chapter] have none. The number $`2|\Gamma|` still appears, as the flag term
of the semismallness budget defined before Theorem 3.9: the formal induction
proves the inequality (3.14) directly, and the paper's reading of
$`2|\Gamma|` as a codimension is not needed for it.

# A global low-degree choice

:::definition "support_multiplicity" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.flagMultiplicity, RB31E2E.ProvenanceFlag.State.card_live_partition") (tags := "paper") (uses := "flag_system")
For $`x \in V`, the support multiplicity
$`h_x = |\{\gamma \in \Gamma : x \in T_\gamma\}|` counts the flags whose
support triple contains $`x`, and it partitions the live vertices into
$`O = \{h_x = 0\}`, $`P = \{h_x = 1\}` and $`S = \{h_x \ge 2\}`, so
$`|O| + |P| + |S| = |V|`.
{Informal.citep "zheng2026" (kind := "section") (index := "3.2")}[]
:::

```tex "support_multiplicity"
\begin{definition}
For $x \in V$, let
\[
  h_x = |\{\gamma \in \Gamma : x \in T_\gamma\}|,
\]
be the support multiplicity of $x$, and set
\[
  O = \{x \in V : h_x = 0\}, \qquad
  P = \{x \in V : h_x = 1\}, \qquad
  S = \{x \in V : h_x \ge 2\}.
\]
\end{definition}
```

A vertex in $`P` is called a _private support vertex_; the vertices in $`O`
are _outside_ every flag, and those in $`S` are _shared_. The formalization
defines the multiplicity and the three sets as {name Finset}`Finset`s of the
live vertex type, and the cardinality identity of the node is
{name RB31E2E.ProvenanceFlag.State.card_live_partition}`card_live_partition`.

```BodyPinBlueprint.bodies
RB31E2E.ProvenanceFlag.State.activeFlagsAt
RB31E2E.ProvenanceFlag.State.flagMultiplicity
RB31E2E.ProvenanceFlag.State.outsideVertices
RB31E2E.ProvenanceFlag.State.privateVertices
RB31E2E.ProvenanceFlag.State.sharedVertices
```

:::lemma_ "flag_selection" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.exists_outside_degree_le_three_or_private_degree_le_two") (tags := "paper") (uses := "support_multiplicity")
If $`V \ne \emptyset`, then some vertex $`x \in O` has $`\deg_G(x) \le 3`, or
some vertex $`x \in P` has $`\deg_G(x) \le 2`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.4")}[]
:::

```tex "flag_selection"
\begin{lemma}[Flag selection lemma]
If $V \neq \emptyset$, then there is a vertex of one of the following
two types:
\begin{equation}
  x \in O, \deg_G(x) \le 3, \qquad \text{or} \qquad
  x \in P, \deg_G(x) \le 2.
  \tag{3.6}
\end{equation}
\end{lemma}
```

:::proof "flag_selection" (uses := "flag_incidence_forest")
Set $`n = |V|`, $`m = |E|` and $`k = |\Gamma|`. Distinct flags share at most
one support vertex, so their missing edges are distinct, absent from the base
graph, and disjoint from every auxiliary star; the completion therefore has
exactly $`m + 4k` edges on $`n + k` vertices, and sparsity gives
$`m \le 2n - 2k - 2`. Each incidence $`x \in T_\gamma` gives an edge of the
induced path $`G[T_\gamma]` at $`x`, and edges selected from distinct flags
differ, so $`\deg_G(x) \ge h_x`.

Suppose neither type of vertex exists. Then every vertex of $`O` has degree
at least four and every vertex of $`P` at least three, so the degree sum
gives $`2m \ge 4|O| + 2|P| + 3k`, using $`\sum_{x \in S} h_x = 3k - |P|`.
Combining this with the edge bound gives $`7k + 4 \le 2|P| + 4|S|`, while
$`h_x \ge 2` on $`S` gives
$`2|P| + 4|S| \le 2(|P| + \sum_{x \in S} h_x) = 6k`, a contradiction.
:::

The formal proof runs the same three ledgers, each proved as an identity of
the literal state: the completion has $`|E| + 4|\Gamma|` edges
({name RB31E2E.ProvenanceFlag.State.card_completionEdges}`card_completionEdges`),
the terminal incidences sum to $`3|\Gamma|`, the live degrees sum to
$`2|E|`, and each incidence at a vertex gives a distinct live edge
({name RB31E2E.ProvenanceFlag.State.flagMultiplicity_le_liveDegree}`flagMultiplicity_le_liveDegree`).
The closing arithmetic is kept in a separate module of natural-number
inequalities, so no truncated subtraction hides inside graph notation. The
selection conclusion is a theorem about every sparse state, not a field of
the structure.

# Private support vertices and missing-edge pivots

Suppose the selected vertex $`v` is a private support vertex, with unique
triple $`T_\gamma = \{v, p, q\}`. The three possible rigidity rows on three
distinct collinear points span the same two-dimensional space —
{bpref "certified_response_edge"}[the observation of Example 2.2] — so the
distinguished missing edge can be moved to an edge incident with $`v`
without changing the completion or the row space. The vertex $`v` and the
flag $`\gamma` are then deleted together, and the retained field $`L`,
configuration $`a_H`, and local numbers $`u`, $`\delta_v` of
{bpref "retained_coordinate_field"}[the deletion chapter] apply verbatim.
Flag collinearity places $`a_v` on the line through $`a_p` and $`a_q`, which
is defined over $`L`, so $`\delta_v \le 1` at a private support vertex.

:::lemma_ "missing_edge_pivot" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.pivotPrivateOpposite, RB31E2E.ProvenanceFlag.State.exists_privatePivotData, RB31E2E.DirectionStress.directionStressDim_exchange_collinear_triangle") (tags := "paper") (uses := "flag_system, rigidity_row")
After possibly interchanging $`p` and $`q`, and if necessary exchanging one
base-graph edge with the distinguished missing edge, we may arrange that
$`d_\gamma = vq` while $`vp, pq \in E(G)`. The exchange leaves the
simultaneous completion, the row space $`\operatorname{row} D_G(a)`, and the
self-stress dimension unchanged, and does not increase $`\deg_G(v)`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.5")}[]
:::

```tex "missing_edge_pivot"
\begin{lemma}[Completion-preserving pivot]
After possibly interchanging the labels $p, q$, and, if necessary, exchanging
one base-graph edge with the distinguished missing edge, we may arrange that
\begin{equation}
  d_\gamma = vq, \qquad vp, pq \in E(G).
  \tag{3.8}
\end{equation}
More precisely, if the original distinguished missing edge is $pq$, set
\[
  E(G^\sharp) = \bigl( E(G) \setminus \{vq\} \bigr) \cup \{pq\}, \qquad
  d^\sharp_\gamma = vq,
\]
and leave all other flag data unchanged.  Let $\widehat{G}^\sharp$ be the
simultaneous completion of the modified flag system.  Then
\[
  \widehat{G}^\sharp = \widehat{G}, \qquad
  \deg_{G^\sharp}(v) \le \deg_G(v), \qquad
  \operatorname{row} D_{G^\sharp}(a) = \operatorname{row} D_G(a),
\]
and the two self-stress spaces have the same dimension.
\end{lemma}
```

The pivot has a combinatorial and a linear half, and the formalization keeps
them in separate modules. The combinatorial half is the state constructor
{name RB31E2E.ProvenanceFlag.State.pivotPrivateOpposite}`pivotPrivateOpposite`,
which applies when the old missing edge $`pq` is opposite $`v`: it inserts
$`pq` into the live edges, erases $`vq`, and redeclares the missing edge of
the flag to be $`vq`. The live edge set and the restored-missing packet
swap one edge each, so the completion is literally unchanged
({name RB31E2E.ProvenanceFlag.State.pivotPrivateOpposite_completionEdges}`pivotPrivateOpposite_completionEdges`),
and sparsity with it.

```BodyPinBlueprint.bodies
RB31E2E.ProvenanceFlag.State.pivotPrivateOpposite
```

The linear half is
{name RB31E2E.DirectionStress.directionStressDim_exchange_collinear_triangle}`directionStressDim_exchange_collinear_triangle`:
on three distinct collinear placed points, each triangle direction row lies
in the span of the other two, so exchanging one live terminal edge for the
missing one preserves the row space, and rank–nullity turns the unchanged
rank and edge count into an unchanged stress dimension.
{name RB31E2E.ProvenanceFlag.State.exists_privatePivotData}`exists_privatePivotData`
states both halves at once: every private terminal admits an orientation
with $`d_\gamma` incident to $`v`, obtained either by renaming $`p` and $`q`
or by the pivot above, together with the facts about the pivoted state that
are used in the private case of the induction.

:::lemma_ "private_local_classification" (parent := "flags_spine") (lean := "RB31E2E.DirectionStress.private_nonexceptional_or_exceptional, RB31E2E.DirectionStress.privateExceptional_classification, RB31E2E.DirectionStress.privateExceptional_bothVirtualRows_mem") (tags := "paper") (uses := "missing_edge_pivot, deletion_ledger")
In the pivoted shape, if $`\deg_G(v) \le 2`, then either the local increment
satisfies $`u + \delta_v \le 1`, or
$`\delta_v = 1`, $`u = 1`, $`\deg_G(v) = 2`,
$`\operatorname{rank} C_v = 1`, $`\dim_K \ker C_v = 1` and
$`\ker \partial_v = \ker C_v`; in the second case the base-graph edge $`vz`
other than $`vp` has $`p, q, z` pairwise distinct with collinear
configuration points, and
$`r_{pz}(a_H), r_{qz}(a_H) \in \operatorname{row}_L D_H(a_H)`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.6")}[]
:::

```tex "private_local_classification"
\begin{lemma}[Local classification at a private support vertex]
If $\deg_G(v) \le 2$, then one of the following holds:
\begin{enumerate}
\item[(i)] The local increment satisfies
  \begin{equation}
    u + \delta_v \le 1;
    \tag{3.9}
  \end{equation}
\item[(ii)]
  \begin{equation}
    \delta_v = 1, \quad u = 1, \quad \deg_G(v) = 2, \quad
    \operatorname{rank} C_v = 1, \quad \dim_K \ker C_v = 1, \quad
    \ker \partial_v = \ker C_v.
    \tag{3.10}
  \end{equation}
  If the second base-graph edge at $v$ is denoted by $vz$, then $p, q, z$ are
  pairwise distinct, their configuration points are collinear, and
  \[
    r_{pz}(a_H), r_{qz}(a_H) \in \operatorname{row}_L D_H(a_H).
  \]
\end{enumerate}
\end{lemma}
```

This is the one-flag analogue of {bpref "low_degree_classification"}[the
low-degree classification]: deleting a private support vertex also deletes
its flag, so the right-hand side of the budget falls by three while the flag
term falls by two, and the local allowance is $`u + \delta_v \le 1` in place
of $`u + \delta_v \le 3`. The
formalization states the allowance as the predicate
{name RB31E2E.DirectionStress.PrivateNonexceptional}`PrivateNonexceptional`
and the exceptional case as its literal negation, exactly as the deletion
chapter does for the outside case; the disjunction
{name RB31E2E.DirectionStress.private_nonexceptional_or_exceptional}`private_nonexceptional_or_exceptional`
is then immediate, and the two branches of the induction exhaust all
possibilities by construction.

```BodyPinBlueprint.bodies
RB31E2E.DirectionStress.PrivateNonexceptional
RB31E2E.DirectionStress.PrivateExceptional
```

{name RB31E2E.DirectionStress.privateExceptional_classification}`privateExceptional_classification`
proves that a failure of the allowance has one shape only. Its hypotheses
are the pivoted flag data: $`vp` live, $`vq` missing, degree at most two,
and $`a_v, a_p, a_q` collinear. Its conclusion gives the unique second
neighbour $`z`, the values in (3.10), collinearity of $`a_v, a_p, a_z`, and
the vanishing of
{name RB31E2E.DirectionStress.deletedConnectingClass}`deletedConnectingClass`,
which is the statement $`\ker \partial_v = \ker C_v` in the form the
formalization uses. The two rows of the conclusion are
{name RB31E2E.DirectionStress.privateExceptional_bothVirtualRows_mem}`privateExceptional_bothVirtualRows_mem`:
the paper's identities (3.11) and (3.12), the two-star relation on the
collinear triple followed by cancellation over $`K` and descent to $`L`, are
carried out on the actual local equilibrium map, and collinearity of
$`a_p, a_q, a_z` descends to $`L` because matrix rank is unchanged under
field extension. Both rows are rows of virtual response edges in the sense of
{bpref "certified_response_edge"}[the deletion chapter], and the private
augmentation lemma below shows one of them can actually be added.

# Two augmentation lemmas for the completion

Both exceptional cases end with the insertion of an edge whose row is
already in the retained row space, and the insertion must preserve
completion sparsity. The two lemmas of this section give that edge, one for
the outside case and one for the private case. Their proofs are tight-set
arguments in the
completion — {bpref "addable_edge_triple"}[the addable-edge lemma] and
{bpref "uncrossing"}[uncrossing] applied to $`\widehat{G}` — and, like those
of the sparsity chapter, they do not use the construction theorem that the
formalization also contains.

:::lemma_ "outside_augmentation" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.outside_live_neighbour_triangle_complete_or_addable, RB31E2E.ProvenanceFlag.State.outside_complete_triangle_live") (tags := "paper") (uses := "flag_system")
Let $`v \in O` have degree three with neighbour set $`N`, and set
$`Q = \widehat{G} - v`. If $`Q[N]` is not complete, some
$`f \in \binom{N}{2} \setminus E(Q)` can be added to $`Q` while preserving
$`(2,2)`-sparsity. If $`Q[N]` is a triangle, then no two vertices of $`N`
belong to the support triple of a common flag, and all three triangle edges
belong to $`G - v`.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.7")}[]
:::

```tex "outside_augmentation"
\begin{lemma}[An addable edge or a complete triangle at a degree-three vertex
outside the flags]
Let $v \in O$, let $\deg_G(v) = 3$, let $N$ be its neighbor set, and set
$Q = \widehat{G} - v$.  If $Q[N]$ is not complete, then there is an
$f \in \binom{N}{2} \setminus E(Q)$ such that $Q + f$ is still
$(2,2)$-sparse.  If $Q[N]$ is a triangle, then:
\begin{enumerate}
\item[(i)] no two vertices of $N$ belong to the support triple of the same
  flag in the original system;
\item[(ii)] all three edges of the triangle belong to $G - v$.
\end{enumerate}
\end{lemma}
```

:::proof "outside_augmentation" (uses := "addable_edge_triple, flag_incidence_forest")
If $`Q[N]` is not complete, then $`Q + vN = \widehat{G}` is sparse and the
addable-edge lemma applies to $`Q`. Suppose $`Q[N]` is complete and
$`x, y \in N` both lie in the support triple $`T_\delta` of an existing
flag. The tight set $`T_\delta \cup \{g_\delta\}` has four vertices and six
edges; since $`v` is outside every flag, the edges $`vx` and $`vy` give at
least eight edges on $`T_\delta \cup \{g_\delta, v\}`. If the third
neighbour $`z` lies in $`T_\delta`, the edge $`vz` is a ninth edge on five
vertices, violating sparsity; otherwise the five-vertex bound forces the set
to be tight, and adjoining $`z` with its three edges $`zv, zx, zy` violates
sparsity again. This proves (i), and (ii) follows: a triangle edge that was
the restored missing edge of a flag would have both its endpoints in that
flag's support triple, contradicting (i).
:::

The formalization proves the alternative in the completed graph. An outside
vertex meets no restored edge and no ghost star, so its incidence packet in
$`\widehat{G}` is exactly the lift of its live packet, its completed degree
is its live degree, and
{name RB31E2E.degree_three_neighbour_triangle_complete_or_addable}`degree_three_neighbour_triangle_complete_or_addable` —
the dichotomy form of {bpref "addable_edge_triple"}[Lemma 2.1] — applies to
$`\widehat{G}` directly. Part (ii) is
{name RB31E2E.ProvenanceFlag.State.outside_complete_triangle_live}`outside_complete_triangle_live`,
proved by the tight-$`K_4` argument of the paper, and
{name RB31E2E.ProvenanceFlag.State.outside_complete_or_exists_sparse_insertedChild}`outside_complete_or_exists_sparse_insertedChild`
states the addable alternative on the smaller flag state directly: the
outside vertex deleted, the edge inserted, and the child completion sparse.

:::lemma_ "private_augmentation" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.State.private_response_edge_addable") (tags := "paper") (uses := "private_local_classification, missing_edge_pivot")
Suppose $`v \in P` satisfies (3.10), its unique flag is $`\gamma` with
$`T_\gamma = \{v, p, q\}` in the pivoted shape, and $`vz` is the base-graph
edge at $`v` other than $`vp`. Set $`Q = \widehat{G} - \{v, g_\gamma\}`.
Then at least one of the edges $`pz`, $`qz` is absent from $`E(Q)` and can
be added to $`Q` while preserving $`(2,2)`-sparsity.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.8")}[]
:::

```tex "private_augmentation"
\begin{lemma}[A certified response edge in the private-support exceptional
case]
Suppose that $v \in P$ satisfies (3.10), that its unique flag has index
$\gamma$, and that $T_\gamma = \{v, p, q\}$.  Use the normalization (3.8).
Let $vz$ denote the base-graph edge at $v$ other than $vp$, and set
\begin{equation}
  Q = \widehat{G} - \{v, g_\gamma\}.
  \tag{3.13}
\end{equation}
Then the vertex set of $Q$ is $V(\widehat{G}) \setminus \{v, g_\gamma\}$, and
at least one of the edges $pz, qz$ is absent from $E(Q)$ and can be added to
$Q$ while preserving $(2,2)$-sparsity.
\end{lemma}
```

:::proof "private_augmentation" (uses := "uncrossing, flag_incidence_forest")
The graph $`Q` contains $`pq`. If both $`pz` and $`qz` belonged to $`E(Q)`,
the original $`K_4` on $`T_\gamma \cup \{g_\gamma\}` together with
$`vz, pz, qz` would put nine edges on five vertices. So suppose one candidate
is missing and cannot be added, say $`qz`; a tight set $`B` containing $`q`
and $`z` blocks it, and if $`p \notin B` the edges $`pq` and $`pz` force
$`B \cup \{p\}` to be tight, so some tight set contains $`p, q, z`. If both
candidates are missing and neither can be added, the two blocking tight sets
meet at $`z` and uncrossing gives a tight set containing $`p, q, z` again.
Restoring $`v` and $`g_\gamma` adds at least the six edges
$`vp, vq, vz, g_\gamma v, g_\gamma p, g_\gamma q` to that set, while two new
vertices permit only four, a contradiction.
:::

The formal statement,
{name RB31E2E.ProvenanceFlag.State.private_response_edge_addable}`private_response_edge_addable`,
is proved on the literal completion with both the private terminal and its
consumed ghost deleted, so the graph it augments is exactly the simultaneous
completion of the child system on which the induction continues. The
blocking argument uses
{name RB31E2E.ProvenanceFlag.State.flagVertices_tight}`flagVertices_tight` —
the completed $`K_4` of the old flag is tight — together with
{bpref "uncrossing"}[uncrossing] and the fact that a tight set with at least
two vertices has at least four. The construction theorem is not used, which
confirms at the level of proofs what
{bpref "lean_nixon_owen_reduction"}[the sparsity chapter] claimed from
reachability alone.

# Function-field branches and the semismallness budget

The paper states Theorem 3.9 for a configuration over a finitely generated
extension $`K/k` and reads it, equivalently, as a codimension bound on
subvarieties of $`X^\circ_{\mathcal{T}}`. The formalization keeps only the
first reading. Its object is a _function-field branch_: a placement
$`\mathrm{pos} : V \to K^3` of the live vertices, together with proofs that
the coordinates generate $`K` over $`k`, that the placement is injective,
and that every terminal triple is collinear. The branch dimension is the
transcendence degree $`\trdeg_k K`, and no codimension, stress bound, or
height conclusion is a field of the structure.

```BodyPinBlueprint.bodies
RB31E2E.ProvenanceFlag.GeneratedByLiveCoordinates
RB31E2E.ProvenanceFlag.AffinelyCollinearOn
RB31E2E.ProvenanceFlag.FlagCollinearities
RB31E2E.ProvenanceFlag.FunctionFieldBranch.stressDim
RB31E2E.ProvenanceFlag.FunctionFieldBranch.SemismallBudget
```

The last definition is the inequality the whole induction proves. As noted
in {bpref "deletion_ledger"}[the deletion chapter], the paper's defect
$`\Delta(G, \Gamma, a) = s + \trdeg_k K + 2|\Gamma| - 3|V|` has no Lean
counterpart as a quantity; the statement $`\Delta \le 0` appears instead as
this predicate, in the subtraction-free form

$$`
s + \trdeg_k K + 2|\Gamma| \le 3|V|,
`

where $`s` is
{name RB31E2E.ProvenanceFlag.FunctionFieldBranch.stressDim}`stressDim`, the
self-stress dimension of the live graph at the branch's placement. The
paper's bookkeeping identities (3.16) and (3.18) below likewise have no
counterparts as equations: each induction step proves the parent's budget
from the child's budget and a local payment, and the arithmetic of the
defect is carried out inside those proofs.

:::theorem "stress_codim_flags" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlag.provenanceFlag_semismallness, RB31E2E.ProvenanceFlag.FunctionFieldBranch.SemismallBudget") (tags := "paper") (uses := "flag_system, rigidity_row")
Let $`(G = (V, E), \Gamma)` be a sparse collinearity-flag system, let $`K/k`
be a finitely generated field extension, and let $`a : V \to K^3` be an
injective configuration that realizes all the flags and whose coordinates
generate $`K`; then

$$`
\dim_K \ker D_G(a)^T + \trdeg_k K + 2|\Gamma| \le 3|V|.
`
{Informal.citep "zheng2026" (kind := "theorem") (index := "3.9")}[]
:::

```tex "stress_codim_flags"
\begin{theorem}[Stress–codimension inequality for collinearity flags]
Let $(G = (V, E), \Gamma)$ be a sparse collinearity-flag system in the sense
of Definition 3.2.  Let $K/k$ be a finitely generated field extension, and
let $a : V \to K^3$ be an injective configuration that realizes all the flags
and whose coordinates generate $K$.  Then
\begin{equation}
  \dim_K \ker D_G(a)^T + \operatorname{trdeg}_k K + 2|\Gamma| \le 3|V|.
  \tag{3.14}
\end{equation}
Equivalently, if $Y \subseteq X^\circ_{\mathcal{T}}$ is an irreducible
locally closed subvariety and $a_Y : V \to k(Y)^3$ denotes its generic-point
configuration, then
\[
  \dim_{k(Y)} \ker D_G(a_Y)^T \le \operatorname{codim}_{X^\circ_{\mathcal{T}}} Y.
\]
\end{theorem}
```

:::proof "stress_codim_flags" (uses := "flag_selection, low_degree_classification, neighbour_rigidity_rows, missing_edge_pivot, private_local_classification, outside_augmentation, private_augmentation, certified_response_edge, deletion_ledger")
Write $`n = |V|`, $`j = |\Gamma|`, $`s = \dim_K \ker D_G(a)^T` and
$`\Delta(G, \Gamma, a) = s + \trdeg_k K + 2j - 3n`; the assertion is
$`\Delta \le 0`, proved by strong induction on $`n`. If $`n = 0` then
$`E = \Gamma = \emptyset` and $`K = k`, so $`\Delta = 0`. Otherwise the
selection lemma gives a vertex $`v` of one of its two types.

_An outside vertex of degree at most three._ Delete $`v` and keep every
flag; the child completion embeds in $`\widehat{G} - v`, so the child system
is sparse, and the ledger gives
$`\Delta(G, \Gamma, a) = \Delta(H, \Gamma, a_H) + (u + \delta_v - 3)`. If
$`u + \delta_v \le 3` the induction hypothesis applies to $`H = G - v`.
Otherwise the low-degree classification gives $`\delta_v = 3`, $`u = 1` and
three distinct collinear neighbours $`N` whose pairwise rigidity rows lie in
$`\operatorname{row}_L D_H(a_H)`. If $`\widehat{G} - v` is not complete on
$`N`, the outside augmentation lemma gives an addable nonedge $`f`; it is a
certified response edge, so adding it raises the self-stress dimension of
$`H` from $`t` to $`t + 1 = s`, since the ledger gives $`s = t + u` with
$`u = 1`. Every retained flag remains valid, and
$`\Delta(H + f, \Gamma, a_H) = \Delta(G, \Gamma, a)` with one live vertex
fewer. If instead the neighbour triangle is complete, its three edges are
live and no two of its vertices share a flag; delete one triangle edge
$`d_N` and register $`(T_\star, d_\star) = (N, d_N)` with a new ghost as a
new flag. Mapping the new ghost to $`v` embeds the new completion into
$`\widehat{G}`, so the enlarged system is sparse. Removing one collinear
triangle row preserves the rank, so the stress dimension becomes $`s - 2`,
while $`j` increases by one and $`n` decreases by one; hence $`\Delta` is
unchanged and the induction hypothesis applies again.

_A private support vertex of degree at most two._ Pivot so that
$`d_\gamma = vq` with $`vp, pq` live; the pivot changes neither the
completion nor the stress dimension. Delete $`v` and the flag $`\gamma`
together; the child completion embeds in $`\widehat{G}`, and the ledger now
reads
$`\Delta(G, \Gamma, a) = \Delta(H, \Gamma \setminus \{\gamma\}, a_H) +
(u + \delta_v - 1)`. If $`u + \delta_v \le 1` the induction hypothesis
applies. Otherwise the private classification forces $`\delta_v = u = 1`,
degree exactly two, and the two candidate rows $`r_{pz}, r_{qz}` in the
retained row space; by the private augmentation lemma one of the two
candidates is an addable edge $`f` of the child completion, its insertion is
a certified response edge, the stress dimension is restored to $`s`, and
$`\Delta(H + f, \Gamma \setminus \{\gamma\}, a_H) = \Delta(G, \Gamma, a)`
with one live vertex fewer.
:::

The formal theorem is
{name RB31E2E.ProvenanceFlag.provenanceFlag_semismallness}`provenanceFlag_semismallness`:
for every state whose completion is sparse and every function-field branch
on it, the semismallness budget holds. The strong induction is on the size
{name Fintype.card}`Fintype.card` of the live vertex type, which strictly
decreases at every recursive call because each move constructs its child on
the subtype of remaining vertices. The base case is
the empty live type, where the state's own fields force $`\Gamma` to be
empty and coordinate generation forces $`\trdeg_k K = 0`. Each of the four
cases of the induction is proved in its own module: the two nonexceptional
deletions rest on the local payments proved in the deletion ledger; in the
outside exceptional case an edge is inserted or the neighbour triple is
registered, with the stress and flag terms changing by exactly two each in
the registered alternative; and in the private exceptional case the branch
is transported across the pivot before the deletion. We describe those
transitions one by one in the closing section.

One hypothesis differs in form. The paper redefines the retained data after
each move and reuses the ambient field $`K`; the formalization measures each
child by the intermediate field generated by the child's own coordinates
inside $`K`, proves that direction-stress rank is unchanged under that
restriction of scalars, and descends collinearity of the retained triples to
the child field. The equivalence between the two measurements is the
intrinsic-placement interface of the deletion ledger, and it is why the
induction can pass to a subtype without rebuilding the function field at
every step.

:::theorem "stress_codim" (parent := "flags_spine") (lean := "RB31E2E.ProvenanceFlagGroundedPF.groundedPF_of_provenanceFlag_semismallness, RB31E2E.endToEndBodyPinStatement_of_groundedPF") (tags := "paper, deviation") (uses := "stress_codim_flags")
Let $`F` be a finite simple $`(2,2)`-sparse graph on the vertex set $`V`,
let $`K/k` be a finitely generated field extension, and let
$`a : V \to K^3` be injective with coordinates generating $`K`; then

$$`
\dim_K \ker D_F(a)^T + \trdeg_k K \le 3|V|.
`
{Informal.citep "zheng2026" (kind := "theorem") (index := "1.2")}[]
:::

```tex "stress_codim"
\begin{theorem}[Stress–codimension inequality]
Let $F$ be a finite simple $(2,2)$-sparse graph, and let $K/k$ be a finitely
generated field extension.  Suppose that $a : V \to K^3$ is injective and
that $K$ is generated by all coordinates $a_{v,i}$.  Then
\begin{equation}
  \dim_K \ker D_F(a)^T + \operatorname{trdeg}_k K \le 3|V|.
  \tag{1.5}
\end{equation}
Equivalently, if $Y$ is an irreducible locally closed subvariety of the open
locus of distinct configurations and $a_Y : V \to k(Y)^3$ is its
generic-point configuration, then
\[
  \dim_{k(Y)} \ker D_F(a_Y)^T \le \operatorname{codim}_{(\mathbb{A}^3_k)^V} Y.
\]
\end{theorem}
```

The paper proves this by applying Theorem 3.9 with $`G = F` and
$`\Gamma = \emptyset`, so that $`\widehat{G} = F` and (3.14) is (1.5). The
formalization makes the same specialization:
{name RB31E2E.ProvenanceFlagGroundedPF.emptyFlagState}`emptyFlagState` puts
the empty flag type on $`F`, and its completion is $`F` itself. It never
states (1.5) as a standalone theorem, however. The assembly of
{bpref "formal_statement"}[the main theorem] uses a _grounded_ form instead:
the placement sends a root vertex to zero, the base field is $`\mathbb{Q}`,
and the right-hand side is $`3(|V| - 1)`, the number of spatial variables
left after grounding.
{name RB31E2E.ProvenanceFlagGroundedPF.groundedPF_of_provenanceFlag_semismallness}`groundedPF_of_provenanceFlag_semismallness`
derives that form from flag semismallness. It adjoins three independent
translation variables to $`K` and translates the placement by them;
{name RB31E2E.ProvenanceFlagGroundedPF.translatedPlacement}`translatedPlacement`
leaves every direction row, hence the stress space, unchanged, while the
transcendence degree grows by exactly three. Applying the empty-flag budget
over the enlarged field and cancelling those three dimensions against the
grounding gives the grounded inequality, which then enters
{name RB31E2E.endToEndBodyPinStatement_of_groundedPF}`endToEndBodyPinStatement_of_groundedPF`
as its sole hypothesis, and
{name RB31E2E.ProvenanceFlagGroundedPF.endToEndBodyPinStatement_of_provenanceFlag_semismallness}`endToEndBodyPinStatement_of_provenanceFlag_semismallness`
is the composite, from the flag theorem to the body–pin statement. The
grounded model itself is the subject of
{bpref "grounded_model"}[the strata chapter].

# Flag moves and the budget ledger

:::lemma_ "lean_flag_moves" (parent := "flags_infrastructure") (tags := "lean-only") (lean := "RB31E2E.ProvenanceFlag.State.deleteOutside_completionSparse, RB31E2E.ProvenanceFlag.State.registerOutside_completionSparse, RB31E2E.ProvenanceFlag.FunctionFieldBranch.semismallBudget_of_deleteOutsideIntrinsic") (uses := "flag_system, lean_sparsity_transport") (uses_intent := "technical")
Each move of the induction — deleting an outside vertex, deleting a private
vertex with its flag, inserting a virtual response edge, registering a new
flag, pivoting a missing edge — is a constructor producing a literal child
state on the exact remaining types, with completion sparsity proved by
transporting the child completion into the parent's, and with a budget-lift
theorem deriving the parent's budget from the child's. The paper
performs the corresponding changes of flag system inside the proof of
Theorem 3.9 and needs no such statements.
:::

The paper's induction modifies one graph in place; the formalization, whose
state is defined on exact types, rebuilds the state at every move. The
child states are built by four constructors:
{name RB31E2E.ProvenanceFlag.State.deleteOutside}`deleteOutside` restricts
every field to the subtype of remaining vertices,
{name RB31E2E.ProvenanceFlag.State.deletePrivate}`deletePrivate` restricts
the flag type as well,
{name RB31E2E.ProvenanceFlag.State.insertLiveEdge}`insertLiveEdge` adds one
certified edge, and
{name RB31E2E.ProvenanceFlag.State.registerOutside}`registerOutside` erases
one triangle edge and adjoins one flag, with the deleted apex replaced by
the new ghost. For each, an edge-for-edge embedding of the child completion
into the parent's gives sparsity by
{bpref "lean_sparsity_transport"}[transport], and the two deletions strictly
decrease the live vertex count, so the strong induction on that count
terminates.

On the numerical side, the deletion-ledger module identifies each child's
stress dimension with that of the parent's deleted graph and proves the two
local budget lifts used in the nonexceptional cases: an outside deletion
removes three ambient dimensions, so a payment of $`u + \delta_v \le 3`
suffices
({name RB31E2E.ProvenanceFlag.FunctionFieldBranch.semismallBudget_of_deleteOutsideIntrinsic}`semismallBudget_of_deleteOutsideIntrinsic`),
while a private deletion removes three ambient dimensions but also one flag
term of two, so the allowance is exactly one
({name RB31E2E.ProvenanceFlag.FunctionFieldBranch.semismallBudget_of_deletePrivateIntrinsic}`semismallBudget_of_deletePrivateIntrinsic`).
The two exceptional cases are proved by
{name RB31E2E.ProvenanceFlag.FunctionFieldBranch.semismallBudget_of_outsideExceptional}`semismallBudget_of_outsideExceptional` —
in its registered alternative one collinear triangle row is erased and one
flag is added, so the stress and flag terms change by exactly two each — and
{name RB31E2E.ProvenanceFlag.FunctionFieldBranch.semismallBudget_of_privateExceptional}`semismallBudget_of_privateExceptional`,
whose proof first transports the branch across the pivot. The transcendence
accounting in all four rests on the tower equality of
{bpref "lean_base_change"}[the base-change infrastructure], and the closing
natural-number arithmetic is collected in one module so that no truncated
subtraction hides inside graph notation.
