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
# Sparse graphs and addable edges  (stub)

Paper §2.1, plus the largest Lean-only cluster in the development.  Phase 2.
-/

#doc (Manual) "Sparse graphs and addable edges" =>

Section 2.1 of {Informal.citet "zheng2026"}[] is two paragraphs: supermodularity
of the edge-count function gives uncrossing, uncrossing gives the addable-edge
criterion, and Lemma 2.1 follows. The formalization needs about 3,500 lines for
the same ground, because the uncrossing arguments are invoked in situations
where a construction theorem for $`(2,2)`-tight graphs has to be available.
That material is covered here by a single cluster node,
{bpref "lean_nixon_owen_reduction"}[].

:::group "sparsity_spine"
The paper's sparsity vocabulary.
:::

:::group "sparsity_infrastructure"
Lean-only combinatorics supporting the paper's short uncrossing arguments.
:::

:::definition "sparse22" (parent := "sparsity_spine") (tags := "paper, unwritten")
$`(2,2)`-sparsity: every nonempty $`U \subseteq V` satisfies
$`|E_F(U)| \le 2|U| - 2`; tight sets are those attaining equality.
{Informal.citep "zheng2026" (kind := "equation") (index := "1.3")}[]
:::

:::lemma_ "uncrossing" (parent := "sparsity_spine") (tags := "paper, unwritten")
Union and intersection of two intersecting tight sets are tight; the
addable-edge criterion follows.
{Informal.citep "zheng2026" (kind := "section") (index := "2.1")}[]
:::

:::lemma_ "addable_edge_triple" (parent := "sparsity_spine") (tags := "paper, unwritten") (uses := "uncrossing, sparse22")
An addable edge among three vertices: if $`Q + vN` is $`(2,2)`-sparse and
$`Q[N]` is not a triangle, some nonedge inside $`N` can be added.
{Informal.citep "zheng2026" (kind := "lemma") (index := "2.1")}[]
:::

:::lemma_ "lean_nixon_owen_reduction" (parent := "sparsity_infrastructure") (tags := "lean-only, unwritten")
A Nixon–Owen style construction theorem for $`(2,2)`-tight graphs, with proper
tight modules, triangle sequences and same-vertex tight completion. No paper
counterpart; it is what the short uncrossing arguments rest on formally.
:::
