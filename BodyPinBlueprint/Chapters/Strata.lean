import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Bodies
import BodyPinBlueprint.Figures
import RB31EndToEnd.Algebra.GroundedTwist
import RB31EndToEnd.Linear.GroundedDirectionConstraint

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Degeneracy strata and the route not taken

Paper §4.  Deliberately short: this chapter is a route comparison, not a
summary of §4.  See PLAN.md before extending it — the scheme-theoretic
material here is not formalized and should not be worked through.

Witness conventions are described in the leading comment of `Statement.lean`.
The two `informal-only` nodes carry witnesses although the convention does not
require one: the chapter's job is to state what §4 claims, and the paper's own
words are the statement.  The `direction_complex` witness wraps the section's
running prose in a reconstructed `definition` environment; it is one
contiguous passage of the paper, from "Fix a nonempty finite simple graph"
through (4.3).  The `stress_strata_codimension` witness is the Theorem 4.2
statement, verbatim and contiguous.  The `grounded_model` witness is attached
to the proof block with `(slot := "proof")`, because the paper states and
proves the equivalence with (4.7) inside the proof of Theorem 4.2 and the
grounded inequality has no displayed statement of its own; it is the first
paragraph of that proof, verbatim and contiguous.

Quoted bodies are named rather than copied; the mechanism is described in the
leading comment of `Statement.lean`.  The fence quotes `OffRoot`, which no
node names, because `GroundedSpatialCoordinate` is unreadable without it.

`check-witness-prose.py` reports 12 windows in this chapter; each was checked
and each is a text-layer artifact.  `stress_strata_codimension` (3): the
paper's display (4.5) survives in the text layer as the token `codimXV,o`,
which the transcription writes as a codim operator with a subscript.
`grounded_model` (9): the display (4.7) survives as the tokens `dimK` and
`trdegk`, and the root point `ao` survives as a word ("subtract ao from"),
where the transcription has math.  `direction_complex` matches with no
unmatched window.
-/

#doc (Manual) "Degeneracy strata and the route not taken" =>

Section 4 of {Informal.citet "zheng2026"}[] recasts the stress–codimension
inequality geometrically. On the root-fixed space of pairwise-distinct
configurations it forms the degeneracy loci $`\Sigma_s(F)`, the placements
whose self-stress space has dimension at least $`s`, as determinantal
subschemes of a two-term complex, and it proves that the universal
infinitesimal-motion cone is a local complete intersection, hence
Cohen–Macaulay and pure-dimensional. None of that is formalized: the Lean
development works with the field-theoretic inequality of
{bpref "stress_codim"}[Theorem 1.2] throughout, and
{bpref "formal_statement"}[Theorem A.1] does not depend on the scheme
statements. From this section the formal argument uses only what the paper
calls the _grounded model_ — fixing a root vertex removes the common
translations without changing the self-stresses — and the equivalence of the grounded
inequality (4.7) with Theorem 1.2, which the paper proves inside the proof of
Theorem 4.2. We state the section's two scheme-theoretic claims first, and
then the grounded equivalence, which is the part with a Lean counterpart.

Rank-deficiency loci of rigidity matrices are a classical subject: the pure
condition of {Informal.citet "whiteWhiteley1983"}[] and
{Informal.citet "whiteWhiteley1987"}[] describes the rank-deficient
realizations of isostatic bar–joint and body–bar frameworks, and later work
stratified configuration spaces of tensegrities by the dimension of the
self-stress space and studied rigidity through tangent spaces to measurement
varieties ({Informal.citep "dorayKarpenkovSchepers2010"}[];
{Informal.citep "karpenkov2021"}[];
{Informal.citep "gortlerHealyThurston2010"}[]). Section 4's contribution is a
uniform codimension bound for every finite simple $`(2,2)`-sparse graph and
every $`s`, derived from the collinearity-flag induction of
{bpref "stress_codim_flags"}[the flags chapter].

:::group "strata_comparison"
What Section 4 claims, and which part of it the formalization uses.
:::

# The direction complex and its degeneracy loci

:::definition "direction_complex" (parent := "strata_comparison") (tags := "informal-only")
Fix a root $`o \in V`, set $`n_0 = |V| - 1` and $`m = |E_F|`, and let
$`X^\circ_{V,o}` be the space of configurations with $`a_o = 0` and pairwise
distinct points, a smooth irreducible open variety of dimension $`3n_0`. The
direction complex $`C^\bullet_F` is the two-term complex of trivial bundles on
$`X^\circ_{V,o}` given by $`\partial_F(a) = D_{F,o}(a)^T`, the transpose of
the rigidity matrix with the root's three columns deleted; for
$`1 \le s \le m` the $`s`th stress-degeneracy subscheme $`\Sigma_s(F)` is the
vanishing of the determinantal ideal sheaf of minors of order $`m - s + 1` of
$`\partial_F`, so its points are the configurations whose self-stress space
has dimension at least $`s`.
{Informal.citep "zheng2026" (kind := "equation") (index := "4.2–4.3")}[]
:::

```tex "direction_complex"
\begin{definition}
Fix a nonempty finite simple graph $F = (V, E_F)$ and a root $o \in V$.  Set
\[
  n_0 = |V| - 1, \qquad m = |E_F|,
\]
and fix $a_o = 0$.  Define
\[
  X^\circ_{V,o} = \{(a_v)_{v \ne o} \in (\mathbb{A}^3)^{V \setminus \{o\}} :
    a_u \ne a_v \ (u \ne v)\}, \qquad a_o := 0,
\]
where the pairwise-distinct condition includes $a_v \ne a_o = 0$.  This is a
smooth irreducible open variety of dimension $3n_0$.  Let $D_{F,o}(a)$ be the
grounded rigidity matrix obtained from $D_F(a)$ by deleting the three-column
block of the root vertex, and write
\[
  \partial_F(a) = D_{F,o}(a)^T.
\]
The sum of the vertex blocks in every rigidity row is zero, and hence
\begin{equation}
  \ker D_{F,o}(a)^T = \ker D_F(a)^T.
  \tag{4.1}
\end{equation}

Regard $\partial_F$ as a morphism of trivial vector bundles.  The associated
two-term graph-indexed direction complex, placed in cohomological degrees
$-1, 0$, is
\begin{equation}
  C^\bullet_F =
    \Bigl(\mathcal{O}_{X^\circ_{V,o}}^{E_F}
      \xrightarrow{\;\partial\;} \mathcal{O}_{X^\circ_{V,o}}^{3n_0}\Bigr).
  \tag{4.2}
\end{equation}
For $a \in X^\circ_{V,o}$, let $\kappa(a)$ denote its residue field.  The
fiber complex then satisfies
\[
  H^{-1}\bigl(C^\bullet_F \otimes_{\mathcal{O}_{X^\circ_{V,o}}} \kappa(a)\bigr)
    = \ker \partial_F(a) = \ker D_F(a)^T.
\]
Thus this cohomology group is precisely the self-stress space of $F$ at $a$.

For $r \ge 1$, let $I_r(\partial_F) \subseteq \mathcal{O}_{X^\circ_{V,o}}$ be
the determinantal ideal sheaf generated by the minors of order $r$ of
$\partial_F$.  For $1 \le s \le m$, define the sth closed stress-degeneracy
subscheme by
\begin{equation}
  \Sigma_s(F) = V\left(I_{m-s+1}(\partial_F)\right).
  \tag{4.3}
\end{equation}
\end{definition}
```

The determinantal construction is the standard one for a morphism of vector
bundles ({Informal.citep "brunsVetter1988"}[];
{Informal.citep "fulton1998"}[]). The section illustrates it on the triangle:
by Example 4.1 of {Informal.citet "zheng2026"}[], three pairwise distinct
collinear points give $`K_3` a one-dimensional self-stress space, and the
locus of such configurations has codimension two in $`X^\circ_{V,o}`, so
$`\codim \Sigma_1(K_3) = 2 \ge 1`.

# The codimension theorem for the strata

The right kernel of the rigidity matrix consists of the infinitesimal
motions, so the section also forms the relative cone over the configuration
space: the equations $`D_{F,o}(a)y = 0` in the variables
$`(a, y) \in X^\circ_{V,o} \times \mathbb{A}^{3n_0}` define the _universal
infinitesimal-motion cone_ $`N_F`, whose fiber over a configuration $`a` is
the space of grounded infinitesimal motions there. If the self-stress space
at $`a` has dimension $`t`, that fiber has dimension $`3n_0 - m + t`, so the
fiber dimension jumps exactly where the self-stress dimension does, and the
inequality $`\codim \Sigma_s(F) \ge s` bounds the loci on which the jumps
occur.

:::theorem "stress_strata_codimension" (parent := "strata_comparison") (tags := "informal-only") (uses := "direction_complex, sparse22")
If $`F` is a finite simple $`(2,2)`-sparse graph, then
$`\codim_{X^\circ_{V,o}} \Sigma_s(F) \ge s` for $`1 \le s \le m`, and this
family of estimates holds for every $`s` if and only if Theorem 1.2 holds.
Moreover $`N_F` is a local complete intersection of pure codimension $`m` in
$`X^\circ_{V,o} \times \mathbb{A}^{3n_0}`, hence Cohen–Macaulay, and every
irreducible component has dimension $`6n_0 - m`.
{Informal.citep "zheng2026" (kind := "theorem") (index := "4.2")}[]
:::

```tex "stress_strata_codimension"
\begin{theorem}[Stress-degeneracy strata and the universal infinitesimal-motion cone]
If $F$ is a finite simple $(2,2)$-sparse graph, then
\begin{equation}
  \operatorname{codim}_{X^\circ_{V,o}} \Sigma_s(F) \ge s
    \qquad (1 \le s \le m).
  \tag{4.5}
\end{equation}
Equation (4.5) holds for every $s$ if and only if Theorem 1.2 holds.
Moreover, $N_F$ is a local complete intersection of pure codimension $m$ in
the smooth ambient space $X^\circ_{V,o} \times \mathbb{A}^{3n_0}$, and is
therefore Cohen–Macaulay.  Every irreducible component has dimension
$6n_0 - m$, and hence
\begin{equation}
  \dim N_F = 6n_0 - m.
  \tag{4.6}
\end{equation}
\end{theorem}
```

The formalization contains no counterpart of any statement in the theorem.
The paper's proof has two independent halves. The codimension estimate (4.5)
is obtained from Theorem 1.2 by evaluating the grounded inequality below at
the generic point of a component of $`\Sigma_s(F)`, where the transcendence
degree of the residue field is the dimension of the component; the
scheme-theoretic half bounds $`\dim N_F` by stratifying the base by exact
self-stress dimension, matches that bound with Krull's height theorem, and
concludes that the $`m` defining equations form a regular sequence in a
regular — hence Cohen–Macaulay — ambient local ring
({Informal.citep "eisenbud1995"}[]; {Informal.citep "brunsHerzog1998"}[]).
The sufficiency argument of
{bpref "sufficiency_assembly"}[the assembly chapter] uses the inequality only
in its field-theoretic form, so Theorem 1.1 depends on nothing in this
theorem, and the section is a consequence of the formalized material rather
than a gap in it. Remark 4.3 of
{Informal.citet "zheng2026"}[] compares the two viewpoints: the strata are
cut out by the self-stress dimension of the whole rigidity matrix, while a
collinearity flag imposes the codimension-two collinearity condition of one
support triple, and Theorem 3.9 carries those flag conditions inside the same
inequality.

Figure 3 of {Informal.citet "zheng2026"}[] draws the dimension count of the
scheme-theoretic half, redrawn below: over a configuration $`a_0` outside
$`\Sigma_1(F)` the infinitesimal-motion fiber has dimension $`d_0 = 3n_0 - m`,
over a configuration in the exact stratum $`S_t` it has dimension $`d_0 + t`
while $`S_t` itself has codimension at least $`t`, and hence
$`\dim (N_F|_{S_t}) \le (3n_0 - t) + (d_0 + t) = 6n_0 - m`.

```BodyPinBlueprint.svgFigure (alt := "A base variety X with a stratum S t; the infinitesimal-motion fiber has dimension d0 over a point outside Sigma 1 and dimension d0 plus t over a point of S t, whose codimension is at least t")
<svg viewBox="0 0 700 260" xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
  <g font-size="12.5" text-anchor="middle">
    <rect x="60" y="175" width="580" height="44" rx="10" fill="none" stroke="currentColor" stroke-width="1.4"/>
    <text x="120" y="201">dim X = 3n<tspan baseline-shift="sub" font-size="9">0</tspan></text>
    <text x="620" y="201" font-style="italic">X</text>
    <ellipse class="bpx_fig_bodyB" cx="470" cy="197" rx="95" ry="15" stroke="currentColor" stroke-width="1.2"/>
    <text x="398" y="201" font-style="italic">S<tspan baseline-shift="sub" font-size="9">t</tspan></text>
    <line x1="205" y1="190" x2="205" y2="95" stroke="currentColor" stroke-width="2"/>
    <circle cx="205" cy="197" r="3.5" fill="currentColor"/>
    <text x="205" y="80">fiber dimension d<tspan baseline-shift="sub" font-size="9">0</tspan></text>
    <text x="205" y="243">a<tspan baseline-shift="sub" font-size="9">0</tspan> ∉ Σ<tspan baseline-shift="sub" font-size="9">1</tspan>(F); stress dimension 0</text>
    <line x1="470" y1="190" x2="470" y2="55" stroke="currentColor" stroke-width="2"/>
    <circle cx="470" cy="197" r="3.5" fill="currentColor"/>
    <text x="470" y="40">fiber dimension d<tspan baseline-shift="sub" font-size="9">0</tspan> + t</text>
    <text x="470" y="243">a ∈ S<tspan baseline-shift="sub" font-size="9">t</tspan>; codim<tspan baseline-shift="sub" font-size="9">X</tspan> S<tspan baseline-shift="sub" font-size="9">t</tspan> ≥ t</text>
  </g>
</svg>
```

# The grounded model

The part of the section the formal argument uses is its first paragraph and
equation (4.7). Both directions of the main theorem work with a root vertex
fixed at the origin: the necessity direction grounds by fixing one block's
twist to zero, and the self-stress estimate used by the sufficiency direction
is stated over configurations with $`a_o = 0`. The word _grounded_ for this
operation is the paper's own, used also by the formalization's module names;
it does not appear in the reference papers, and it is not the _pinned
framework_ of {Informal.citet "kiralyTanigawa2019"}[], in which the pinned
points are fixed completely in the ambient space — grounding fixes one point
and removes only the translations, and in a body–pin graph the word pin is
already taken. The equivalence with the ungrounded inequality of Theorem 1.2
is the following lemma.

:::lemma_ "grounded_model" (parent := "strata_comparison") (lean := "RB31E2E.GroundedDirectionConstraint.GroundedSpatialCoordinate, RB31E2E.GroundedDirectionConstraint.ker_synthesis_eq_directionStressSpace") (tags := "paper") (uses := "stress_codim")
Let $`a : V \to K^3` be an injective configuration with $`a_o = 0` whose
nonroot coordinates generate the extension $`K/k`. Theorem 1.2 is equivalent
to the grounded inequality
$$`
\dim_K \ker D_F(a)^T + \trdeg_k K \le 3n_0.
`
{Informal.citep "zheng2026" (kind := "equation") (index := "4.7")}[]
:::

:::proof "grounded_model"
Given Theorem 1.2, take three parameters $`z = (z_1, z_2, z_3)` algebraically
independent over $`K` and translate every point by $`z` over $`K(z)`. The
rigidity matrix is unchanged, the translated coordinates generate $`K(z)`,
and $`\trdeg_k K(z) = \trdeg_k K + 3`; applying Theorem 1.2 to the translated
configuration and removing the three added parameters gives the grounded
inequality. Conversely, subtract $`a_o` from an arbitrary configuration and
let $`L` be the field generated by the coordinate differences. The rigidity
matrix is defined over $`L` and rank does not change under the scalar
extension $`K/L`, while $`K` is generated by $`L` and the three coordinates
of $`a_o`, so $`\trdeg_k K \le \trdeg_k L + 3`; applying the grounded
inequality to $`a - a_o` gives Theorem 1.2.
:::

```tex "grounded_model" (slot := "proof")
\begin{proof}
We first show that Theorem 1.2 is equivalent to the grounded inequality (4.7).
Suppose that $a_o = 0$ and that $K$ is generated by the nonroot coordinates.
Choose three parameters $z = (z_1, z_2, z_3)$ that are algebraically
independent over $K$, and, over the extension field $K(z)$, translate every
point to $a_v + z$.  The rigidity matrix does not change, while the translated
coordinates generate $K(z)$: the root point gives $z$, and subtracting it from
the other points recovers the original coordinates.  Applying Theorem 1.2 to
the configuration $v \mapsto a_v + z$ and removing the three added
transcendental parameters gives
\begin{equation}
  \dim_K \ker D_F(a)^T + \operatorname{trdeg}_k K \le 3n_0.
  \tag{4.7}
\end{equation}
Conversely, subtract $a_o$ from an arbitrary ungrounded configuration, and let
$L$ be the subfield generated by all coordinate differences.  The original
coordinate field $K$ is generated by $L$ together with the three coordinates
of $a_o$.  The rigidity matrix is defined over $L$, and the rank of a finite
matrix is unchanged under the scalar extension $K/L$.  Therefore
\[
  \dim_K \ker D_F(a)^T = \dim_L \ker D_F(a - a_o)^T, \qquad
  \operatorname{trdeg}_k K \le \operatorname{trdeg}_k L + 3.
\]
Applying the grounded inequality to $a - a_o$ proves Theorem 1.2.
\end{proof}
```

The formalization grounds by index type rather than by deleting columns: the
grounded coordinates form the type
{name RB31E2E.GroundedDirectionConstraint.GroundedSpatialCoordinate}`GroundedSpatialCoordinate`,
with three spatial coordinates at each vertex other than the root, and the
ambient count $`3n_0` is its cardinality.

```BodyPinBlueprint.bodies
RB31E2E.OffRoot
RB31E2E.GroundedDirectionConstraint.GroundedSpatialCoordinate
```

The vertex blocks of every rigidity row sum to zero, which is the paper's
observation (4.1), formalized as
{name RB31E2E.GroundedDirectionConstraint.sum_directionRow_eq_zero}`sum_directionRow_eq_zero`;
hence restricting the equilibrium output to the non-root blocks leaves the
self-stress space of $`F` literally unchanged, which
{name RB31E2E.GroundedDirectionConstraint.ker_synthesis_eq_directionStressSpace}`ker_synthesis_eq_directionStressSpace`
states, and grounding removes only the translations.

Of the paper's two directions, the formalization needs the one from the
ungrounded inequality to the grounded one: the grounded form is the sole
self-stress hypothesis of the assembly theorem in
{bpref "sufficiency_assembly"}[the body–pin chapter], and its derivation from
the flag theorem — by the same device of adjoining three translation
parameters, over $`\Q` and with the cancellation made explicit — is recorded
on {bpref "stress_codim"}[the Theorem 1.2 node] of the flags chapter.
