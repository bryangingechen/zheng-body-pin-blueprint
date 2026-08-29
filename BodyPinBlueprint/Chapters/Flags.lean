import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography

open Verso.Genre
open Verso.Genre.Manual
open Informal

set_option doc.verso true

/-
# Collinearity flags  (stub)

Paper §3, and the heart of the argument.  Phase 3.  The vocabulary table goes
at the top of this chapter: every name in §3 is different in Lean.
-/

#doc (Manual) "Collinearity flags" =>

*This chapter is a stub.* Its nodes are titled, tagged and mapped to the
correspondence table, but the mathematics is not written yet: each body is a
one-line placeholder naming the result it will state.

In the exceptional case of {bpref "low_degree_classification"}[the local
classification], deleting a degree-three vertex leaves three collinear
neighbours. Section 3 of {Informal.citet "zheng2026"}[] retains that case as a
_collinearity flag_: the collinear triple, called its support triple, a
distinguished missing edge on the triple, and an auxiliary vertex that
completes the triple to a $`K_4`; the simultaneous $`K_4`-completion of all
flags is required to stay $`(2,2)`-sparse. Every move of the argument —
deleting a vertex, adding a certified response edge, switching the
distinguished missing edge, creating or removing a flag — preserves that
sparsity and decreases the number of base-graph vertices, i.e. of vertices
that are not auxiliary, so the stress–codimension inequality follows by
induction on that number.

The Lean development renames every object of §3: a collinearity flag becomes a
provenance flag, the support triple becomes the terminals, the auxiliary
vertex becomes a ghost vertex, and the inequality $`\Delta \le 0` becomes a
semismallness budget. The vocabulary table relating the two belongs at the top
of this chapter.

:::group "flags_spine"
The paper's flag calculus.
:::

:::group "flags_infrastructure"
Transitions between flag systems, with no paper counterpart.
:::

:::definition "collinearity_flag" (parent := "flags_spine") (tags := "paper, deviation, unwritten")
A collinearity flag $`d < T < Q`: distinguished missing edge, support triple,
and $`K_4`-completion, renamed throughout in the formalization.
{Informal.citep "zheng2026" (index := "Definition 3.1")}[]
:::

:::definition "flag_system" (parent := "flags_spine") (tags := "paper, deviation, unwritten") (uses := "collinearity_flag")
Sparse collinearity-flag systems, and the sparsity condition on the simultaneous
completion. {Informal.citep "zheng2026" (index := "Definition 3.2")}[]
:::

:::lemma_ "flag_incidence_forest" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_system")
The incidence forest of a flag system, and $`\codim X_T = 2|\Gamma|`; rendered
as a lemma rather than a proposition.
{Informal.citep "zheng2026" (index := "Proposition 3.3")}[]
:::

:::lemma_ "support_multiplicity" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_system")
Support multiplicity and the outside / private / shared split of the live
vertices. {Informal.citep "zheng2026" (kind := "section") (index := "3.2")}[]
:::

:::lemma_ "flag_selection" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "support_multiplicity")
The flag selection lemma: some outside vertex has degree at most three, or some
private support vertex has degree at most two. {Informal.citep "zheng2026" (kind := "lemma") (index := "3.4")}[]
:::

:::lemma_ "missing_edge_pivot" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_system")
The completion-preserving pivot that switches the distinguished missing edge.
{Informal.citep "zheng2026" (kind := "lemma") (index := "3.5")}[]
:::

:::lemma_ "private_local_classification" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_selection")
Local classification at a private support vertex. {Informal.citep "zheng2026" (kind := "lemma") (index := "3.6")}[]
:::

:::lemma_ "outside_augmentation" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_selection")
An addable edge or a complete triangle outside the flags. {Informal.citep "zheng2026" (kind := "lemma") (index := "3.7")}[]
:::

:::lemma_ "private_augmentation" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "private_local_classification")
The certified response edge in the private-support case. {Informal.citep "zheng2026" (kind := "lemma") (index := "3.8")}[]
:::

:::theorem "stress_codim_flags" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_selection, missing_edge_pivot, outside_augmentation, private_augmentation, flag_incidence_forest")
The stress–codimension inequality for collinearity flags: the induction on the
number of base-graph vertices. {Informal.citep "zheng2026" (kind := "theorem") (index := "3.9")}[]
:::

:::theorem "stress_codim" (parent := "flags_spine") (tags := "paper, deviation, unwritten") (uses := "stress_codim_flags")
The stress–codimension inequality with no flags,
$`\dim_K \ker D_F(a)^T + \trdeg_k K \le 3|V|`. {Informal.citep "zheng2026" (kind := "theorem") (index := "1.2")}[] In the formalization it appears as the grounded hypothesis of the assembly
theorem rather than as a standalone statement.
:::

:::lemma_ "lean_flag_moves" (parent := "flags_infrastructure") (tags := "lean-only, unwritten")
Flag state transitions — deletion, insertion, private deletion, registration —
together with the bookkeeping of the semismallness budget across each. No
paper counterpart: the corresponding changes of flag system are made inside
the paper's proof of Theorem 3.9.
:::
