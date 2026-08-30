import VersoManual
import VersoBlueprint.PreviewManifest
import BodyPinBlueprint
import BodyPinBlueprint.Style

open Verso Doc
open Verso.Genre Manual

def main (args : List String) : IO UInt32 :=
  Informal.PreviewManifest.blueprintMainWithPreviewData
    (%doc BodyPinBlueprint)
    args
    (extensionImpls := by exact extension_impls%)
    (config :=
      { extraCss := [BodyPinBlueprint.quotedBodyCss, BodyPinBlueprint.daggerRowCss]
        extraJs := [BodyPinBlueprint.quotedBodyJs, BodyPinBlueprint.daggerRowJs] })
