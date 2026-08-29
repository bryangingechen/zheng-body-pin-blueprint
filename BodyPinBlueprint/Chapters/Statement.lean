import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Bodies
import RB31EndToEnd

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Statement of the theorem

Paper §1 and Appendix A.1.  The two are merged here because they state the same
theorem twice — once informally, once in the form that was formalized — and the
whole point of this chapter is to put those two statements side by side.

Node bodies hold the statement and nothing else.  Everything about how Lean
renders a definition, why a convention was chosen, or what a step costs is
chapter prose sitting after the node, because a node body is what the graph and
the hover previews show: a reader following an edge wants the statement, not an
essay.  A node keeps exactly one located citation, at the end of the statement.

On the `tex` witnesses: the paper has no LaTeX source (see `AGENTS.md`, "No TeX
source"), so every witness in this repository is hand-transcribed from
`source/paper.txt`.  The text inside a witness is the paper's; the environment
around it is a reconstruction.  Where the paper really has a numbered
environment — Theorem 1.1, Theorem A.1 — the witness uses that exact kind.
Where the paper defines something in running prose, the witness wraps the
paper's sentences in `definition`.  Nodes with no paper counterpart at all
(`gap`, `lean-only`) carry no witness, because there is nothing to quote.  A
witness must stay immediately adjacent to its node; commentary goes after it.

Because §1 and A.1 are merged, most witnesses here join a §1 sentence to its
A.1 counterpart.  `scripts/check-witness-prose.py` reports one unmatched word
window at each such join; in this chapter they are all that merge.

Quoted Lean bodies are named rather than copied.  A `BodyPinBlueprint.bodies`
fence lists fully qualified declaration names and `Bodies.lean`
reads each body out of the pinned submodule's extract, so nothing is
re-elaborated and there is no scaffolding to hide.  Where a node names the
declaration, `quotedBodyJs` splices the value onto that declaration's panel and
the block leaves the prose; where no node names it, the block stays where it is.
Proof obligations render as `⋯` and nothing else is omitted.

Every `def` and `abbrev` a node here names is quoted.  That is the rule in
the `AGENTS.md` beside this directory, and `scripts/coverage.py` fails the build
on a node that names one with neither a fence nor an opt-out.
-/

#doc (Manual) "Statement of the theorem" =>

This chapter states what is claimed and what was proved. Everything in it comes
from §1 and Appendix A.1 of {Informal.citet "zheng2026"}[]; the argument starts
in {bpref "sparse22"}[the sparsity chapter].

Two statements are involved, and they are not the same statement. Theorem 1.1
is about generic rigidity in the usual sense. Theorem A.1 is about a
realization attaining the same rigidity-matrix rank as the complete graph, and
that is the statement the formalization proves. The two are related by the
Asimow–Roth theorem, which the paper cites and the formalization does not
contain.

:::group "statement_data"
The combinatorial data of a body–pin framework, the rigidity operator, and the
two sides of the equivalence.
:::

:::group "statement_theorem"
The theorem itself, in both of the paper's formulations, together with the one
literature citation standing between them.
:::

# The body-pin model

:::definition "bodypin_incidence" (parent := "statement_data") (lean := "RB31E2E.BodyPinIncidence") (tags := "paper")
A body–pin multigraph is a finite loopless multigraph $`H = (W, E)`: the
vertices are rigid bodies and the edges are pins, with parallel pins allowed as
distinct elements of $`E`.
{Informal.citep "zheng2026" (kind := "section") (index := "1 and A.1")}[]
:::

```tex "bodypin_incidence"
\begin{definition}
Let $H = (W, E)$ be a finite loopless multigraph.

Write a finite loopless multigraph as
\[
  H = (W, E; \partial_0, \partial_1), \qquad
  \partial_0, \partial_1 : E \longrightarrow W, \qquad
  \partial_0(e) \neq \partial_1(e).
\]
Here $E$ is the edge set; parallel edges are distinct elements of $E$.
\end{definition}
```

Quoted Lean here and in the rest of the blueprint is the pinned formalization's
own source, extracted at build time rather than copied. To check one against the
repository it came from, follow the source link on the declaration's panel: it
is anchored to the line range of the declaration at the pinned commit.

The formalization represents $`H` as a type of pins together with two endpoint
maps and a proof that the two endpoints of a pin differ, which is the
appendix's presentation $`H = (W, E; \partial_0, \partial_1)` rather than the
main text's. Two pins joining the same pair of bodies are then distinct
elements of the pin type, so each can be referred to individually.

:::definition "bodypin_expansion" (parent := "statement_data") (lean := "RB31E2E.BodyPinIncidence.bodyPinGraph, RB31E2E.BodyPinIncidence.bodyClique, RB31E2E.BodyPinIncidence.canonicalBodyPinGraph") (tags := "paper") (uses := "bodypin_incidence")
Each body $`w` is expanded into a complete graph on its pins together with at
least four private vertices, and each pin becomes a single vertex shared by the
two bodies it joins. The union of these cliques is the body–pin graph $`G_H`.
{Informal.citep "zheng2026" (kind := "section") (index := "1 and A.1")}[]
:::

```tex "bodypin_expansion"
\begin{definition}
For each $w \in W$, take a complete graph $B_w$ on at least $d_H(w) + 4$
vertices.  For every $e = xy \in E$, choose one previously unused vertex from
each of $B_x$ and $B_y$ and identify the two chosen vertices to form the pin
vertex $p_e$.  Distinct edges use distinct pin vertices.  The resulting simple
graph $G_H$ is called the body--pin graph of $H$
\cite[Section 7.2]{jacksonJordanVillanyi2026}.

For $n \in \mathbb{N}$, write $[n] = \{0, \dots, n-1\}$.  Given $r : W \to
\mathbb{N}$, let
\begin{equation}
  V(H, r) = E \sqcup \Bigl( \bigsqcup_{w \in W} \{w\} \times [4 + r(w)] \Bigr).
  \tag{A.1}
\end{equation}
For each $w \in W$, set
\[
  B_w = \{ e \in E : \partial_0(e) = w \text{ or } \partial_1(e) = w \}
    \sqcup \bigl( \{w\} \times [4 + r(w)] \bigr).
\]
Define $G(H, r)$ to be the simple graph on $V(H, r)$ obtained as the union of
the complete graphs $K_{B_w}$ for $w \in W$.  Thus two distinct vertices are
adjacent if and only if they belong to a common body.  The body $w$ contains
$d_H(w)$ pin vertices and $4 + r(w)$ private vertices.
\end{definition}
```

The paper cites
{Informal.citet "jacksonJordanVillanyi2026" (kind := "section") (index := "7.2")}[]
at this point, and the definition given there agrees with this one, including
the $`d_H(w) + 4` bound.

The appendix parametrizes the construction by a function $`r : W \to \N`
counting private vertices _beyond_ the mandatory four, which is what makes
$`G(H, r)` a function of $`H` and $`r` rather than of a sequence of choices.
The formalization follows the appendix: the vertex type is
$`E \sqcup \bigsqcup_{w \in W} \{w\} \times [4 + r(w)]`, adjacency is "belongs
to a common body", and the graph is _definitionally_ the supremum of its body
cliques.

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.bodyClique
RB31E2E.BodyPinIncidence.bodyPinGraph
RB31E2E.BodyPinIncidence.canonicalBodyPinGraph
```

What `bodyClique` shows is its adjacency relation. What it does not show is its
two proof obligations — a `SimpleGraph` carries proofs that adjacency is
symmetric and irreflexive — which render as `⋯` here and in every quoted body.
Nothing else is left out.

The bound $`|V(B_w)| \ge d_H(w) + 4` is exactly the requirement that four
private vertices survive after the pins have taken theirs, so every body carries
a $`K_4` of its own whatever its pin degree. The formalization names that
$`K_4` explicitly:
{name RB31E2E.BodyPinIncidence.privateCoreVertex}`privateCoreVertex` picks the
four out, {name RB31E2E.BodyPinIncidence.privateCore_adj}`privateCore_adj` proves them mutually adjacent, and
{name RB31E2E.BodyPinIncidence.canonicalBodyPinGraph}`canonicalBodyPinGraph` is
the case $`r \equiv 0`.

# Two readings of generic rigidity

:::definition "rigidity_matrix" (parent := "statement_data") (lean := "RB31E2E.BarJoint.edgeConstraint, RB31E2E.BarJoint.rigidityOperator") (tags := "paper")
The rigidity matrix $`D_F(a)` of a framework has one row per edge, sending a
velocity assignment $`y` to the numbers $`(a_u - a_v) \cdot (y_u - y_v)`. Its
left kernel is the self-stress space.
{Informal.citep "zheng2026" (kind := "equation") (index := "1.4")}[]
:::

```tex "rigidity_matrix"
\begin{definition}
Let $K/k$ be a field extension and let $a = (a_v)_{v \in V} \in (K^3)^V$.  The
rigidity matrix of the framework $(F, a)$ is denoted by
\[
  D_F(a) : (K^3)^V \longrightarrow K^{E_F},
\]
with one row for each edge, defined by
\begin{equation}
  (D_F(a)y)_{uv} = (a_u - a_v) \cdot (y_u - y_v) \qquad (uv \in E_F).
  \tag{1.4}
\end{equation}
An edge weighting $\lambda \in K^{E_F}$ lies in $\ker D_F(a)^T$ if and only if
the corresponding edge loads satisfy the equilibrium equation at every vertex.
The left kernel $\ker D_F(a)^T$ is called the self-stress space (or
equilibrium-stress space) of $(F, a)$.  Throughout, a rigidity row means a row
of $D_F(a)$.

For a finite simple graph $G$ and a realization $p : V(G) \to \mathbb{R}^3$, let
\[
  R_G(p) : (\mathbb{R}^3)^{V(G)} \longrightarrow \mathbb{R}^{V(G) \times V(G)}
\]
be the linear map defined by
\[
  \bigl( R_G(p)u \bigr)_{vw} =
  \begin{cases}
    (p_v - p_w) \cdot (u_v - u_w), & vw \in E(G), \\
    0, & vw \notin E(G).
  \end{cases}
\]
Each undirected edge occurs twice in the target, but the two coordinate linear
forms are equal, so this map has the same rank as the usual rigidity matrix.
\end{definition}
```

The paper uses two forms of this matrix, and so does the formalization.
Equation (1.4) is stated over an arbitrary field extension $`K/k`, because §2
onwards needs to vary the coefficient field; Appendix A.1 uses the real form
$`R_G(p)`, indexed by _all_ ordered vertex pairs with nonedges sent to zero.

{name RB31E2E.BarJoint.rigidityOperator}`rigidityOperator` is that real form,
and the `if` in its body is where the nonedges go to zero. Its value at an
adjacent pair is
{name RB31E2E.BarJoint.edgeConstraint}`edgeConstraint`, the single number one
edge contributes; the two are joined by
{name RB31E2E.BarJoint.edgeFunctional}`edgeFunctional`, which bundles that
number as a linear functional of the velocity. The field-extension form appears
in the Lean development as the direction matrix and its stress space; see
{bpref "stress_exact_sequence"}[the deletion chapter].

```BodyPinBlueprint.bodies
RB31E2E.BarJoint.edgeConstraint
RB31E2E.BarJoint.rigidityOperator
```

:::definition "generic_rigidity_max_rank" (parent := "statement_data") (lean := "RB31E2E.BarJoint.genericRigidityRank, RB31E2E.BarJoint.IsGenericallyRigidInR3, RB31E2E.BodyPinIncidence.GenericallyRigidInR3") (tags := "paper") (uses := "rigidity_matrix, bodypin_expansion")
The generic rank $`\rho_3(G)` is the greatest rank attained by the real rigidity
operator over all placements. A graph is generically rigid in $`\R^3` when
$`\rho_3(G) = \rho_3(K_{V(G)})`.
{Informal.citep "zheng2026" (kind := "section") (index := "1 and A.1")}[]
:::

```tex "generic_rigidity_max_rank"
\begin{definition}
We say that $G_H$ is generically rigid in $\mathbb{R}^3$ if a generic
realization is rigid.  By the Asimow--Roth theorem, this is equivalent to the
rigidity matrix of a generic realization having the same rank as the complete
graph on the same vertex set.

For a finite set $U$, let $K_U$ denote the complete graph with vertex set $U$.
Define
\[
  \rho_3(G) = \max_{p : V(G) \to \mathbb{R}^3} \operatorname{rank} R_G(p).
\]
\end{definition}
```

```BodyPinBlueprint.bodies
RB31E2E.BarJoint.genericRigidityRank
```

No generic configuration is chosen in this statement, and no genericity
hypothesis appears anywhere in it. A maximum over all placements is attained
because the rank takes finitely many values, so the condition is
finite-dimensional linear algebra — which is why it can be stated in Lean
without first developing a theory of generic points. The Lean definition takes
the maximum as a {name Nat.findGreatest}`Nat.findGreatest` bounded by the dimension of the velocity
space, and {name RB31E2E.BarJoint.rigidityRank_le_velocityFinrank}`rigidityRank_le_velocityFinrank` is the bound that makes that
search exhaustive.

Two predicates carry that condition: {name RB31E2E.BarJoint.IsGenericallyRigidInR3}`IsGenericallyRigidInR3`
states it of a graph, and {name RB31E2E.BodyPinIncidence.GenericallyRigidInR3}`GenericallyRigidInR3`
of a body–pin multigraph together with a choice of private vertices, by applying
the first to its expansion.

```BodyPinBlueprint.bodies
RB31E2E.BarJoint.IsGenericallyRigidInR3
RB31E2E.BodyPinIncidence.GenericallyRigidInR3
```

Each is one line. The comparison with the complete graph is written once, for
any dimension, as
{name RB31E2E.BarJoint.IsGenericallyRigidInDimension}`IsGenericallyRigidInDimension`,
and fixing $`d = 3` is the whole of the first; three is the only value this
paper needs.

A maximum-rank placement is precisely what
{Informal.citet "asimowRoth1978"}[] call a _regular point_, and their theorem is
stated at regular points, so this definition coincides with theirs. Their
theorem is stated next. It is the one result in this chapter that the
formalization does not prove.

:::theorem "asimow_roth" (parent := "statement_theorem") (tags := "gap") (uses := "generic_rigidity_max_rank")
Call a placement _regular_ when the rigidity matrix attains its maximal rank
over all placements of the graph. The regular placements form a dense open set
whose complement has Lebesgue measure zero; at a regular placement $`p` of a
graph with $`v` vertices, the framework $`G(p)` is rigid in $`\R^n` exactly when

$$`
\operatorname{rank} \mathrm{d}f_G(p) = nv - (m + 1)(2n - m)/2,
`

where $`m` is the dimension of the affine hull of $`p`; and if $`G(p)` is rigid
at one regular placement it is rigid at every other.
{Informal.citep "asimowRoth1978" (index := "the theorem of §3, and Corollary 2")}[]
:::

That right-hand side is the rank the complete graph attains at the same
placement, which is why the criterion can be stated as
$`\rho_3(G) = \rho_3(K_{V(G)})`. The second half, rigidity at one regular
placement implying rigidity at all of them, is what makes rigidity a property of
the graph rather than of a placement.

This is the one step of the paper's Theorem 1.1 that the formalization does not
contain, and the only statement in this chapter given without a witness, since
it is not the paper's sentence to quote. It is standard, the paper treats it as
such, and {Informal.citet "asimowRoth1979"}[] carries the theory further; but a
reader auditing the Lean development should know that this is where the formal
statement stops and the literature takes over. The register entry for this gap
is in `lt-source-deviations.toml`.

# Pin capacity and the partition condition

:::definition "pin_capacity" (parent := "statement_data") (lean := "RB31E2E.pinCapacity") (tags := "paper")
The capped rank contribution of a bundle of $`n` pins joining two blocks is
$`c(0) = 0`, $`c(1) = 3`, $`c(2) = 5`, and $`c(n) = 6` for $`n \ge 3`.
{Informal.citep "zheng2026" (kind := "equation") (index := "1.1")}[]
:::

```tex "pin_capacity"
\begin{definition}
For disjoint sets $A, B \subseteq W$, let $d_H(A, B)$ be the number of edges
with one endpoint in $A$ and the other in $B$, and define
\begin{equation}
  \ell_H(A, B) =
  \begin{cases}
    0, & d_H(A, B) = 0, \\
    3, & d_H(A, B) = 1, \\
    5, & d_H(A, B) = 2, \\
    6, & d_H(A, B) \ge 3.
  \end{cases}
  \tag{1.1}
\end{equation}

Define also $c : \mathbb{N} \to \mathbb{N}$ by
\[
  c(0) = 0, \qquad c(1) = 3, \qquad c(2) = 5, \qquad c(n) = 6 \quad (n \ge 3).
\]
\end{definition}
```

```BodyPinBlueprint.bodies
RB31E2E.pinCapacity
```

One shared pin forces two bodies to agree at a point, which is three
constraints. Two distinct shared pins leave a relative rotation about the line
through them, so five. Three noncollinear shared pins remove all six relative
degrees of freedom. The cap at six is the dimension of the group of rigid
motions of $`\R^3`, so no bundle can ever do better.

{Informal.citet "jacksonJordanVillanyi2026" (kind := "section") (index := "7.2")}[]
state the same criterion with the same $`\ell_H` notation and the same four
cases. On the value $`5`,
{Informal.citet "kiralyTanigawa2019" (index := "Conjecture 5")}[] observe that
replacing it by $`6` would turn the criterion into the Tutte–Nash-Williams
condition for $`3G` to contain six edge-disjoint spanning trees.

:::definition "partition_condition" (parent := "statement_data") (lean := "RB31E2E.BodyPinIncidence.partitionCapacity, RB31E2E.BodyPinIncidence.PartitionCondition") (tags := "paper") (uses := "pin_capacity, bodypin_incidence")
Every partition of the bodies into $`t` nonempty blocks satisfies

$$`
\sum_{1 \le i < j \le t} \ell_H(P_i, P_j) \ge 6(t - 1).
`

{Informal.citep "zheng2026" (kind := "equation") (index := "1.2, formally A.2")}[]
:::

```tex "partition_condition"
\begin{definition}
For a surjection $\pi : W \twoheadrightarrow [t]$, write
\[
  m_\pi(i, j) = \bigl| \{ e \in E : \{\pi(\partial_0 e), \pi(\partial_1 e)\} = \{i, j\} \} \bigr|.
\]
For every $t \in \mathbb{N}$ and every surjection $\pi : W \twoheadrightarrow [t]$,
\begin{equation}
  6 \max\{t - 1, 0\} \le \sum_{0 \le i < j < t} c\bigl( m_\pi(i, j) \bigr).
  \tag{A.2}
\end{equation}
\end{definition}
```

```BodyPinBlueprint.bodies
RB31E2E.BodyPinIncidence.partitionCapacity
RB31E2E.BodyPinIncidence.PartitionCondition
```

The formalization indexes partitions by surjections $`\pi : W \to [t]` rather than by set
partitions, and writes the right-hand side as `6 * (t - 1)` over $`\N`, where
truncated subtraction supplies the paper's $`\max\{t - 1, 0\}` for free. Both
moves are bookkeeping with a purpose: the empty body set and the one-block case
then fall out of the definition instead of needing separate treatment.

The paper's unordered pairs $`i < j` are the edges of the complete graph on
$`[t]`, and that is literally how
{name RB31E2E.BodyPinIncidence.partitionCapacity}`partitionCapacity` sums over
them: the index set is `(⊤ : SimpleGraph (Fin t)).edgeFinset`. The
formalization also carries a second, ordered convention —
{name RB31E2E.BodyPinIncidence.orderedPartitionCapacity}`orderedPartitionCapacity`, summing over ordered pairs against a bound of
$`12(t-1)` — as an audit form. The paper has only the unordered one.

For a two-block partition $`\{A, B\}` the inequality reduces to
$`\ell_H(A, B) \ge 6`. So at least three pins must join the two blocks; one or
two pins have capacities only $`3` or $`5`.

# The theorem

:::theorem "bodypin_partition_characterization" (parent := "statement_theorem") (tags := "paper, deviation") (uses := "formal_statement, asimow_roth")
For every finite loopless body–pin multigraph $`H` and every admissible choice
of body cliques, $`G_H` is generically rigid in $`\R^3` if and only if the
partition condition holds.
{Informal.citep "zheng2026" (kind := "theorem") (index := "1.1")}[]
:::

```tex "bodypin_partition_characterization"
\begin{theorem}[Body--pin partition characterization]
Let $H = (W, E)$ be any finite loopless multigraph.  For each $w \in W$, choose
a complete graph $B_w$ satisfying
\[
  |V(B_w)| \ge d_H(w) + 4,
\]
and construct $G_H$ as above.  Then the following conditions are equivalent:
\begin{enumerate}
  \item[(i)] $G_H$ is generically rigid in $\mathbb{R}^3$;
  \item[(ii)] every partition $\mathcal{P} = \{P_1, \dots, P_t\}$ of $W$ satisfies
    \begin{equation}
      \sum_{1 \le i < j \le t} \ell_H(P_i, P_j) \ge 6(t - 1).
      \tag{1.2}
    \end{equation}
\end{enumerate}
\end{theorem}
```

This is the paper's headline result: Conjecture 5 of
{Informal.citet "kiralyTanigawa2019"}[], still listed as Conjecture 7.6 by
{Informal.citet "jacksonJordanVillanyi2026"}[] as of July 2026.

It is not the proposition the formalization proves. The formalization proves
{bpref "formal_statement"}[Theorem A.1], its maximum-rank form; the remaining step is
{bpref "asimow_roth"}[the Asimow–Roth step]. The dependency edges on this node record that.

:::theorem "formal_statement" (parent := "statement_theorem") (lean := "RB31E2E.EndToEndBodyPinStatement, RB31E2E.endToEndBodyPinStatement, RB31E2E.endToEndBodyPinStatement_iff_sufficiency") (tags := "paper") (uses := "bodypin_expansion, partition_condition, generic_rigidity_max_rank")
For every finite loopless body–pin multigraph $`H` and every $`r : W \to \N`,
the expanded graph $`G(H, r)` attains the rigidity rank of the complete graph on
its vertex set if and only if the capacity inequality holds for every $`t` and
every surjection $`\pi : W \to [t]`.
{Informal.citep "zheng2026" (kind := "theorem") (index := "A.1")}[]
:::

```tex "formal_statement"
\begin{theorem}[Formally verified body--pin theorem]
For every finite loopless multigraph $H = (W, E; \partial_0, \partial_1)$ and
every $r : W \to \mathbb{N}$, the following conditions are equivalent:
\begin{enumerate}
  \item[(i)] $\rho_3(G(H, r)) = \rho_3(K_{V(H, r)})$;
  \item[(ii)] for every $t \in \mathbb{N}$ and every surjection
    $\pi : W \twoheadrightarrow [t]$,
    \begin{equation}
      6 \max\{t - 1, 0\} \le \sum_{0 \le i < j < t} c\bigl( m_\pi(i, j) \bigr).
      \tag{A.2}
    \end{equation}
\end{enumerate}
\end{theorem}
```

```BodyPinBlueprint.bodies
RB31E2E.EndToEndBodyPinStatement
```

This is the root theorem of the formalization: a closed proposition, universally
quantified over $`H` and $`r`, proved in both directions, with axiom closure
exactly {name propext}`propext`, {name Classical.choice}`Classical.choice`, {name Quot.sound}`Quot.sound`. See
{bpref "trust_boundary"}[the trust boundary].

The appendix reconciles it with Theorem 1.1 in a paragraph. The cases
$`W = \emptyset` and $`|W| = 1` are included; for $`W \ne \emptyset` a
surjection $`\pi : W \to [t]` forces $`t \ge 1`, so (A.2) agrees term by term
with (1.2); for $`W = \emptyset` the only surjection has target $`[0]`, the
inequality reads $`0 \le 0`, and the expanded graph is empty. Setting
$`r(w) = |V(B_w)| - d_H(w) - 4` identifies any expansion of the main text with
some $`G(H, r)` after relabelling private vertices, and conversely. So the two
statements differ only in the reading of "generically rigid".

Since necessity is a theorem, the equivalence is equivalent to its sufficiency
direction alone: that the partition condition implies maximum-rank generic
rigidity. The formalization records that trivial consequence as
{name RB31E2E.endToEndBodyPinStatement_iff_sufficiency}`endToEndBodyPinStatement_iff_sufficiency`
and uses it once, in the final assembly, to avoid restating both directions
there. Necessity is proved separately, in {bpref "necessity"}[the necessity chapter]; everything from
{bpref "sparse22"}[the sparsity chapter] onwards serves the other direction.
