import Lake
open Lake DSL

require RB31EndToEnd from "formalization"
require VersoBlueprint from git "https://github.com/leanprover/verso-blueprint.git" @ "v4.29.0"
-- `require mathlib` must come LAST so Mathlib's own dependency pins take
-- precedence over Verso's. Without this, Verso's `proofwidgets v0.0.92` wins
-- over Mathlib's `v0.0.95` and `lake exe cache get` computes wrong hashes and
-- refuses to fetch the Mathlib cache. The rev matches `formalization/`'s pin.
require mathlib from git "https://github.com/leanprover-community/mathlib4.git" @ "8a178386ffc0f5fef0b77738bb5449d50efeea95"

package BodyPinBlueprint where
  precompileModules := false
  leanOptions := #[
    ⟨`experimental.module, true⟩,
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩,
    ⟨`weak.verso.blueprint.math.lint, true⟩,
    ⟨`weak.verso.blueprint.externalCode.strictResolve, true⟩,
    ⟨`weak.verso.code.warnLineLength, .ofNat 0⟩
  ]

@[default_target]
lean_lib BodyPinBlueprint where

lean_exe «blueprint-gen» where
  root := `BlueprintMain
  supportInterpreter := true
