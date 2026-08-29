/-
Which formalization modules hold the declarations the blueprint's nodes name?

Run with `lake env lean scripts/body-modules.lean`; it writes
`_out/body-modules.json`. Roughly three minutes, almost all of it loading
oleans, so background it.

`scripts/extract-bodies.sh` consumes the output: for every module named here it
builds SubVerso's `highlighted` facet, which is what supplies a declaration's
body to the blueprint. Extracting all 125 modules `correspondence.toml` names
would cost about three hours; these are the ones a panel can actually use, and
there are far fewer of them.

The kind is reported too, because only a `def` or an `abbrev` has a body worth
showing. A theorem's value is its proof, and the panel already renders a
structure's fields.
-/
import RB31EndToEnd

open Lean

/-- The module a declaration was compiled from. -/
def moduleOf? (env : Environment) (decl : Name) : Option Name :=
  match env.getModuleIdxFor? decl with
  | some idx => env.header.moduleNames[idx.toNat]?
  | none => none

/-- `def`, `abbrev`, `theorem`, … as the blueprint would label it. -/
def kindOf (decl : Name) : CoreM String := do
  match (← getEnv).find? decl with
  | some (.thmInfo _) => return "theorem"
  | some (.axiomInfo _) => return "axiom"
  | some (.opaqueInfo _) => return "opaque"
  | some (.inductInfo _) => return "inductive"
  | some (.ctorInfo _) => return "constructor"
  | some (.defnInfo _) => return if ← isReducible decl then "abbrev" else "def"
  | _ => return "unknown"

#eval show CoreM Unit from do
  let env ← getEnv
  let names := (← IO.FS.readFile "_out/body-names.txt").splitOn "\n"
    |>.map (·.trimAscii.copy) |>.filter (!·.isEmpty) |>.map String.toName
  let mut entries : Array (String × String × String) := #[]
  let mut missing : Array Name := #[]
  for n in names do
    match moduleOf? env n with
    | none => missing := missing.push n
    | some m => entries := entries.push (n.toString, m.toString, ← kindOf n)
  let mods := entries.filterMap (fun (_, m, k) =>
    if k == "def" || k == "abbrev" then some m else none)
  let uniq := mods.foldl (fun (s : Array String) m =>
    if s.contains m then s else s.push m) #[]
  let json := Json.mkObj [
    ("declarations", Json.arr (entries.map fun (n, m, k) =>
      Json.mkObj [("name", .str n), ("module", .str m), ("kind", .str k)])),
    ("bodyModules", Json.arr (uniq.map .str)),
    ("missing", Json.arr (missing.map (Json.str ·.toString)))
  ]
  IO.FS.createDirAll "_out"
  IO.FS.writeFile "_out/body-modules.json" (json.pretty ++ "\n")
  IO.println s!"{entries.size} declarations, {uniq.size} modules with a body to extract, {missing.size} missing"
