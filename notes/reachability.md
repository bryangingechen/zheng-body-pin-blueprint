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

## Open, for the phases that reach them

Seven of the ten unreached modules are in `NullCellule`, and six of those are
the weight and initial-ideal apparatus that `lean_weight_apparatus` covers —
157 declarations reaching the root theorem not at all. `NullCellule.Definitions`
and `NullCellule.PolynomialModel` are named by `isotropic_difference_ideal`,
and `NullCellule.GroundScale` by `ungrounded_variety` and
`orbit_dimension_drop`. Those are Phase 4 chapters. `coverage.py --reachable`
prints all of them as warnings, and they should be resolved as those chapters
are written rather than now: either the module inventory is wrong, as it was
twice in the statement chapter, or there is a real story about a body of work
that the final assembly does not depend on, as there is for Nixon–Owen.

Nothing is reachable and unclaimed: every module the root theorem reaches is
named by some entry.
