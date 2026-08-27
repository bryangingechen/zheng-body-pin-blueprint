import Verso
import VersoManual
import VersoBlueprint
import VersoBlueprint.Commands.Graph
import VersoBlueprint.Commands.Summary
import BodyPinBlueprint.TeXPrelude
import BodyPinBlueprint.Chapters.Statement

open Verso.Genre
open Verso.Genre.Manual
open Informal

set_option doc.verso true

#doc (Manual) "Three-Dimensional Body-Pin Rigidity" =>

%%%
shortTitle := "Body-Pin Rigidity"
%%%

An unofficial blueprint relating Denzel Zheng's paper on three-dimensional
body--pin rigidity to its Lean 4 formalization. All mathematical results are
his; errors in this exposition are ours.

{include 0 BodyPinBlueprint.Chapters.Statement}

{blueprint_graph}
{blueprint_summary}
