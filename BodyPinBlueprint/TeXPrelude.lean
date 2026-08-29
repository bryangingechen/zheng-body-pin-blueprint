import Verso
import VersoManual
import VersoBlueprint

open Informal

-- Use `\providecommand`, not `\newcommand`. The prelude is re-evaluated into a
-- persistent KaTeX macro map, so `\newcommand` fails on every math span after
-- the first with "attempting to redefine \N; use \renewcommand", and KaTeX then
-- rejects the whole span. `\providecommand` is idempotent. The same applies to
-- `\DeclareMathOperator`, which is why the operators below are spelled out with
-- `\operatorname`.
--
-- Keep this list short and keep every entry in use. A macro nobody calls is a
-- macro nobody notices breaking.
tex_prelude
  r#"\providecommand{\N}{\mathbb{N}}
\providecommand{\Q}{\mathbb{Q}}
\providecommand{\R}{\mathbb{R}}
\providecommand{\C}{\mathbb{C}}
\providecommand{\trdeg}{\operatorname{trdeg}}
\providecommand{\codim}{\operatorname{codim}}
\providecommand{\ht}{\operatorname{ht}}"#
