/-
Links into the pinned formalization, built from `correspondence.toml`.

The chapters name a file of the formalization where the file's boundary is the
point -- which module proves which half, where a namespace and a file part
company -- and the audit chapter's reverse index links every module.  Writing
those links as literal URLs quotes the repository and the pinned rev at every
site, and a moved pin then means editing them all and trusting a checker to
find the ones missed.  The `srcFile` role below builds the URL instead, from
the single `[formalization]` table in `correspondence.toml` that
`scripts/coverage.py` already treats as the pin:

    {srcFile}`Construction.lean`                    a file, found by its name
    {srcFile}`RB31EndToEnd.Combinatorics.Sparse22.Basic`   a module, spelled out

Both render as the code span the source shows, linked to the file at the
pinned rev.  A file name that matches nothing, or more than one module, is an
elaboration error; the ambiguous case names the candidates and takes a
`(module := ...)` argument to settle it.  Nothing here touches the
formalization's *build* -- only its file tree and the toml -- so the role works
in `scripts/preview.py` unchanged.
-/
import VersoManual

open Lean
open Verso Verso.ArgParse Verso.Doc Verso.Doc.Elab
open Verso.Genre.Manual

namespace BodyPinBlueprint

/-- One `key = "value"` line of a toml table, or `none`. -/
private def quotedValue? (line key : String) : Option String :=
  if line.startsWith (key ++ " ") || line.startsWith (key ++ "=") then
    match line.splitOn "\"" with
    | _ :: v :: _ => some v
    | _ => none
  else none

/-- The `repo` and `rev` of `[formalization]` in `correspondence.toml`. -/
def readPin : IO (String × String) := do
  let text ← IO.FS.readFile "correspondence.toml"
  let mut inTable := false
  let mut repo? : Option String := none
  let mut rev? : Option String := none
  for rawLine in text.splitOn "\n" do
    let line := rawLine.trimAscii.copy
    if line.startsWith "[" then
      inTable := line == "[formalization]"
    else if inTable then
      if let some v := quotedValue? line "repo" then repo? := some v
      if let some v := quotedValue? line "rev" then rev? := some v
  match repo?, rev? with
  | some repo, some rev => return (repo, rev)
  | _, _ =>
    throw (.userError "correspondence.toml has no [formalization] table with repo and rev")

private partial def leanFilesUnder (dir : System.FilePath) : IO (Array System.FilePath) := do
  let mut out := #[]
  for entry in ← dir.readDir do
    if ← entry.path.isDir then
      out := out ++ (← leanFilesUnder entry.path)
    else if entry.path.extension == some "lean" then
      out := out.push entry.path
  return out

/--
Every module of the pinned submodule, as repository-relative paths -- the same
set `scripts/coverage.py` builds: `RB31EndToEnd/**/*.lean` plus the root
`RB31EndToEnd.lean`.
-/
def formalizationModules : IO (Array String) := do
  let root : System.FilePath := "formalization"
  let files ← leanFilesUnder (root / "RB31EndToEnd")
  let rels := files.map fun f => String.intercalate "/" (f.components.drop 1)
  return #["RB31EndToEnd.lean"] ++ rels.qsort (· < ·)

structure SrcFileConfig where
  /-- Full dotted module name; needed only when the file name alone is ambiguous. -/
  module : Option Name

section
variable {m : Type → Type} [Monad m] [MonadError m]

def SrcFileConfig.parse : ArgParse m SrcFileConfig :=
  SrcFileConfig.mk <$> .named `module .name true

instance : FromArgs SrcFileConfig m := ⟨SrcFileConfig.parse⟩

end

/--
A code span naming a file of the pinned formalization, linked to that file at
the pinned repository and rev from `correspondence.toml`.

The span is either a file name (`Construction.lean`), resolved against the
submodule's tree and required to be unique, or a full dotted module name
(`RB31EndToEnd.Combinatorics.Sparse22.Basic`).  When a file name is ambiguous,
`(module := ...)` picks; the display stays whatever the span says, so the
argument must name a module the span could mean.
-/
@[role_expander srcFile]
def srcFile : RoleExpander
  | args, inls => do
    let cfg ← parseThe SrcFileConfig args
    let name ← oneCodeStr inls
    let text := name.getString
    let modules ← formalizationModules
    let path ←
      if let some module := cfg.module then
        let p := String.intercalate "/" (module.components.map (·.toString)) ++ ".lean"
        unless modules.contains p do
          throwErrorAt name "{p} is not a module of the pinned submodule"
        unless (System.FilePath.mk p).fileName == some text || module.toString == text do
          throwErrorAt name "The span says {text}, but (module := {module}) is {p}"
        pure p
      else if text.endsWith ".lean" then
        match modules.filter (fun p => (System.FilePath.mk p).fileName == some text) with
        | #[p] => pure p
        | #[] => throwErrorAt name
            "{text} is not a file of the pinned submodule"
        | found => throwErrorAt name
            "{text} names more than one module: {found}. Add (module := ...) to pick one"
      else
        let p := String.intercalate "/" (text.splitOn ".") ++ ".lean"
        unless modules.contains p do
          throwErrorAt name "{text} is not a module of the pinned submodule"
        pure p
    let (repo, rev) ← readPin
    let url := s!"https://github.com/{repo}/blob/{rev}/{path}"
    return #[← ``(Verso.Doc.Inline.link #[Verso.Doc.Inline.code $(quote text)] $(quote url))]

end BodyPinBlueprint
