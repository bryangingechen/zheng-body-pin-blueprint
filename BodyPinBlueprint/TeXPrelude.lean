import Verso
import VersoManual
import VersoBlueprint

open Informal

-- Use `\providecommand`, not `\newcommand`. The prelude is re-evaluated into a
-- persistent KaTeX macro map, so `\newcommand` fails on every math span after
-- the first with "attempting to redefine \N; use \renewcommand", and KaTeX then
-- rejects the whole span. `\providecommand` is idempotent.
tex_prelude
  r#"\providecommand{\N}{\mathbb{N}}
\providecommand{\Z}{\mathbb{Z}}
\providecommand{\Q}{\mathbb{Q}}
\providecommand{\R}{\mathbb{R}}"#
