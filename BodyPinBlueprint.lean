import Verso
import VersoManual
import VersoBlueprint
import VersoBlueprint.Commands.Graph
import VersoBlueprint.Commands.Summary
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography
import BodyPinBlueprint.Chapters.Statement
import BodyPinBlueprint.Chapters.Necessity
import BodyPinBlueprint.Chapters.Sparsity
import BodyPinBlueprint.Chapters.Deletion
import BodyPinBlueprint.Chapters.Flags
import BodyPinBlueprint.Chapters.Strata
import BodyPinBlueprint.Chapters.SplitKlein
import BodyPinBlueprint.Chapters.BodyPin
import BodyPinBlueprint.Chapters.Correspondence

open Verso.Genre
open Verso.Genre.Manual
open Informal

set_option doc.verso true

#doc (Manual) "Three-Dimensional Body-Pin Rigidity" =>

%%%
shortTitle := "Body-Pin Rigidity"
%%%

An *unofficial* blueprint relating Denzel Zheng's paper on three-dimensional
body–pin rigidity to its Lean 4 formalization. All mathematical results are
his; errors in this exposition are ours. Nothing here is endorsed by the author,
and the `owner` metadata on a node records who is writing that node, never who
proved the theorem.

The theorem is a characterization of generic rigidity for body–pin frameworks
in $`\R^3`. Expand each rigid body into a complete graph, let each pin be a
vertex shared by the two bodies it joins, and the resulting graph is generically
rigid exactly when every partition of the bodies into $`t` blocks satisfies
$`\sum_{i<j} \ell_H(P_i, P_j) \ge 6(t-1)`, where a bundle of one, two, or three
or more pins between two blocks contributes $`3`, $`5`, or $`6`. The precise
statement is {bpref "bodypin_partition_characterization"}[].

Generic rigidity of finite graphs has combinatorial characterizations in
dimensions one and two. In dimension three none is known — not even for the rank
function of the rigidity matroid of an arbitrary graph
{Informal.citep "laman1970" "lovaszYemini1982" "graverServatiusServatius1993" "jordan2016" "cruickshankJacksonJordanTanigawa2026" "jacksonJordanVillanyi2026"}[],
and the difficulty persists for graphs covered by large complete subgraphs.
Body–pin graphs are exactly such a class. Two neighbouring models do have
characterizations — body–bar frameworks, by a packing of spanning trees, and
body–hinge frameworks with their molecular variants
{Informal.citep "tay1984" "whiteley1988" "tay1989" "katohTanigawa2011" "kiralyTanigawa2019"}[] —
but a pin is a shared joint rather than a bar between two bodies, so the
expanded graph lands back in the ordinary three-dimensional bar–joint rigidity
matroid and the packing theorems do not transfer.

This is Conjecture 5 of {Informal.citet "kiralyTanigawa2019"}[]. According to
the historical account in
{Informal.citet "jacksonJordanVillanyi2026" (kind := "section") (index := "7.2")}[], the
criterion was proposed independently by Jackson–Jordán in 2009 and by Tanigawa
in 2011, and as of July 2026 the genuine three-dimensional statement was still
listed there as Conjecture 7.6. Those authors proved the same partition formula
for the $`C^1_2` cofactor matroid, whose combinatorial characterization is due
to {Informal.citet "clinchJacksonTanigawa2022b"}[] — but equality of the
cofactor matroid with the three-dimensional rigidity matroid is
{Informal.citet "whiteley1996"}[]'s Conjecture 10.3.2, still open, so that
result does not settle the Euclidean question. What
{Informal.citet "zheng2026"}[] does is go at the rigidity matrix of $`\R^3`
directly, through a stress–codimension theorem for $`(2,2)`-sparse graphs
whose degree-three deletion step forces a collinear neighbour triple — and so
requires carrying *collinearity flags* through the induction. Prescribed
collinearity has been studied before, for planar bar–joint rigidity and for
pin-collinear body–pin frameworks
{Informal.citep "jacksonJordan2005" "jacksonJordan2008"}[]; what is new here is
that the collinear triple is not prescribed in advance. It arises during vertex
deletion, and has to be carried along.

The formalization is already complete: no `sorry`, no custom axioms, axiom
closure exactly `propext`, `Classical.choice`, `Quot.sound`. So this is not a
coordination blueprint, and its progress percentage is not the point. Its job is
to let a reader check, statement by statement, that the Lean development proves
*the paper's theorem*, and to make visible where the Lean route departs from the
written argument. Coverage and correspondence are the deliverable. Concretely,
that means every node that corresponds to something in the paper carries the
paper's own words as a hidden source witness, every divergence has an entry in a
fingerprinted register, and the audit chapter asks of each of the development's
125 modules which node accounts for it.

A reader new to the material should start with the author's own research note,
[Stress Degeneracy, Collinearity Flags, and Three-Dimensional Body–Pin
Rigidity](https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/),
which walks the same argument informally in six sections
{Informal.citep "zheng2026note"}[]. Then read {bpref "bodypin_partition_characterization"}[]
here, and follow the dependency graph. Note that the note's wording differs from
the paper's throughout; where this blueprint quotes, it quotes the paper.

Node tags say what state the *exposition* is in, not what state a proof is in:

- `paper` — a numbered result of the paper, mapped to Lean
- `informal-only` — in the paper, deliberately not formalized
- `lean-only` — in Lean, with no paper counterpart
- `deviation` — mapped, but by a different route; has a register entry
- `gap` — cited by the paper, not formalized, and not ours to prove
- `unwritten` — node stubbed, prose not drafted

Three caveats on provenance, all of which a reader should weigh. The paper is a
preprint distributed as a PDF under a ResearchGate DOI, with no arXiv version as
of 27 August 2026, and result numbering shifts between revisions — so this
blueprint pins a SHA-256 of the exact file it maps and labels its nodes
semantically rather than by paper number. The formalization repository carries
no licence, so it is referenced here as a pinned submodule and never vendored.
And the author credits OpenAI Codex (GPT-5.6 Sol) in both the paper and the note
with assisting the proof organization, the Lean formalization and its
verification, the typesetting and the proofreading; the Lean development is
nonetheless kernel-checked, which is the property that actually carries the
weight.

{include 0 BodyPinBlueprint.Chapters.Statement}

{include 0 BodyPinBlueprint.Chapters.Necessity}

{include 0 BodyPinBlueprint.Chapters.Sparsity}

{include 0 BodyPinBlueprint.Chapters.Deletion}

{include 0 BodyPinBlueprint.Chapters.Flags}

{include 0 BodyPinBlueprint.Chapters.Strata}

{include 0 BodyPinBlueprint.Chapters.SplitKlein}

{include 0 BodyPinBlueprint.Chapters.BodyPin}

{include 0 BodyPinBlueprint.Chapters.Correspondence}

{blueprint_graph}
{blueprint_summary}
{blueprint_bibliography}
