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
# Necessity  (stub)

Paper §6.4, first half, and §6.1.  Phase 2.  Nodes here are titled and tagged
but not drafted; `correspondence.toml` holds the module inventory for each.
-/

#doc (Manual) "Necessity" =>

Necessity takes one paragraph in {Informal.citet "zheng2026"}[] and 894 lines in
the formalization. Assign a common block twist to every body in a block and
count degrees of freedom modulo the six-dimensional diagonal; the capacity
inequality follows. The formalization additionally supplies the genericity
apparatus that the paragraph assumes.

:::group "necessity_spine"
The paper's necessity argument.
:::

:::group "necessity_infrastructure"
The genericity machinery with no paper counterpart.
:::

:::lemma_ "necessity" (parent := "necessity_spine") (tags := "paper, unwritten")
Generic rigidity of the expanded graph implies the partition condition.
{Informal.citep "zheng2026" (kind := "section") (index := "6.4")}[]
:::

:::lemma_ "lean_genericity" (parent := "necessity_infrastructure") (tags := "lean-only, unwritten")
Openness of the maximum-rank locus, affine independence of the body cores, and
the core-line determinant polynomial: the ingredients the paper's one-paragraph
argument leaves implicit.
:::
