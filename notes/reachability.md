# What the root theorem actually uses

A record of one measurement and what it changed. Rerun it whenever the
submodule pin moves:

```bash
lake env lean scripts/reachable.lean     # ~3 min, writes _out/reachable.json
python3 scripts/coverage.py --reachable  # compares it against correspondence.toml
```

## Why

`correspondence.toml` gives each entry a `modules` inventory, and until now
those lists were assembled by reading imports and file names. That overstates
dependency in both directions. A module can be imported for one lemma, or for
nothing at all; and a module can be genuinely load bearing while its name says
nothing about which paper result it serves. Since coverage and correspondence
are what this repository delivers, the inventories need a check that does not
rely on reading.

## Method

`scripts/reachable.lean` imports `RB31EndToEnd`, takes the constant
`RB31E2E.endToEndBodyPinStatement` — the root theorem — and walks the constants
appearing in the type and value of each declaration it meets, transitively,
through the kernel environment. Proof terms are included, so a lemma used only
inside a proof is reached. It then reports, per module of the formalization,
how many of its declarations the walk reached.

Two things to know when reading the numbers. The denominators count everything
the module adds to the environment, so auto-generated equation lemmas,
`injEq` lemmas and recursors are in them; they are larger than the source-level
declaration counts in `notes/attribution.md`. And unreached does not mean
unused by anything: it means not used by the root theorem, which is the only
thing this blueprint claims about.

## Result, measured 2026-08-27 against submodule `afdfb9f`

The walk reaches 40,765 constants in all, of which 1,385 of the
formalization's 2,555 belong to `RB31EndToEnd`. Ten modules contribute nothing:

| Module | Declarations |
|---|---|
| `Algebra.HomogeneousChartContradiction` | 4 |
| `Combinatorics.BodyPinCapacity` | 10 |
| `Graph.LooplessMultiGraph` | 36 |
| `NullCellule.Definitions` | 11 |
| `NullCellule.GroundScale` | 8 |
| `NullCellule.PolynomialModel` | 33 |
| `NullCellule.ReplacementIdentities` | 13 |
| `NullCellule.VertexK4Weight` | 65 |
| `NullCellule.WeightComponents` | 18 |
| `NullCellule.WeightInitialIdeal` | 61 |

Four more are reached only marginally: `Sparse22.TightCompletion` 1 of 28,
`Incidence.Arithmetic` 1 of 27, `Algebra.ComplexRealSpecialization` 1 of 13,
`Sparse22.GraphExtension` 8 of 90.

## What it changed

*Two module lists in the statement chapter were wrong.* `bodypin_incidence`
named `Graph/LooplessMultiGraph.lean` and `pin_capacity` named
`Combinatorics/BodyPinCapacity.lean`; neither contributes anything.
`BodyPinIncidence` is a standalone structure and the conversion
`BodyPinIncidence.toLooplessMultiGraph` is never used; the capacity bounds the
proof actually uses are the rank bounds in `Linear/PinRank.lean`. Both entries
were corrected, and the chapter prose needed no change.

*The Nixon–Owen description was wrong.* The `lean_nixon_owen_reduction` entry
said its modules supported "the short uncrossing arguments of Lem 2.1, 3.7,
3.8". They do not. The reduction disjunction `HasNixonOwenReduction`, the
graph-extension quotient and the tight completion `exists_tight22_completion`
are all unreachable, and what the rest of the development takes from those four
modules is edge-set vocabulary from `Construction.lean` plus eight counting
facts from `GraphExtension.lean` and `TriangleSequence.lean`. Lemma 2.1's own
Lean proof is a tight-set obstruction argument that does not use them. The
sparsity chapter says so, and `lt-source-deviations.toml` has the entry.

## Resolved by Phase 4 (was: open, for the phases that reach them)

Seven of the ten unreached modules are in `NullCellule`, and Phase 4 settled
each one while writing chapters 06 to 08; `notes/questions.md` has the moved
inventories, `lt-source-deviations.toml` the registered routes. In summary:

- The four pure weight modules (`WeightInitialIdeal`, `WeightComponents`,
  `VertexK4Weight`, `ReplacementIdentities`) are a parallel development, told
  by the Split–Klein chapter's `lean_weight_apparatus` node: the keystone
  height comparison `WeightInitialHeightMonotone` is defined and never
  assumed or proved, because Mathlib lacks the flat weighted-Rees family.
- `Definitions` and `PolynomialModel` hold the *literal* build of the ideal
  $I_F$; the load-bearing build is `SelectedNullHeight`'s grounded,
  occurrence-indexed one. Both are named by `isotropic_difference_ideal`,
  which is now a registered deviation.
- `GroundScale` proves the point-set orbit freeness of Lemma 6.4 and defers
  the dimension conversion, which is never made; the load-bearing substitute
  is the homogeneous height drop in `HomogeneousDenominatorContradiction`.
  It moved from `ungrounded_variety` to `orbit_dimension_drop`, also now a
  registered deviation.
- Of the four marginal modules: `Sparse22.TightCompletion` and
  `Sparse22.GraphExtension` were already told by the sparsity chapter;
  `Incidence.Arithmetic` contributes exactly one declaration
  (`sparseNull_relativeHeight_budget`), said on `lean_chart_layer`; and
  `Algebra.ComplexRealSpecialization`'s one reachable declaration is
  `exists_real_eval_ne_zero` — no complex-to-real specialization occurs on
  the load-bearing route, which is a registered deviation on
  `sufficiency_assembly`.

Nothing is reachable and unclaimed: every module the root theorem reaches is
named by some entry.
