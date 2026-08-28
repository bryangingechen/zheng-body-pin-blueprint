/-
Which of the formalization's declarations does the root theorem actually use?

Run with `lake env lean scripts/reachable.lean`; it writes `_out/reachable.json`.
Roughly three minutes, almost all of it loading oleans, so background it.

The blueprint claims that its nodes cover the development. Deciding whether a
module is load bearing by reading imports overstates the case -- a module can be
imported for one lemma, or for nothing at all -- so this walks the constant
dependencies of `RB31E2E.endToEndBodyPinStatement` in the kernel environment
instead, and reports, per module of the formalization, which declarations the
root theorem reaches.

`scripts/coverage.py --reachable` consumes the output.
-/
import RB31EndToEnd

open Lean

/-- Transitive closure of the constants appearing in a declaration's type and value. -/
partial def reachedFrom (env : Environment) (n : Name) (seen : NameSet) : NameSet :=
  if seen.contains n then seen
  else
    let seen := seen.insert n
    match env.find? n with
    | none => seen
    | some ci =>
      let used := ci.type.getUsedConstants ++
        (match ci.value? with | some v => v.getUsedConstants | none => #[])
      used.foldl (fun s c => reachedFrom env c s) seen

/-- Is this a module of the formalization rather than of Mathlib or core? -/
def isFormalizationModule (m : Name) : Bool :=
  m == `RB31EndToEnd || (`RB31EndToEnd).isPrefixOf m

def quote (s : String) : String := "\"" ++ s ++ "\""

#eval show CoreM Unit from do
  let env ← getEnv
  let root : Name := `RB31E2E.endToEndBodyPinStatement
  let reached := reachedFrom env root {}
  -- every declaration of the formalization, by module
  let mut declsOf : Std.HashMap Name (Array Name) := {}
  let mut reachedOf : Std.HashMap Name (Array Name) := {}
  for m in env.header.moduleNames do
    if isFormalizationModule m then
      declsOf := declsOf.insert m #[]
      reachedOf := reachedOf.insert m #[]
  for (n, _) in env.constants.map₁.toList do
    if n.isInternal then continue
    match env.getModuleIdxFor? n with
    | none => pure ()
    | some idx =>
      let m := env.header.moduleNames[idx.toNat]!
      if isFormalizationModule m then
        declsOf := declsOf.insert m ((declsOf.getD m #[]).push n)
        if reached.contains n then
          reachedOf := reachedOf.insert m ((reachedOf.getD m #[]).push n)
  let mods := (declsOf.toList.map Prod.fst).toArray.qsort (fun a b => a.toString < b.toString)
  let mut rows : Array String := #[]
  for m in mods do
    let all := (declsOf.getD m #[]).qsort (fun a b => a.toString < b.toString)
    let hit := (reachedOf.getD m #[]).qsort (fun a b => a.toString < b.toString)
    let names := String.intercalate ", " (hit.toList.map (fun n => quote n.toString))
    rows := rows.push <|
      "    " ++ quote m.toString ++ ": {\"declarations\": " ++ toString all.size ++
      ", \"reached\": " ++ toString hit.size ++ ", \"names\": [" ++ names ++ "]}"
  let totalReached := mods.foldl (fun acc m => acc + (reachedOf.getD m #[]).size) 0
  let totalDecls := mods.foldl (fun acc m => acc + (declsOf.getD m #[]).size) 0
  let json :=
    "{\n  " ++ quote "root" ++ ": " ++ quote root.toString ++ ",\n  " ++
    quote "constants_reached" ++ ": " ++ toString reached.size ++ ",\n  " ++
    quote "formalization_declarations" ++ ": " ++ toString totalDecls ++ ",\n  " ++
    quote "formalization_reached" ++ ": " ++ toString totalReached ++ ",\n  " ++
    quote "modules" ++ ": {\n" ++ String.intercalate ",\n" rows.toList ++ "\n  }\n}\n"
  IO.FS.createDirAll "_out"
  IO.FS.writeFile "_out/reachable.json" json
  IO.println s!"[reachable] {totalReached} of {totalDecls} formalization declarations \
reachable from {root}"
  IO.println s!"[reachable] wrote _out/reachable.json"
