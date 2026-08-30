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
his; errors in this exposition are ours. Nothing here is endorsed by the
author. The `owner` metadata on a node records who is writing that node, never
who proved the theorem.

A body–pin framework is a finite collection of rigid bodies in $`\R^3`, joined
at pins: a pin is a point shared by exactly two bodies, about which the two
bodies rotate freely relative to each other. Its combinatorics is a finite
loopless multigraph $`H = (W, E)` with one vertex per body and one edge per
pin, where two bodies sharing several pins give parallel edges. The framework
is modelled inside ordinary bar–joint rigidity by expanding each body $`w` into
a complete graph — its vertices points fixed on the body — and letting each pin
be a vertex shared by the two complete graphs of the bodies it joins.

The paper's theorem characterizes generic rigidity of the expanded graph: it is
generically rigid in $`\R^3` exactly when every partition of the bodies into
$`t` nonempty blocks $`P_1, \dots, P_t` satisfies

$$`
\sum_{i<j} \ell_H(P_i, P_j) \ge 6(t-1),
`

where $`\ell_H(P_i, P_j)` is $`0`, $`3`, $`5`, or $`6` according as the number
of pins joining a body of $`P_i` to a body of $`P_j` is zero, one, two, or at
least three. A single shared pin constrains two blocks at one point, which is
three constraints; a second pin leaves only a rotation about the line through
the two, so five; three or more pins can never remove more than the six
degrees of freedom of a rigid motion. The precise statement is
{bpref "bodypin_partition_characterization"}[the body–pin partition characterization].

Generic rigidity of finite graphs has combinatorial characterizations in
dimensions one and two. In dimension three none is known, not even for the rank
function of the rigidity matroid of an arbitrary graph
{Informal.citep "laman1970" "lovaszYemini1982" "graverServatiusServatius1993" "jordan2016" "cruickshankJacksonJordanTanigawa2026" "jacksonJordanVillanyi2026"}[],
and the difficulty persists for graphs covered by large complete subgraphs,
which is the class body–pin graphs belong to. Two neighbouring models do have
characterizations: body–bar frameworks, by a packing of spanning trees, and
body–hinge frameworks with their molecular variants
{Informal.citep "tay1984" "whiteley1988" "tay1989" "katohTanigawa2011" "kiralyTanigawa2019"}[].
A pin, however, is a shared joint rather than a bar between two bodies, so the
expanded graph lies in the ordinary three-dimensional bar–joint rigidity
matroid and those packing theorems do not transfer.

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
result does not settle the Euclidean question.
{Informal.citet "zheng2026"}[] works with the rigidity matrix of $`\R^3`
directly, through a stress–codimension theorem for $`(2,2)`-sparse graphs whose
degree-three deletion step forces a collinear neighbour triple, and so requires
carrying *collinearity flags* through the induction. Prescribed collinearity
has been studied before, for planar bar–joint rigidity and for pin-collinear
body–pin frameworks {Informal.citep "jacksonJordan2005" "jacksonJordan2008"}[];
here, by contrast, the collinear triple is not prescribed in advance: it arises
during vertex deletion and is retained in the later steps.

The chapters follow the paper. {bpref "formal_statement"}[The statement
chapter] gives the body–pin model, the rigidity matrix, and the theorem in
both of the paper's formulations. {bpref "necessity"}[The necessity
chapter] proves that rigidity implies the partition condition, by a rank
comparison: rigidity makes a certain block-twist operator injective, and the
rank of that operator is at most the sum of the bundle capacities. The rest of
the blueprint serves the sufficiency direction.
{bpref "sparse22"}[The sparsity chapter] introduces $`(2,2)`-sparse graphs and
tight sets; {bpref "stress_exact_sequence"}[the deletion chapter] measures
what deleting one vertex does to the self-stress space, and its exceptional
case — three collinear neighbours — is the reason
{bpref "collinearity_flag"}[the flags chapter] exists, whose induction proves
the stress–codimension inequality.
{bpref "isotropic_ideal_height"}[The Split–Klein chapter] converts that inequality
into a height estimate for the ideal of twist-difference equations, and
{bpref "sufficiency_assembly"}[the body–pin chapter] assembles the sufficiency
direction from a $`(2,2)`-sparse subgraph of representative pins.
{bpref "direction_complex"}[The strata chapter] records the scheme-theoretic
part of the paper that is deliberately not formalized, and
{bpref "trust_boundary"}[the correspondence chapter] is the audit: what
corresponds to what, and what the verification does and does not cover.

The formalization is already complete: no `sorry`, no custom axioms, axiom
closure exactly `propext`, `Classical.choice`, `Quot.sound`. This is therefore
not a coordination blueprint, and it does not track a progress percentage. It is
written so that a reader can check, statement by statement, that the
formalization proves the paper's theorem, and can see where the formal route
departs from the written one. Each node that corresponds to something in the
paper carries the paper's own words as a hidden source witness; each divergence
has an entry in a fingerprinted register; and the audit chapter asks, of each of
the development's 126 modules, which node accounts for it.

A reader new to the material may prefer to start with the author's own research
note, [Stress Degeneracy, Collinearity Flags, and Three-Dimensional Body–Pin
Rigidity](https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/),
which walks the same argument informally in six sections
{Informal.citep "zheng2026note" (index := "research note")}[]. The note's
wording differs from the paper's throughout; where this blueprint quotes, it
quotes the paper.

Two numbering systems appear on these pages and they are not the same. Headings
such as "Definition 1.1.1" or "Theorem 1.4.2" are the blueprint's own numbering,
assigned by position in this document. The paper's numbers — Theorem 1.1,
Lemma 2.3, equation (1.1) — appear only inside citations, as "(Zheng, 2026,
Theorem 1.1)". A cross-reference in the prose is written out in words rather
than as a number, so that nothing in a sentence can be mistaken for a paper
result.

Node tags say what state the *exposition* is in, not what state a proof is in:

- `paper` — a numbered result of the paper, mapped to Lean
- `informal-only` — in the paper, deliberately not formalized
- `lean-only` — in Lean, with no paper counterpart
- `deviation` — mapped, but by a different route; has a register entry
- `gap` — cited by the paper, not formalized, and not ours to prove
- `unwritten` — node stubbed, prose not drafted

Three caveats on provenance. The paper is a preprint distributed as a PDF under
a ResearchGate DOI, with no arXiv version as of 27 August 2026, and result
numbering shifts between revisions, so this blueprint pins a SHA-256 of the
exact file it maps and labels its nodes semantically rather than by paper
number. The formalization repository carries no licence, so it is referenced
here as a pinned submodule and never vendored: where a definition's body
appears on these pages it is read out of that submodule as the page is built,
and the only thing ever left out of one is a proof obligation, which renders as
`⋯`. The author credits OpenAI Codex (GPT-5.6 Sol), in both the paper and the
note, with assisting the proof organization, the Lean formalization and its
verification, the typesetting and the proofreading; the kernel check does not
depend on how the proofs were produced.

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
