import VersoManual
import VersoBlueprint.PreviewManifest
import BodyPinBlueprint.Preview

open Verso Doc
open Verso.Genre Manual

def main (args : List String) : IO UInt32 :=
  Informal.PreviewManifest.blueprintMainWithPreviewData
    (%doc BodyPinBlueprint.Preview)
    args
    (extensionImpls := by exact extension_impls%)
