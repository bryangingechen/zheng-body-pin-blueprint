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

Section 4 of {Informal.citet "zheng2026"}[] recasts the stress–codimension
inequality geometrically: the direction complex, the determinantal degeneracy
loci $`\Sigma_s(F)`, the universal infinitesimal-motion cone, and the
conclusion that the cone is a local complete intersection and therefore
Cohen–Macaulay and pure-dimensional.

*None of this is formalized*, and none of it needs to be. The Lean development
uses the field-theoretic inequality throughout, and Theorem A.1 never depends
on the scheme statements. This chapter exists to say so in place: a reader
meeting a scheme-theoretic section with no Lean beside it will ask whether it
was skipped, and the answer belongs here rather than in a footnote. The one
mapped part is the equivalence the paper itself proves between (1.5) and (4.7).

:::group "strata_comparison"
What §4 claims, and which part of it the formalization uses.
:::

:::definition "direction_complex" (parent := "strata_comparison") (tags := "informal-only, unwritten")
The direction complex of a graph and the degeneracy loci $`\Sigma_s(F)` as
determinantal subschemes. {Informal.citep "zheng2026" (kind := "equation") (index := "4.2–4.3")}[] No Lean counterpart.
:::

:::theorem "stress_strata_codimension" (parent := "strata_comparison") (tags := "informal-only, unwritten") (uses := "direction_complex")
$`\codim \Sigma_s \ge s`; the universal infinitesimal-motion cone
$`N_F` is a local complete intersection of codimension $`|E(F)|`, hence
Cohen–Macaulay and pure-dimensional. {Informal.citep "zheng2026" (kind := "theorem") (index := "4.2")}[] No Lean counterpart.
:::

:::lemma_ "grounded_model" (parent := "strata_comparison") (tags := "paper, unwritten") (uses := "stress_codim")
The grounded model and the grounded inequality (4.7), which is the part of §4
the formalization does use: it is equivalent to (1.5), and that equivalence is
the only bridge Theorem A.1 crosses into this section. {Informal.citep "zheng2026" (kind := "section") (index := "4")}[]
:::
