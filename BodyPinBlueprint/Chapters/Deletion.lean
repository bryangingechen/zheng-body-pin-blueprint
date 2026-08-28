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
# Vertex deletion and self-stress  (stub)

Paper §2.2.  Phase 2.
-/

#doc (Manual) "Vertex deletion and self-stress" =>

*This chapter is a stub.* Its nodes are titled, tagged and mapped to the
correspondence table, but the mathematics is not written yet: each body is a
one-line placeholder naming the result it will state. See `PLAN.md` for the
phase that covers it.

Section 2.2 of {Informal.citet "zheng2026"}[] compares the self-stress spaces of
$`F` and $`F - v` by an exact sequence, records the change in a four-term
ledger, and classifies what can happen at a low-degree vertex. One case is not
covered by the local estimate: a degree-three vertex whose three neighbours are
collinear. That case is what {bpref "collinearity_flag"}[the flags chapter] is introduced for.

:::group "deletion_spine"
The exact sequence, the ledger, and the local classification.
:::

:::group "deletion_infrastructure"
Base-change and field-tower plumbing with no paper counterpart.
:::

:::lemma_ "stress_exact_sequence" (parent := "deletion_spine") (tags := "paper, unwritten")
Block form of the transposed rigidity matrix after deleting $`v`, the connecting
map $`\partial_v`, and the resulting exact sequence. {Informal.citep "zheng2026" (kind := "equation") (index := "2.1–2.3")}[]
:::

:::definition "deletion_ledger" (parent := "deletion_spine") (tags := "paper, unwritten") (uses := "stress_exact_sequence")
The $`(s, t, u, \delta)` ledger and the defect $`\Delta`. {Informal.citep "zheng2026" (kind := "equation") (index := "2.4–2.6")}[]
:::

:::lemma_ "certified_response_edge" (parent := "deletion_spine") (tags := "paper, unwritten")
The collinear two-edge path, and the certified response edge it produces. {Informal.citep "zheng2026" (index := "Example 2.2")}[]
:::

:::lemma_ "low_degree_classification" (parent := "deletion_spine") (tags := "paper, unwritten") (uses := "deletion_ledger")
Local classification at a low-degree vertex: either the local estimate pays for
the deletion, or the exceptional collinear configuration occurs. {Informal.citep "zheng2026" (kind := "lemma") (index := "2.3")}[]
:::

:::lemma_ "affine_coefficient_descent" (parent := "deletion_spine") (tags := "paper, unwritten")
Descent of affine coefficients into the retained coordinate field. {Informal.citep "zheng2026" (kind := "lemma") (index := "2.4")}[]
:::

:::lemma_ "neighbour_rigidity_rows" (parent := "deletion_spine") (tags := "paper, unwritten") (uses := "low_degree_classification")
Rigidity rows among the three neighbours of a deleted degree-three vertex.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.5")}[]
:::

:::lemma_ "lean_base_change" (parent := "deletion_infrastructure") (tags := "lean-only, unwritten")
Direction-stress base change, finite row systems, coordinate field towers and
localization plumbing: the formal content of the paper's habit of silently
changing coefficient field.
:::
