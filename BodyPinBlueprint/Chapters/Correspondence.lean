import Verso
import VersoManual
import VersoBlueprint
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Bibliography

open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open Informal

set_option doc.verso true

/-
# Correspondence and audit

No paper counterpart, except for the trust boundary, which is Appendix A.2.
The chapter renders the correspondence table, the glossary, the deviations
register, the trust boundary, and the reverse index from Lean module to
blueprint node.

The three tables here are hand-written copies of machine-readable sources --
the correspondence table and the reverse index of `correspondence.toml`, the
deviations table of `lt-source-deviations.toml` -- and `scripts/coverage.py`
checks every row against its source, so none of them can drift: a row's paper
locus, node link and status must match its entry, the reverse index must list
every module of the pinned formalization exactly once with exactly the
entries that name it and a source link to the module at the pinned repo and
rev, daggers must match the reachability measurement, and the deviations
table must carry every register entry's locus, with each row's chapter cell
linking the node whose witness the entry fingerprints (any node of the
chapter, for the three fingerprint-free entries).

Witness conventions are described in the leading comment of `Statement.lean`.
This chapter carries no witness and no node: the appendix's trust boundary
(A.2) states checkable facts about the verification but numbers no result,
so it is quoted verbatim in the prose of its section -- a displayed
quotation, not a reconstructed environment -- and its correspondence entry
carries no label.  The quote reflows the appendix's two displayed lines into
the sentences introducing them and changes nothing else; it is transcribed
from `source/paper.txt` like every witness, but being prose rather than a
`tex` block it is outside `check-witness-prose.py`'s scan, so "quote matches
the paper" is a review item here.
-/

#doc (Manual) "Correspondence and audit" =>

%%%
tag := "correspondence-audit"
%%%

The eight chapters before this one follow the paper's results in the paper's
order. This chapter is organized by the formalization instead. It lists, for
every numbered result of {Informal.citet "zheng2026"}[], the node that
documents it and the state of the mapping; collects the vocabulary that the
paper and the Lean development do not share; summarizes every registered
deviation in one place; states what the kernel check covers and what stands
outside it; and records, for each of the development's 126 modules, which
node accounts for it.

# The correspondence table

Each row gives the paper's locus, the result, the node of this blueprint
that documents it, and a status. _Mapped_ means the result has a Lean anchor
on that node; _deviation_ means it is mapped but proved or represented by a
different route, and the register below has the entry; _informal_ means the
paper's statement is deliberately not formalized and nothing depends on it;
_gap_ means the paper cites the result and the formalization does not
contain it; _lean-only_ means the Lean development contains the material and
the paper does not. Five rows carry no node: three are the paper's worked
examples and closing remark, which are covered in their chapters' prose, one
is a one-declaration reduction recorded with the root theorem, and one is
the trust boundary of Appendix A.2, quoted verbatim in its own section below
rather than wrapped in a formal environment the paper does not have. The table
is kept in machine-readable form in the repository file
`correspondence.toml`, and the build checks each row here against it, so a
row cannot drift from the entry it copies.

Section 1 states the theorem, and Appendix A gives the formal statement and
the scope of the verification:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * §1
  * Loopless body–pin multigraph $`H`
  * {bpref "bodypin_incidence"}[`bodypin_incidence`]
  * mapped
* * §1
  * Expanded graph $`G_H` as a union of body cliques
  * {bpref "bodypin_expansion"}[`bodypin_expansion`]
  * mapped
* * (1.1)
  * Capacity $`\ell_H \in \{0, 3, 5, 6\}`
  * {bpref "pin_capacity"}[`pin_capacity`]
  * mapped
* * (1.2)/(A.2)
  * Partition condition $`\sum \ell_H(P_i, P_j) \ge 6(t-1)`
  * {bpref "partition_condition"}[`partition_condition`]
  * mapped
* * (1.4)
  * Rigidity matrix $`D_F(a)`
  * {bpref "rigidity_matrix"}[`rigidity_matrix`]
  * mapped
* * §1
  * Generic rigidity as attained maximum rank
  * {bpref "generic_rigidity_max_rank"}[`generic_rigidity_max_rank`]
  * mapped
* * Thm 1.1
  * Body–pin partition characterization, informal form
  * {bpref "bodypin_partition_characterization"}[`bodypin_partition_characterization`]
  * deviation
* * Thm A.1
  * Formally verified body–pin theorem, the root theorem
  * {bpref "formal_statement"}[`formal_statement`]
  * mapped
* * §1
  * Asimow–Roth: maximum rank implies generic rigidity
  * {bpref "asimow_roth"}[`asimow_roth`]
  * gap
* * —
  * Equivalence reduces to the sufficiency direction
  * none
  * lean-only
* * A.2
  * Trust boundary and axiom closure
  * none
  * informal
:::

Section 2 develops the sparsity class and the deletion step:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * (1.3)
  * $`(2,2)`-sparse and tight sets
  * {bpref "sparse22"}[`sparse22`]
  * mapped
* * §2.1
  * Uncrossing of intersecting tight sets
  * {bpref "uncrossing"}[`uncrossing`]
  * mapped
* * §2.1
  * Addable-edge criterion
  * {bpref "addable_edge_criterion"}[`addable_edge_criterion`]
  * deviation
* * Lem 2.1
  * Addable edge among three vertices
  * {bpref "addable_edge_triple"}[`addable_edge_triple`]
  * mapped
* * §2.2
  * Direction rows and the self-stress space over a coefficient field
  * {bpref "rigidity_row"}[`rigidity_row`]
  * mapped
* * §2.2
  * Retained coordinate field $`L` and the extension degree $`\delta_v`
  * {bpref "retained_coordinate_field"}[`retained_coordinate_field`]
  * mapped
* * (2.1)-(2.3)
  * Block form and the self-stress exact sequence
  * {bpref "stress_exact_sequence"}[`stress_exact_sequence`]
  * mapped
* * (2.4)-(2.6)
  * The $`(s, t, u, \delta)` ledger and the defect $`\Delta`
  * {bpref "deletion_ledger"}[`deletion_ledger`]
  * deviation
* * §2.2, Ex 2.2
  * Certified response edge; the collinear two-edge path
  * {bpref "certified_response_edge"}[`certified_response_edge`]
  * mapped
* * Lem 2.3
  * Low-degree local classification
  * {bpref "low_degree_classification"}[`low_degree_classification`]
  * mapped
* * Lem 2.4
  * Descent of affine coefficients
  * {bpref "affine_coefficient_descent"}[`affine_coefficient_descent`]
  * mapped
* * Lem 2.5
  * Rigidity rows among the three neighbours
  * {bpref "neighbour_rigidity_rows"}[`neighbour_rigidity_rows`]
  * mapped
:::

Section 3 proves the stress–codimension inequality, and Theorem 1.2 is its
flag-free case:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * Def 3.1
  * Collinearity flag $`d_\gamma \subsetneq T_\gamma \subsetneq Q_\gamma`
  * {bpref "collinearity_flag"}[`collinearity_flag`]
  * deviation
* * Def 3.2
  * Sparse collinearity-flag system
  * {bpref "flag_system"}[`flag_system`]
  * deviation
* * Prop 3.3
  * Incidence forest; $`\codim X_{\mathcal{T}} = 2|\Gamma|`
  * {bpref "flag_incidence_forest"}[`flag_incidence_forest`]
  * deviation
* * §3.2
  * Support multiplicity and the $`O`, $`P`, $`S` split
  * {bpref "support_multiplicity"}[`support_multiplicity`]
  * mapped
* * Lem 3.4
  * Flag selection lemma
  * {bpref "flag_selection"}[`flag_selection`]
  * mapped
* * Lem 3.5
  * Completion-preserving pivot
  * {bpref "missing_edge_pivot"}[`missing_edge_pivot`]
  * mapped
* * Lem 3.6
  * Local classification at a private support vertex
  * {bpref "private_local_classification"}[`private_local_classification`]
  * mapped
* * Lem 3.7
  * Addable edge or complete triangle outside the flags
  * {bpref "outside_augmentation"}[`outside_augmentation`]
  * mapped
* * Lem 3.8
  * Certified response edge, private-support case
  * {bpref "private_augmentation"}[`private_augmentation`]
  * mapped
* * Thm 3.9
  * Stress–codimension inequality for collinearity flags
  * {bpref "stress_codim_flags"}[`stress_codim_flags`]
  * mapped
* * Thm 1.2
  * Stress–codimension inequality ($`\Gamma = \emptyset`)
  * {bpref "stress_codim"}[`stress_codim`]
  * deviation
:::

Section 4 recasts the inequality geometrically, and only its grounded model
enters the formal argument:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * §4, (4.7)
  * Grounded model and the grounded inequality
  * {bpref "grounded_model"}[`grounded_model`]
  * mapped
* * (4.2)-(4.3)
  * Direction complex; $`\Sigma_s(F)` as determinantal loci
  * {bpref "direction_complex"}[`direction_complex`]
  * informal
* * Ex 4.1
  * The collinear triangle
  * none
  * informal
* * Thm 4.2
  * $`\codim \Sigma_s \ge s`; $`N_F` a local complete intersection, Cohen–Macaulay, pure
  * {bpref "stress_strata_codimension"}[`stress_strata_codimension`]
  * informal
* * Rem 4.3
  * Flag conditions against exact stress strata
  * none
  * informal
:::

Section 5 converts the inequality into a height theorem, stated in Section 1
as Theorem 1.3:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * (5.1)
  * Split–Klein quadratic form and twists
  * {bpref "split_klein_form"}[`split_klein_form`]
  * mapped
* * (5.2)
  * The ideal $`I_F` and the distinct locus
  * {bpref "isotropic_difference_ideal"}[`isotropic_difference_ideal`]
  * deviation
* * Lem 5.1
  * Componentwise Witt shear
  * {bpref "witt_shear_componentwise"}[`witt_shear_componentwise`]
  * mapped
* * Ex 5.2
  * A shear separating coincident coordinates
  * none
  * informal
* * Lem 5.3
  * $`\operatorname{ht} P + \trdeg = N` for a polynomial ring
  * {bpref "polynomial_dimension_formula"}[`polynomial_dimension_formula`]
  * mapped
* * Thm 1.3
  * Height of the distinct isotropic-difference ideal
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
  * deviation
* * Cor 5.4
  * The ungrounded isotropic-difference variety
  * {bpref "ungrounded_variety"}[`ungrounded_variety`]
  * deviation
:::

Section 6 returns to body–pin graphs and assembles both directions of the
theorem:

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * §6.1
  * Rigid-body twists and the pin compatibility equation
  * {bpref "twist_system"}[`twist_system`]
  * mapped
* * Lem 6.1
  * Twist description of motions within a body
  * {bpref "twist_description"}[`twist_description`]
  * mapped
* * Lem 6.2
  * The fibre of a pin; three pins imply collinear points
  * {bpref "pin_fibre"}[`pin_fibre`]
  * mapped
* * §6.1
  * The twist-equality partition
  * {bpref "twist_equality_partition"}[`twist_equality_partition`]
  * mapped
* * Lem 6.3
  * Selecting a $`(2,2)`-sparse subgraph via matroid union
  * {bpref "sparse_subgraph_selection"}[`sparse_subgraph_selection`]
  * deviation
* * Lem 6.4
  * Dimension drop along free $`\mathbb{G}_m` orbits
  * {bpref "orbit_dimension_drop"}[`orbit_dimension_drop`]
  * deviation
* * Prop 6.5
  * Exceptional parameter image is a proper closed subset
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
  * mapped
* * §6.4
  * Necessity
  * {bpref "necessity"}[`necessity`]
  * mapped
* * §6.4
  * Sufficiency and final assembly
  * {bpref "sufficiency_assembly"}[`sufficiency_assembly`]
  * deviation
:::

The remaining eight rows have no paper locus at all: they are the Lean-only
infrastructure clusters, named after the proof step each serves.

:::table +header
* * Paper
  * Result
  * Node
  * Status
* * —
  * Construction theorem for $`(2,2)`-tight graphs
  * {bpref "lean_nixon_owen_reduction"}[`lean_nixon_owen_reduction`]
  * lean-only
* * —
  * Transport of sparsity along an injective vertex map
  * {bpref "lean_sparsity_transport"}[`lean_sparsity_transport`]
  * lean-only
* * —
  * Provenance weight and initial-ideal apparatus
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
  * lean-only
* * —
  * Universal and provenance chart layer
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
  * lean-only
* * —
  * Flag state transitions and budget ledger
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
  * lean-only
* * —
  * Base-change and field-tower plumbing
  * {bpref "lean_base_change"}[`lean_base_change`]
  * lean-only
* * —
  * Grouped cross-block bundle operator
  * {bpref "lean_block_bundle_operator"}[`lean_block_bundle_operator`]
  * lean-only
* * —
  * Genericity machinery for the necessity direction
  * {bpref "lean_genericity"}[`lean_genericity`]
  * lean-only
:::

# Glossary

The paper and the Lean development do not share names, and several of the
paper's own terms are coinages that occur nowhere in its four background
references. Each term below is glossed at first use in the chapter that
introduces it; this table collects them. The Lean names behind each term are
on the linked node, whose panel carries their signatures and source links.

:::table +header
* * Term
  * Introduced at
  * Meaning
* * provenance flag
  * {bpref "collinearity_flag"}[the flags chapter]
  * the formalization's name for the paper's _collinearity flag_: a support
    triple with a distinguished missing edge and an auxiliary vertex
* * terminals
  * {bpref "collinearity_flag"}[the flags chapter]
  * the support triple $`T_\gamma` of a flag
* * missing terminal edge
  * {bpref "collinearity_flag"}[the flags chapter]
  * the distinguished missing edge $`d_\gamma`
* * ghost vertex
  * {bpref "collinearity_flag"}[the flags chapter]
  * the auxiliary vertex $`g_\gamma`; in the formalization it is the flag
    index itself, the right summand of $`V \oplus \Gamma`
* * live vertices, live edges
  * {bpref "collinearity_flag"}[the flags chapter]
  * the vertices and edges of the base graph, as opposed to the ghost
    vertices and the completion edges
* * completion
  * {bpref "flag_system"}[the flags chapter]
  * the simultaneous completion $`\widehat{G}`: every missing terminal edge
    restored and every auxiliary star attached
* * outside, private, shared vertices
  * {bpref "support_multiplicity"}[the flags chapter]
  * the partition of the live vertices by support multiplicity: outside
    ($`h_x = 0`), private ($`h_x = 1`), shared ($`h_x \ge 2`); the paper's
    sets $`O`, $`P`, $`S`
* * payment, payment failure
  * {bpref "deletion_ledger"}[the deletion chapter]
  * the local bound $`u + \delta_v \le 3`, or $`\le 1` at a private support
    vertex, under which one deletion step does not increase the defect; the
    exceptional collinear case is its failure
* * semismallness budget
  * {bpref "stress_codim_flags"}[the flags chapter]
  * the subtraction-free form $`s + \trdeg_k K + 2|\Gamma| \le 3|V|` of the
    paper's defect inequality $`\Delta \le 0`
* * virtual response edge
  * {bpref "certified_response_edge"}[the deletion chapter]
  * an absent edge whose direction row already lies in the row space; the
    paper's _certified response edge_, without the sparsity clause
* * direction rows, direction stress
  * {bpref "rigidity_row"}[the deletion chapter]
  * the field-extension form (1.4) of the rigidity matrix, and its
    self-stress space over the coefficient field
* * grounded
  * {bpref "grounded_model"}[the strata chapter]
  * a root vertex fixed at the origin, removing the translations and nothing
    else; the paper's coinage, and not the _pinned framework_ of
    {Informal.citet "kiralyTanigawa2019"}[], which fixes points completely
* * twist
  * {bpref "twist_system"}[the necessity chapter]
  * an element of $`k^3 \oplus k^3`, angular and linear part, describing the
    infinitesimal motion of one rigid body; (5.1) puts the Split–Klein form
    on it
* * null cellule
  * {bpref "isotropic_difference_ideal"}[the Split–Klein chapter]
  * the module family's name for the pair of conditions on a twist
    assignment: pairwise distinct, and null on every selected edge; not
    checked against a primary source
* * Nixon–Owen reduction
  * {bpref "lean_nixon_owen_reduction"}[the sparsity chapter]
  * the construction moves for $`(2,2)`-tight graphs; the module's own name,
    cited nowhere in the paper and not checked against a primary source
:::

Two conventions of the development are worth stating once. Every declaration
lives under the namespace root `RB31E2E`, and every module under the library
root `RB31EndToEnd/`; the reverse index below is organized by that module
tree. And the paper's flags, graphs and fields appear in Lean with exact
types rather than as subsets of a fixed universe: deletion and flag
registration change the vertex type, and sparsity is transported along the
inclusion at every step.

# Deviations register

Where a mapped result is proved or represented by a different route, the
divergence is recorded in a register, `lt-source-deviations.toml`, whose
entries are fingerprinted against the witness they excuse: re-transcribing a
witness expires its entries, so the register cannot silently outlive the
text it reviews. The register holds twenty-one entries. Each row below
compresses one entry to a sentence; the chapter name links to the node whose
witness the entry excuses, where both sides are stated in full.

:::table +header
* * Paper
  * Chapter
  * The difference
* * §1, A.1
  * {bpref "bodypin_incidence"}[Statement]
  * Pins are occurrences with two endpoint maps, so parallel pins stay
    distinct, and partitions are surjections onto $`[t]`
* * (1.2)
  * {bpref "partition_condition"}[Statement]
  * A second, ordered capacity convention with bound $`12(t-1)` is defined
    alongside the paper's unordered one and never used in the main theorem
* * §1 (Asimow-Roth)
  * {bpref "asimow_roth"}[Statement]
  * The Lean theorem is the maximum-rank form throughout; the step to
    generic rigidity in the usual sense is a literature citation
* * §6.4 (necessity)
  * {bpref "necessity"}[Necessity]
  * Proved directly rather than by contraposition: no flex is constructed,
    and grounding fixes one block's twist to zero
* * §2.1 (addable-edge criterion)
  * {bpref "addable_edge_criterion"}[Sparsity]
  * Proved from the induced-edge count alone; supermodularity is never
    invoked
* * Lem 2.1, 3.7, 3.8
  * {bpref "addable_edge_triple"}[Sparsity]
  * A 2,811-line construction theorem for $`(2,2)`-tight graphs sits beside
    them with no paper counterpart, and is not what they rest on
* * (2.1)-(2.3)
  * {bpref "stress_exact_sequence"}[Deletion]
  * Exactness of (2.3) is never asserted; the block-kernel dimension formula
    is proved directly and gives $`s = t + u`
* * (2.4)-(2.6)
  * {bpref "deletion_ledger"}[Deletion]
  * The defect $`\Delta` is not a named quantity anywhere; the inequality
    $`\Delta \le 0` appears only as the flagged semismallness budget
* * §2.2 (certified response edge)
  * {bpref "certified_response_edge"}[Deletion]
  * The augmentation lemma asks only that the edge be absent and its row in
    the row space; sparsity of $`H + xy` is a hypothesis of each use,
    discharged there by the addable-edge lemma
* * Def 3.1
  * {bpref "collinearity_flag"}[Flags]
  * Renamed throughout; no standalone one-flag object, and the ghost vertex
    is the flag index itself
* * Def 3.2
  * {bpref "flag_system"}[Flags]
  * Exact types for live vertices and active flags; the completion is an
    edge set on $`V \oplus \Gamma`, and the variety $`X_{\mathcal{T}}` has
    no counterpart
* * Prop 3.3
  * {bpref "flag_incidence_forest"}[Flags]
  * Counting halves only: the incidence graph $`B_{\mathcal{T}}` is never
    constructed, and the geometric half has no counterpart
* * Thm 1.2
  * {bpref "stress_codim"}[Flags]
  * Never stated standalone; the sole self-stress hypothesis of the assembly
    theorem is a grounded form over $`\Q`, derived by adjoining three
    translation variables
* * Prop 3.3, Prop 6.5
  * {bpref "flag_incidence_forest"}[Flags]
  * A rendering convention: the release line has no proposition directive,
    so the paper's propositions render as lemmas with the word Proposition
    in the title
* * §4, Thm 4.2
  * {bpref "stress_strata_codimension"}[Strata]
  * Expository: the scheme statements have no Lean counterpart, and
    Theorem 1.1 does not depend on them
* * (1.6)/(5.2)
  * {bpref "isotropic_difference_ideal"}[Split–Klein]
  * Two builds of $`I_F`; the load-bearing one is grounded, over $`\Q`,
    indexed by selected pin occurrences, with the distinct locus as a
    denominator
* * Thm 1.3
  * {bpref "isotropic_ideal_height"}[Split–Klein]
  * Lower bound only: every reachable statement is $`|E_F| \le
    \operatorname{ht} P`, and the Krull half of the equality is not
    formalized
* * Cor 5.4
  * {bpref "ungrounded_variety"}[Split–Klein]
  * Neither the ungrounded variety nor the product decomposition has a
    counterpart; the formalization is grounded from the ring onward
* * Lem 6.3
  * {bpref "sparse_subgraph_selection"}[Body–pin]
  * No matroid API: the sparse subgraph comes from a maximum sparse subset
    and the tight-hull partition, with only the constructive half of the
    min-max load bearing
* * Lem 6.4
  * {bpref "orbit_dimension_drop"}[Body–pin]
  * No statement of the lemma's shape exists; a homogeneous prime avoiding a
    positive-degree denominator drops height, which replaces the orbit
    argument
* * §6.4 (sufficiency)
  * {bpref "sufficiency_assembly"}[Body–pin]
  * No complex-to-real specialization occurs: the certificates are integer
    polynomials from the start, and the compatibility-matrix minor $`f` has
    no counterpart
:::

# Trust boundary

%%%
tag := "trust-boundary"
%%%

Appendix A.2 of {Informal.citet "zheng2026"}[] states the scope of the
verification, and every clause of it is checkable against the pinned
repository. The appendix is running prose — it numbers no result — so this
section quotes it verbatim rather than restating it as a formal environment,
and then says what stands outside it. The paper's words, from the paragraphs
titled _Scope and logical foundations of the verification_
{Informal.citep "zheng2026" (kind := "section") (index := "A.2")}[]:

> The formal verification is end-to-end. Theorem A.1 is universally
  quantified over $`H` and $`r` and derives both directions of the
  equivalence. The development includes proofs of the stress–codimension
  inequality for collinearity flags, the minimal-prime height theorem for
  the Split–Klein isotropic-difference ideal, and the exclusion of
  exceptional pin parameters; none is assumed by Theorem A.1.

  The project introduces no custom mathematical axioms. It does not use
  `sorry`, `admit`, explicit opaque declarations, or an external oracle in
  place of any mathematical argument. Nor do the structure fields of the
  flag states or function-field branches contain the stress–codimension or
  height conclusions to be proved. The project theorems and the mathlib
  theorems they invoke are all checked by the Lean kernel.

  The foundational axiom dependencies of the final theorem are exactly
  `propext`, `Classical.choice`, `Quot.sound`. These are, respectively,
  propositional extensionality, classical choice, and the compatibility
  principle for quotient types. Here “unconditional” means that Theorem A.1
  is a closed proposition: $`H` and $`r` are bound by universal quantifiers,
  and no additional mathematical hypotheses or project-specific axioms
  occur. The verification uses Lean 4.29.0; the corresponding mathlib commit
  is `8a178386ffc0f5fef0b77738bb5449d50efeea95`. The accompanying toolchain
  file and dependency manifest pin these two versions.

The quotation reflows the appendix's two displayed lines — the three axiom
names and the mathlib commit — into the sentences that introduce them, and
changes nothing else.

The three axioms are the ones nearly all of mathlib depends on:
propositional extensionality, classical choice, and quotient soundness. The
formalization repository checks the closure itself, in a test module that
runs `#print axioms` on the root theorem, and this blueprint's build resolves
every declaration it names against that same pinned commit.

Three things stand outside the kernel check. The step from attained maximum
rank to generic rigidity in the usual sense is
{bpref "asimow_roth"}[the Asimow–Roth citation], the one mathematical gap,
so what is verified end to end is Theorem A.1 rather than Theorem 1.1.
Whether the formal statement says what the paper's theorem says is a reading
question no kernel can settle;
{bpref "formal_statement"}[the statement chapter] exists so that a reader
can settle it, definition by definition. And the check itself trusts the
Lean kernel and the toolchain it runs on, a trust base the verification
shares with every Lean development at these versions.

# Reverse index

The index below asks the coverage question in the opposite direction: not
which Lean declarations correspond to a paper result, but which node
accounts for each module of the pinned formalization. The development has 126
modules, the root module and 125 under seven directories, and every one
appears exactly once below, with the entries of the correspondence table
that name it; each module name links to its source at the pinned commit.
Modules marked †, and shown muted, contribute nothing to the root theorem:
the kernel-level dependency walk described at the end of this section reaches
none of their declarations. A module marked _(none)_ is named by no entry —
both such modules are also unreachable, and each is superseded by a module
the proof does use. A cluster node is later split by promoting rows of this
index to nodes of their own.

The root modules state the theorem:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd.lean)
  * {bpref "formal_statement"}[`formal_statement`]
* * [`RB31EndToEnd.Specification`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Specification.lean)
  * {bpref "bodypin_incidence"}[`bodypin_incidence`], {bpref "pin_capacity"}[`pin_capacity`], {bpref "partition_condition"}[`partition_condition`], {bpref "formal_statement"}[`formal_statement`]
* * [`RB31EndToEnd.Target`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Target.lean)
  * {bpref "formal_statement"}[`formal_statement`]
* * [`RB31EndToEnd.TargetReduction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/TargetReduction.lean)
  * no node; a one-declaration reduction recorded with the root theorem
:::

`Algebra/` holds the commutative algebra:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Algebra.AffineSpanDescent`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/AffineSpanDescent.lean)
  * {bpref "affine_coefficient_descent"}[`affine_coefficient_descent`]
* * [`RB31EndToEnd.Algebra.AlgebraicIndependentAffine`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/AlgebraicIndependentAffine.lean)
  * {bpref "affine_coefficient_descent"}[`affine_coefficient_descent`]
* * [`RB31EndToEnd.Algebra.CoefficientLinearFibre`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/CoefficientLinearFibre.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.ComplexRealSpecialization`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/ComplexRealSpecialization.lean)
  * {bpref "sufficiency_assembly"}[`sufficiency_assembly`]
* * [`RB31EndToEnd.Algebra.CoordinateFieldTower`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/CoordinateFieldTower.lean)
  * {bpref "retained_coordinate_field"}[`retained_coordinate_field`], {bpref "deletion_ledger"}[`deletion_ledger`], {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.FilteredInitialHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/FilteredInitialHeight.lean)
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
* * [`RB31EndToEnd.Algebra.FiniteChartCertificates`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/FiniteChartCertificates.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.FiniteCoordinateTrdeg`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/FiniteCoordinateTrdeg.lean)
  * {bpref "polynomial_dimension_formula"}[`polynomial_dimension_formula`]
* * [`RB31EndToEnd.Algebra.FiniteOpenIntersection`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/FiniteOpenIntersection.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.FractionQuotientCoordinates`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/FractionQuotientCoordinates.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.GroundedTwist`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/GroundedTwist.lean)
  * {bpref "grounded_model"}[`grounded_model`], {bpref "lean_block_bundle_operator"}[`lean_block_bundle_operator`]
* * [`RB31EndToEnd.Algebra.GroundedTwistPolynomial`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/GroundedTwistPolynomial.lean)
  * {bpref "isotropic_difference_ideal"}[`isotropic_difference_ideal`]
* * [`RB31EndToEnd.Algebra.HomogeneousChartContradiction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/HomogeneousChartContradiction.lean) †
  * {bpref "orbit_dimension_drop"}[`orbit_dimension_drop`]
* * [`RB31EndToEnd.Algebra.HomogeneousDenominatorContradiction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/HomogeneousDenominatorContradiction.lean)
  * {bpref "orbit_dimension_drop"}[`orbit_dimension_drop`]
* * [`RB31EndToEnd.Algebra.HomogeneousPrimeChartHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/HomogeneousPrimeChartHeight.lean)
  * {bpref "orbit_dimension_drop"}[`orbit_dimension_drop`]
* * [`RB31EndToEnd.Algebra.LinearFormIdeal`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/LinearFormIdeal.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.LinearFormIdealHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/LinearFormIdealHeight.lean)
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.Algebra.MinimalPrimeLinearFibre`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/MinimalPrimeLinearFibre.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Algebra.MinimalPrimeLinearFibreHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/MinimalPrimeLinearFibreHeight.lean)
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.Algebra.PolynomialPrimeTrdegHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/PolynomialPrimeTrdegHeight.lean)
  * {bpref "polynomial_dimension_formula"}[`polynomial_dimension_formula`]
* * [`RB31EndToEnd.Algebra.RationalCertificateDescent`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Algebra/RationalCertificateDescent.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
:::

`Combinatorics/` holds the sparsity theory and the flag states:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Combinatorics.BodyPinCapacity`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/BodyPinCapacity.lean) †
  * (none)
* * [`RB31EndToEnd.Combinatorics.BodyPinFinpartition`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/BodyPinFinpartition.lean)
  * {bpref "twist_equality_partition"}[`twist_equality_partition`]
* * [`RB31EndToEnd.Combinatorics.BodyPinSparseSkeleton`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/BodyPinSparseSkeleton.lean)
  * {bpref "sparse_subgraph_selection"}[`sparse_subgraph_selection`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlag`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlag.lean)
  * {bpref "collinearity_flag"}[`collinearity_flag`], {bpref "flag_system"}[`flag_system`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagArithmetic`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagArithmetic.lean)
  * {bpref "flag_selection"}[`flag_selection`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagDeletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagDeletion.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagForest`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagForest.lean)
  * {bpref "flag_incidence_forest"}[`flag_incidence_forest`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagInsertion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagInsertion.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagOutsideMove`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagOutsideMove.lean)
  * {bpref "outside_augmentation"}[`outside_augmentation`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagOutsideRegistration`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagOutsideRegistration.lean)
  * {bpref "outside_augmentation"}[`outside_augmentation`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagPrivateDeletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagPrivateDeletion.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagPrivateMove`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagPrivateMove.lean)
  * {bpref "private_augmentation"}[`private_augmentation`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagPrivatePivot`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagPrivatePivot.lean)
  * {bpref "missing_edge_pivot"}[`missing_edge_pivot`]
* * [`RB31EndToEnd.Combinatorics.ProvenanceFlagSelection`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/ProvenanceFlagSelection.lean)
  * {bpref "support_multiplicity"}[`support_multiplicity`], {bpref "flag_selection"}[`flag_selection`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.Basic`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/Basic.lean)
  * {bpref "sparse22"}[`sparse22`], {bpref "addable_edge_criterion"}[`addable_edge_criterion`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.Construction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/Construction.lean)
  * {bpref "lean_nixon_owen_reduction"}[`lean_nixon_owen_reduction`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.DegreeThreeAugmentation`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/DegreeThreeAugmentation.lean)
  * {bpref "addable_edge_triple"}[`addable_edge_triple`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.GraphExtension`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/GraphExtension.lean)
  * {bpref "lean_nixon_owen_reduction"}[`lean_nixon_owen_reduction`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.OptimalPartition`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/OptimalPartition.lean)
  * {bpref "sparse_subgraph_selection"}[`sparse_subgraph_selection`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.TightCompletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/TightCompletion.lean)
  * {bpref "lean_nixon_owen_reduction"}[`lean_nixon_owen_reduction`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.Transport`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/Transport.lean)
  * {bpref "lean_sparsity_transport"}[`lean_sparsity_transport`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.TriangleSequence`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/TriangleSequence.lean)
  * {bpref "lean_nixon_owen_reduction"}[`lean_nixon_owen_reduction`]
* * [`RB31EndToEnd.Combinatorics.Sparse22.Uncrossing`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Combinatorics/Sparse22/Uncrossing.lean)
  * {bpref "uncrossing"}[`uncrossing`]
:::

`Graph/` holds one module:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Graph.LooplessMultiGraph`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Graph/LooplessMultiGraph.lean) †
  * (none)
:::

`Incidence/` holds the chart layer under Proposition 6.5:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Incidence.ActivePinPrimeHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/ActivePinPrimeHeight.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.Arithmetic`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/Arithmetic.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.CollinearityPolynomial`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/CollinearityPolynomial.lean)
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
* * [`RB31EndToEnd.Incidence.DistinctProvenanceChart`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/DistinctProvenanceChart.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.EqualityPartition`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/EqualityPartition.lean)
  * {bpref "twist_equality_partition"}[`twist_equality_partition`]
* * [`RB31EndToEnd.Incidence.FiniteBadCover`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/FiniteBadCover.lean)
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
* * [`RB31EndToEnd.Incidence.FiniteFullProvenancePropernessAssembly`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/FiniteFullProvenancePropernessAssembly.lean)
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
* * [`RB31EndToEnd.Incidence.FullProvenanceChart`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/FullProvenanceChart.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.PinOuterActiveHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/PinOuterActiveHeight.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.PinOuterFullProvenanceHeightTransfer`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/PinOuterFullProvenanceHeightTransfer.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.PinTriangularElimination`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/PinTriangularElimination.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.SkeletonOccurrenceSelection`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/SkeletonOccurrenceSelection.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.SmallBundleCertificate`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/SmallBundleCertificate.lean)
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
* * [`RB31EndToEnd.Incidence.TotalRingProvenanceSwap`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/TotalRingProvenanceSwap.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.TripleBundleCertificate`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/TripleBundleCertificate.lean)
  * {bpref "exceptional_pin_parameters"}[`exceptional_pin_parameters`]
* * [`RB31EndToEnd.Incidence.UniversalActivePinHeightTransfer`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalActivePinHeightTransfer.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalChartContraction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalChartContraction.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalChartHeightElimination`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalChartHeightElimination.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalChartIdeal`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalChartIdeal.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalDistinctChartContraction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalDistinctChartContraction.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalFullProvenanceChartContraction`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalFullProvenanceChartContraction.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
* * [`RB31EndToEnd.Incidence.UniversalHomogeneousChart`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Incidence/UniversalHomogeneousChart.lean)
  * {bpref "lean_chart_layer"}[`lean_chart_layer`]
:::

`Linear/` holds the direction-stress theory of the deletion step:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Linear.BlockKernelExact`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/BlockKernelExact.lean)
  * {bpref "stress_exact_sequence"}[`stress_exact_sequence`]
* * [`RB31EndToEnd.Linear.DirectionResponse`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionResponse.lean)
  * {bpref "certified_response_edge"}[`certified_response_edge`]
* * [`RB31EndToEnd.Linear.DirectionResponseBaseChange`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionResponseBaseChange.lean)
  * {bpref "certified_response_edge"}[`certified_response_edge`]
* * [`RB31EndToEnd.Linear.DirectionResponseVertexDeletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionResponseVertexDeletion.lean)
  * {bpref "certified_response_edge"}[`certified_response_edge`]
* * [`RB31EndToEnd.Linear.DirectionStress`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionStress.lean)
  * {bpref "rigidity_row"}[`rigidity_row`], {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.DirectionStressBaseChange`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionStressBaseChange.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.DirectionStressDeletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionStressDeletion.lean)
  * {bpref "stress_exact_sequence"}[`stress_exact_sequence`]
* * [`RB31EndToEnd.Linear.DirectionStressVertexDeletion`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/DirectionStressVertexDeletion.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.FiniteFamilyBaseChange`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/FiniteFamilyBaseChange.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.FiniteRowSpanStress`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/FiniteRowSpanStress.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.FiniteRowSystem`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/FiniteRowSystem.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.GroundedDirectionConstraint`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/GroundedDirectionConstraint.lean)
  * {bpref "grounded_model"}[`grounded_model`]
* * [`RB31EndToEnd.Linear.OutsideExceptionalFullResponse`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/OutsideExceptionalFullResponse.lean)
  * {bpref "neighbour_rigidity_rows"}[`neighbour_rigidity_rows`]
* * [`RB31EndToEnd.Linear.OutsideLocalClassification`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/OutsideLocalClassification.lean)
  * {bpref "low_degree_classification"}[`low_degree_classification`]
* * [`RB31EndToEnd.Linear.OutsideLocalGeometry`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/OutsideLocalGeometry.lean)
  * {bpref "low_degree_classification"}[`low_degree_classification`]
* * [`RB31EndToEnd.Linear.OutsideLocalPayment`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/OutsideLocalPayment.lean)
  * {bpref "retained_coordinate_field"}[`retained_coordinate_field`], {bpref "deletion_ledger"}[`deletion_ledger`]
* * [`RB31EndToEnd.Linear.OutsideRegistrationStress`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/OutsideRegistrationStress.lean)
  * {bpref "lean_base_change"}[`lean_base_change`]
* * [`RB31EndToEnd.Linear.PinFibres`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/PinFibres.lean)
  * {bpref "pin_fibre"}[`pin_fibre`]
* * [`RB31EndToEnd.Linear.PinRank`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/PinRank.lean)
  * {bpref "necessity"}[`necessity`]
* * [`RB31EndToEnd.Linear.PrivateLocalClassification`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/PrivateLocalClassification.lean)
  * {bpref "private_local_classification"}[`private_local_classification`]
* * [`RB31EndToEnd.Linear.PrivatePivotStress`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/PrivatePivotStress.lean)
  * {bpref "missing_edge_pivot"}[`missing_edge_pivot`]
* * [`RB31EndToEnd.Linear.TwistSystem`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/TwistSystem.lean)
  * {bpref "twist_system"}[`twist_system`], {bpref "twist_description"}[`twist_description`]
* * [`RB31EndToEnd.Linear.Vec3Twist`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Linear/Vec3Twist.lean)
  * {bpref "split_klein_form"}[`split_klein_form`], {bpref "twist_system"}[`twist_system`]
:::

`NullCellule/` holds the semismallness induction and the height theorem:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.NullCellule.Definitions`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/Definitions.lean) †
  * {bpref "isotropic_difference_ideal"}[`isotropic_difference_ideal`]
* * [`RB31EndToEnd.NullCellule.GroundScale`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/GroundScale.lean) †
  * {bpref "orbit_dimension_drop"}[`orbit_dimension_drop`]
* * [`RB31EndToEnd.NullCellule.GroundedPFEndToEnd`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/GroundedPFEndToEnd.lean)
  * {bpref "stress_codim"}[`stress_codim`], {bpref "sufficiency_assembly"}[`sufficiency_assembly`]
* * [`RB31EndToEnd.NullCellule.GroundedTwistSplit`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/GroundedTwistSplit.lean)
  * {bpref "grounded_model"}[`grounded_model`]
* * [`RB31EndToEnd.NullCellule.PolynomialModel`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/PolynomialModel.lean) †
  * {bpref "isotropic_difference_ideal"}[`isotropic_difference_ideal`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagBranch`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagBranch.lean)
  * {bpref "stress_codim_flags"}[`stress_codim_flags`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagDeletionLedger`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagDeletionLedger.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagGroundedPF`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagGroundedPF.lean)
  * {bpref "stress_codim"}[`stress_codim`], {bpref "sufficiency_assembly"}[`sufficiency_assembly`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagInsertedBranch`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagInsertedBranch.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagOutsideExceptional`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagOutsideExceptional.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagOutsideExceptionalBudget`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagOutsideExceptionalBudget.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagOutsideRegisteredBranch`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagOutsideRegisteredBranch.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagPlacement`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagPlacement.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagPrivateExceptional`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagPrivateExceptional.lean)
  * {bpref "lean_flag_moves"}[`lean_flag_moves`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagSemismallness`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagSemismallness.lean)
  * {bpref "stress_codim_flags"}[`stress_codim_flags`]
* * [`RB31EndToEnd.NullCellule.ProvenanceFlagSemismallnessFinal`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ProvenanceFlagSemismallnessFinal.lean)
  * {bpref "stress_codim_flags"}[`stress_codim_flags`]
* * [`RB31EndToEnd.NullCellule.ReplacementIdentities`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/ReplacementIdentities.lean) †
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
* * [`RB31EndToEnd.NullCellule.SelectedDirectionFibre`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/SelectedDirectionFibre.lean)
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.NullCellule.SelectedDirectionHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/SelectedDirectionHeight.lean)
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.NullCellule.SelectedNullHeight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/SelectedNullHeight.lean)
  * {bpref "isotropic_difference_ideal"}[`isotropic_difference_ideal`], {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.NullCellule.SelectedNullHeightPrimewise`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/SelectedNullHeightPrimewise.lean)
  * {bpref "isotropic_ideal_height"}[`isotropic_ideal_height`]
* * [`RB31EndToEnd.NullCellule.VertexK4Weight`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/VertexK4Weight.lean) †
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
* * [`RB31EndToEnd.NullCellule.WeightComponents`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/WeightComponents.lean) †
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
* * [`RB31EndToEnd.NullCellule.WeightInitialIdeal`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/WeightInitialIdeal.lean) †
  * {bpref "lean_weight_apparatus"}[`lean_weight_apparatus`]
* * [`RB31EndToEnd.NullCellule.WittShear`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/WittShear.lean)
  * {bpref "witt_shear_componentwise"}[`witt_shear_componentwise`]
* * [`RB31EndToEnd.NullCellule.WittShearDistinctPrime`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/NullCellule/WittShearDistinctPrime.lean)
  * {bpref "witt_shear_componentwise"}[`witt_shear_componentwise`]
:::

`Rigidity/` holds the real bar–joint model and the two ends of the argument:

:::table +header
* * Module
  * Node
* * [`RB31EndToEnd.Rigidity.BarJoint`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/BarJoint.lean)
  * {bpref "rigidity_matrix"}[`rigidity_matrix`], {bpref "generic_rigidity_max_rank"}[`generic_rigidity_max_rank`]
* * [`RB31EndToEnd.Rigidity.BodyPinGraph`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/BodyPinGraph.lean)
  * {bpref "bodypin_expansion"}[`bodypin_expansion`]
* * [`RB31EndToEnd.Rigidity.BodyTwistBridge`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/BodyTwistBridge.lean)
  * {bpref "twist_description"}[`twist_description`]
* * [`RB31EndToEnd.Rigidity.BodyTwistGenericBridge`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/BodyTwistGenericBridge.lean)
  * {bpref "sufficiency_assembly"}[`sufficiency_assembly`], {bpref "lean_genericity"}[`lean_genericity`]
* * [`RB31EndToEnd.Rigidity.GraphNecessity`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/GraphNecessity.lean)
  * {bpref "necessity"}[`necessity`], {bpref "lean_genericity"}[`lean_genericity`]
* * [`RB31EndToEnd.Rigidity.TwistNecessity`](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture/blob/afdfb9fc8f28abc4feb5dcee31ae04082922ceb7/RB31EndToEnd/Rigidity/TwistNecessity.lean)
  * {bpref "necessity"}[`necessity`], {bpref "lean_block_bundle_operator"}[`lean_block_bundle_operator`]
:::

The daggers come from a measurement rather than a reading. The walk is a
short metaprogram,
[`scripts/reachable.lean`](https://github.com/bryangingechen/zheng-body-pin-blueprint/blob/main/scripts/reachable.lean)
in this blueprint's repository: it takes the root theorem's constant in the
kernel environment and closes over every constant appearing in the type or
the value — proof terms included — of each declaration it meets, then
reports, per module of the formalization, which declarations were reached.
Rerunning it against the pinned submodule reproduces the numbers here, and
`scripts/coverage.py --reachable` checks every dagger in this index against
its output. The walk reaches 1,385 of the development's 2,555
declarations, and the ten daggered modules contribute none of theirs; every
module the walk does reach is named by some entry above, so nothing
load-bearing is unaccounted for. Of the four modules that develop
{bpref "lean_nixon_owen_reduction"}[the construction theorem of the sparsity
chapter], only a few counting facts are reachable: from `TightCompletion.lean`
one equation lemma for a definition made elsewhere; from
`TriangleSequence.lean` two declarations about the four-element vertex set of
a $`K_4`; from `GraphExtension.lean` eight facts about the edges one outside
vertex sends into a tight subgraph; and from `Construction.lean` its edge-set
vocabulary rather than its reduction theorems. The ten daggered modules
divide into two groups. Two are superseded and named by no entry: the
multigraph interface, whose conversion is never used, and the capacity
table, whose bounds the proof takes from `PinRank.lean` instead. The other
eight are documented as parallel developments by the
{bpref "isotropic_difference_ideal"}[Split–Klein] and
{bpref "orbit_dimension_drop"}[assembly] chapters: the literal build of the
ideal, the weight apparatus, and the two orbit modules.

# Reading the dependency graph

The graph page draws one node per labelled entry of the correspondence table
and one arrow per declared dependency, pointing from prerequisite to
dependent. Its edges are hand-declared at the granularity of nodes, so it is
coarser than the kernel-level walk above and reviewed rather than measured;
this section says what its edges and colours do and do not claim.

An edge records mathematical dependency as the formalization discharges it.
Where the paper's proof cites a result whose formal counterpart took a
different route, the edge points at the node carrying the formal content and
the paper's own citation stays a plain link in the proof text, with the
divergence in the register above. Two proofs in
{bpref "sufficiency_assembly"}[the body–pin chapter] do this. The proof of
Proposition 6.5 cites Corollary 5.4, whose ungrounded statement has no Lean
counterpart, so its edge lands on
{bpref "isotropic_ideal_height"}[the grounded height theorem] that the
corollary restates. And the paper closes Section 6.4 by invoking
Asimow–Roth to pass from attained maximum rank to generic rigidity in the
usual sense; that step belongs to
{bpref "bodypin_partition_characterization"}[Theorem 1.1], whose edge into
{bpref "asimow_roth"}[the Asimow–Roth citation] carries it, and not to the
assembly lemma, whose Lean form is the maximum-rank statement. The
dependencies declared by the eight `lean_`-prefixed infrastructure nodes
carry a technical intent, which keeps them apart from the paper's spine in
the node panels.

The colours come from upstream's coordination vocabulary, computed from the
Lean anchors rather than from anything this blueprint asserts. A node fills
dark, _locally formalized + dependencies complete_, exactly when its own
anchors and those of every node it transitively depends on resolve, proved,
in the pinned environment. Since the formalization is finished, the whole
spine from the root theorem down renders that way. The exceptions are
deliberate, the nodes with nothing to resolve: the
{bpref "direction_complex"}[strata chapter]'s scheme statements,
{bpref "ungrounded_variety"}[Corollary 5.4],
{bpref "asimow_roth"}[Asimow–Roth], and
{bpref "bodypin_partition_characterization"}[Theorem 1.1] itself, which
carries no anchor on purpose — the anchor belongs to the formal statement,
and the route between the two runs through the one acknowledged gap.

One label on those informal nodes should not be read at face value. A node
with no Lean code whose recorded prerequisites are all formalized is
labelled _ready to formalize_, a phrase from the upstream tool's
coordination vocabulary for formalizations still in progress. This one is
finished, and the label on {bpref "asimow_roth"}[the Asimow–Roth node] is
a statement about its recorded prerequisites alone, not about the real cost
of formalizing the differential-geometric theory behind it; the strata
nodes are {bpref "direction_complex"}[deliberately informal] whatever their
colour. Read _ready to formalize_ here as: informal, with formalized
prerequisites. The release line offers no per-node override for that label.
