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
# Degeneracy strata and the route not taken  (stub)

Paper §4.  Phase 4.  Deliberately short: this chapter is a route comparison,
not a summary of §4.  See PLAN.md before extending it — the material here is
not formalized and should not be worked through.
-/

#doc (Manual) "Degeneracy strata and the route not taken" =>

*This chapter is a stub.* Its nodes are titled, tagged and mapped to the
correspondence table, but the mathematics is not written yet: each body is a
one-line placeholder naming the result it will state.

Section 4 of {Informal.citet "zheng2026"}[] recasts the stress–codimension
inequality geometrically. On the root-fixed space of distinct configurations
it forms the degeneracy loci $`\Sigma_s(F)`, the placements whose self-stress
space has dimension at least $`s`, as determinantal subschemes of a direction
complex, and it proves that the universal infinitesimal-motion cone is a local
complete intersection, hence Cohen–Macaulay and pure-dimensional; the
codimension estimate $`\codim \Sigma_s \ge s` is equivalent to Theorem 1.2.

None of this is formalized. The Lean development works with the
field-theoretic form (1.5) of the inequality throughout, and Theorem A.1 does
not depend on the scheme statements. The one part of §4 the formal argument
uses is the grounded model: fixing a root vertex removes the common
translations without changing the self-stresses, and the grounded inequality
(4.7) is equivalent to (1.5), which the paper proves inside §4. This chapter
records what §4 claims and marks that equivalence as the used part.

:::group "strata_comparison"
What §4 claims, and which part of it the formalization uses.
:::

:::definition "direction_complex" (parent := "strata_comparison") (tags := "informal-only, unwritten")
The direction complex of a graph and the degeneracy loci $`\Sigma_s(F)` as
determinantal subschemes; no Lean counterpart.
{Informal.citep "zheng2026" (kind := "equation") (index := "4.2–4.3")}[]
:::

:::theorem "stress_strata_codimension" (parent := "strata_comparison") (tags := "informal-only, unwritten") (uses := "direction_complex")
$`\codim \Sigma_s \ge s`; the universal infinitesimal-motion cone
$`N_F` is a local complete intersection of codimension $`|E(F)|`, hence
Cohen–Macaulay and pure-dimensional. No Lean counterpart.
{Informal.citep "zheng2026" (kind := "theorem") (index := "4.2")}[]
:::

:::lemma_ "grounded_model" (parent := "strata_comparison") (tags := "paper, unwritten") (uses := "stress_codim")
The grounded model and the grounded inequality (4.7). This is the part of §4
the formalization uses: (4.7) is equivalent to (1.5), and Theorem A.1 depends
on nothing else in the section. {Informal.citep "zheng2026" (kind := "section") (index := "4")}[]
:::
