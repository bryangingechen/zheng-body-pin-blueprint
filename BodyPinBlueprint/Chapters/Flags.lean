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

This is the chapter the paper is named for. A collinearity flag records the
collinear neighbour triple produced by a degree-three deletion, a distinguished
missing edge, and an auxiliary vertex; the simultaneous $`K_4`-completion of all
flags is required to stay $`(2,2)`-sparse. Deletion, certified response edges,
switching the distinguished missing edge, and creating or removing a flag all
preserve that sparsity while reducing the base-graph vertex count, which is what
turns the local classification of {bpref "low_degree_classification"}[] into an
induction. See §3 of {Informal.citet "zheng2026"}[].

The chapter opens with a vocabulary table, because the Lean development renames
every object in §3: collinearity flag becomes provenance flag, the support
triple becomes terminals, the auxiliary vertex becomes a ghost vertex, and the
stress–codimension inequality becomes a semismallness budget.

:::group "flags_spine"
The paper's flag calculus.
:::

:::group "flags_infrastructure"
Lean-only state transitions and budget bookkeeping.
:::

:::definition "collinearity_flag" (parent := "flags_spine") (tags := "paper, deviation, unwritten")
A collinearity flag $`d < T < Q`: distinguished missing edge, support triple,
$`K_4`-completion. {Informal.citep "zheng2026" (index := "Definition 3.1")}[] Renamed throughout in the formalization.
:::

:::definition "flag_system" (parent := "flags_spine") (tags := "paper, deviation, unwritten") (uses := "collinearity_flag")
Sparse collinearity-flag systems, and the sparsity condition on the simultaneous
completion. {Informal.citep "zheng2026" (index := "Definition 3.2")}[]
:::

:::lemma_ "flag_incidence_forest" (parent := "flags_spine") (tags := "paper, unwritten") (uses := "flag_system")
The incidence forest of a flag system, and $`\codim X_T = 2|\Gamma|`.
{Informal.citep "zheng2026" (index := "Proposition 3.3")}[] Rendered as a lemma;
see `lt-source-deviations.toml`.
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
and the budget ledger that tracks them. No paper counterpart: the paper moves
between flag systems in prose.
:::
