import Verso
import VersoManual
import VersoManual.Bibliography
import VersoBlueprint

open Verso
open Verso.Genre
open Verso.Genre.Manual
open Verso.Genre.Manual.Bibliography

/-!
# Bibliography

The paper's own reference list, transcribed from `source/paper.txt`, plus the
three artifacts this blueprint is *about*: the paper, the author's informal
research note, and the Lean development.

Citation keys are `lowerCamelSurname` + year, matching the paper's author
ordering. They are stable identifiers: cite by key, never by the paper's
bracketed number, which shifts between preprint revisions for the same reason
result numbers do.

Two rendering notes, neither of which we can fix from here (see
`notes/upstream.md` §4):

* `Citable` has only `article`, `inProceedings`, `thesis`, and `arXiv`
  constructors. Monographs are entered as `article` with the series in the
  journal slot and the series number in the volume slot, which is where an
  author-date renderer puts them anyway.
* Inline citations abbreviate an author to the *last word* of the name, so
  authors are written initials-first (`L. Asimow`). That is also what the paper
  does.
-/

namespace BodyPinBlueprint.Bib

/-! ## The paper, the note, and the formalization -/

/-- The paper this blueprint maps. -/
@[bib "zheng2026"]
def zheng2026 : Citable := .article
  { title := inlines!"Stress Degeneracy of Direction Complexes of (2, 2)-Sparse Graphs and Three-Dimensional Body–Pin Rigidity"
  , authors := #[inlines!"D. Zheng"]
  , journal := inlines!"Preprint"
  , year := 2026
  , month := some inlines!"August"
  , volume := inlines!"doi:10.13140/RG.2.2.17830.28485"
  , number := inlines!""
  , url := some "https://doi.org/10.13140/RG.2.2.17830.28485"
  }

/-- The author's informal research note on the same material. -/
@[bib "zheng2026note"]
def zheng2026note : Citable := .article
  { title := inlines!"Stress Degeneracy, Collinearity Flags, and Three-Dimensional Body–Pin Rigidity"
  , authors := #[inlines!"D. Zheng"]
  , journal := inlines!"Research note"
  , year := 2026
  , month := some inlines!"20 August"
  , volume := inlines!"denzelzheng.com"
  , number := inlines!""
  , url := some "https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/"
  }

/-- The Lean 4 development, pinned here as the `formalization/` submodule. -/
@[bib "zheng2026lean"]
def zheng2026lean : Citable := .article
  { title := inlines!"Three-Dimensional Body–Pin Rigidity: a Lean 4 Formalization"
  , authors := #[inlines!"D. Zheng"]
  , journal := inlines!"Lean 4 development"
  , year := 2026
  , month := some inlines!"August"
  , volume := inlines!"v1.0.0"
  , number := inlines!""
  , url := some "https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture"
  }

/-! ## The paper's reference list -/

/-- Paper reference [1]. -/
@[bib "asimowRoth1978"]
def asimowRoth1978 : Citable := .article
  { title := inlines!"The rigidity of graphs"
  , authors := #[inlines!"L. Asimow", inlines!"B. Roth"]
  , journal := inlines!"Trans. Amer. Math. Soc."
  , year := 1978
  , month := none
  , volume := inlines!"245"
  , number := inlines!""
  , pages := some (279, 289)
  , url := some "https://doi.org/10.1090/S0002-9947-1978-0511410-9"
  }

/-- Paper reference [2]. -/
@[bib "asimowRoth1979"]
def asimowRoth1979 : Citable := .article
  { title := inlines!"The rigidity of graphs, II"
  , authors := #[inlines!"L. Asimow", inlines!"B. Roth"]
  , journal := inlines!"J. Math. Anal. Appl."
  , year := 1979
  , month := none
  , volume := inlines!"68"
  , number := inlines!""
  , pages := some (171, 190)
  , url := some "https://doi.org/10.1016/0022-247X(79)90108-2"
  }

/-- Paper reference [3]. -/
@[bib "brunsHerzog1998"]
def brunsHerzog1998 : Citable := .article
  { title := inlines!"Cohen–Macaulay Rings, revised edition"
  , authors := #[inlines!"W. Bruns", inlines!"H. J. Herzog"]
  , journal := inlines!"Cambridge Studies in Advanced Mathematics, Cambridge University Press"
  , year := 1998
  , month := none
  , volume := inlines!"39"
  , number := inlines!""
  , url := some "https://doi.org/10.1017/CBO9780511608681"
  }

/-- Paper reference [4]. -/
@[bib "brunsVetter1988"]
def brunsVetter1988 : Citable := .article
  { title := inlines!"Determinantal Rings"
  , authors := #[inlines!"W. Bruns", inlines!"U. Vetter"]
  , journal := inlines!"Lecture Notes in Mathematics, Springer"
  , year := 1988
  , month := none
  , volume := inlines!"1327"
  , number := inlines!""
  , url := some "https://doi.org/10.1007/BFb0080378"
  }

/-- Paper reference [5]. -/
@[bib "clinchJacksonTanigawa2022a"]
def clinchJacksonTanigawa2022a : Citable := .article
  { title := inlines!"Abstract 3-rigidity and bivariate C¹₂-splines I: Whiteley's maximality conjecture"
  , authors := #[inlines!"K. Clinch", inlines!"B. Jackson", inlines!"S.-i. Tanigawa"]
  , journal := inlines!"Discrete Anal."
  , year := 2022
  , month := none
  , volume := inlines!"2022:2"
  , number := inlines!""
  , url := some "https://doi.org/10.19086/da.34691"
  }

/-- Paper reference [6]. -/
@[bib "clinchJacksonTanigawa2022b"]
def clinchJacksonTanigawa2022b : Citable := .article
  { title := inlines!"Abstract 3-rigidity and bivariate C¹₂-splines II: Combinatorial characterization"
  , authors := #[inlines!"K. Clinch", inlines!"B. Jackson", inlines!"S.-i. Tanigawa"]
  , journal := inlines!"Discrete Anal."
  , year := 2022
  , month := none
  , volume := inlines!"2022:3"
  , number := inlines!""
  , url := some "https://doi.org/10.19086/da.34692"
  }

/-- Paper reference [7]. -/
@[bib "cruickshankJacksonJordanTanigawa2026"]
def cruickshankJacksonJordanTanigawa2026 : Citable := .inProceedings
  { title := inlines!"Rigidity of graphs and frameworks: A matroid theoretic approach"
  , authors := #[inlines!"J. Cruickshank", inlines!"B. Jackson", inlines!"T. Jordán",
      inlines!"S.-i. Tanigawa"]
  , year := 2026
  , booktitle := inlines!"Surveys in Combinatorics 2026"
  , series := some inlines!"London Mathematical Society Lecture Note Series, Cambridge University Press, pp. 189–230"
  , url := some "https://doi.org/10.1017/9781009766012.007"
  }

/-- Paper reference [8]. -/
@[bib "deMouraUllrich2021"]
def deMouraUllrich2021 : Citable := .inProceedings
  { title := inlines!"The Lean 4 theorem prover and programming language"
  , authors := #[inlines!"L. de Moura", inlines!"S. Ullrich"]
  , year := 2021
  , booktitle := inlines!"Automated Deduction – CADE 28"
  , series := some inlines!"Lecture Notes in Computer Science 12699, Springer, pp. 625–635"
  , url := some "https://doi.org/10.1007/978-3-030-79876-5_37"
  }

/-- Paper reference [9]. -/
@[bib "dorayKarpenkovSchepers2010"]
def dorayKarpenkovSchepers2010 : Citable := .article
  { title := inlines!"Geometry of configuration spaces of tensegrities"
  , authors := #[inlines!"F. Doray", inlines!"O. Karpenkov", inlines!"J. Schepers"]
  , journal := inlines!"Discrete Comput. Geom."
  , year := 2010
  , month := none
  , volume := inlines!"43"
  , number := inlines!""
  , pages := some (436, 466)
  , url := some "https://doi.org/10.1007/s00454-009-9229-4"
  }

/-- Paper reference [10]. -/
@[bib "edmonds1965"]
def edmonds1965 : Citable := .article
  { title := inlines!"Minimum partition of a matroid into independent subsets"
  , authors := #[inlines!"J. Edmonds"]
  , journal := inlines!"J. Res. Nat. Bur. Standards Sect. B"
  , year := 1965
  , month := none
  , volume := inlines!"69B"
  , number := inlines!""
  , pages := some (67, 72)
  , url := some "https://doi.org/10.6028/JRES.069B.004"
  }

/-- Paper reference [11]. -/
@[bib "eisenbud1995"]
def eisenbud1995 : Citable := .article
  { title := inlines!"Commutative Algebra with a View Toward Algebraic Geometry"
  , authors := #[inlines!"D. Eisenbud"]
  , journal := inlines!"Graduate Texts in Mathematics, Springer"
  , year := 1995
  , month := none
  , volume := inlines!"150"
  , number := inlines!""
  , url := some "https://doi.org/10.1007/978-1-4612-5350-1"
  }

/-- Paper reference [12]. -/
@[bib "fulton1998"]
def fulton1998 : Citable := .article
  { title := inlines!"Intersection Theory, second edition"
  , authors := #[inlines!"W. Fulton"]
  , journal := inlines!"Ergebnisse der Mathematik und ihrer Grenzgebiete (3), Springer"
  , year := 1998
  , month := none
  , volume := inlines!"2"
  , number := inlines!""
  , url := some "https://doi.org/10.1007/978-1-4612-1700-8"
  }

/-- Paper reference [13]. -/
@[bib "gortlerHealyThurston2010"]
def gortlerHealyThurston2010 : Citable := .article
  { title := inlines!"Characterizing generic global rigidity"
  , authors := #[inlines!"S. J. Gortler", inlines!"A. D. Healy", inlines!"D. P. Thurston"]
  , journal := inlines!"Amer. J. Math."
  , year := 2010
  , month := none
  , volume := inlines!"132"
  , number := inlines!""
  , pages := some (897, 939)
  , url := some "https://doi.org/10.1353/ajm.0.0132"
  }

/-- Paper reference [14]. -/
@[bib "graverServatiusServatius1993"]
def graverServatiusServatius1993 : Citable := .article
  { title := inlines!"Combinatorial Rigidity"
  , authors := #[inlines!"J. E. Graver", inlines!"B. Servatius", inlines!"H. Servatius"]
  , journal := inlines!"Graduate Studies in Mathematics, American Mathematical Society"
  , year := 1993
  , month := none
  , volume := inlines!"2"
  , number := inlines!""
  , url := some "https://doi.org/10.1090/gsm/002"
  }

/-- Paper reference [15]. -/
@[bib "jacksonJordan2005"]
def jacksonJordan2005 : Citable := .article
  { title := inlines!"Rigid two-dimensional frameworks with three collinear points"
  , authors := #[inlines!"B. Jackson", inlines!"T. Jordán"]
  , journal := inlines!"Graphs Combin."
  , year := 2005
  , month := none
  , volume := inlines!"21"
  , number := inlines!""
  , pages := some (427, 444)
  , url := some "https://doi.org/10.1007/s00373-005-0629-9"
  }

/-- Paper reference [16]. -/
@[bib "jacksonJordan2008"]
def jacksonJordan2008 : Citable := .article
  { title := inlines!"Pin-collinear body-and-pin frameworks and the molecular conjecture"
  , authors := #[inlines!"B. Jackson", inlines!"T. Jordán"]
  , journal := inlines!"Discrete Comput. Geom."
  , year := 2008
  , month := none
  , volume := inlines!"40"
  , number := inlines!""
  , pages := some (258, 278)
  , url := some "https://doi.org/10.1007/s00454-008-9100-z"
  }

/-- Paper reference [17]. -/
@[bib "jacksonJordanVillanyi2026"]
def jacksonJordanVillanyi2026 : Citable := .arXiv
  { title := inlines!"Rank contributions of vertices in rigidity matroids of clique covered graphs"
  , authors := #[inlines!"B. Jackson", inlines!"T. Jordán", inlines!"S. Villányi"]
  , year := 2026
  , id := "2607.26266"
  }

/-- Paper reference [18]. -/
@[bib "jordan2016"]
def jordan2016 : Citable := .inProceedings
  { title := inlines!"Combinatorial rigidity: Graphs and matroids in the theory of rigid frameworks"
  , authors := #[inlines!"T. Jordán"]
  , year := 2016
  , booktitle := inlines!"Discrete Geometric Analysis"
  , series := some inlines!"MSJ Memoirs 34, Mathematical Society of Japan, pp. 33–112"
  , url := some "https://doi.org/10.2969/msjmemoirs/03401C020"
  }

/-- Paper reference [19]. -/
@[bib "karpenkov2021"]
def karpenkov2021 : Citable := .article
  { title := inlines!"The combinatorial geometry of stresses in frameworks"
  , authors := #[inlines!"O. Karpenkov"]
  , journal := inlines!"Discrete Comput. Geom."
  , year := 2021
  , month := none
  , volume := inlines!"65"
  , number := inlines!""
  , pages := some (43, 89)
  , url := some "https://doi.org/10.1007/s00454-020-00234-8"
  }

/-- Paper reference [20]. -/
@[bib "katohTanigawa2011"]
def katohTanigawa2011 : Citable := .article
  { title := inlines!"A proof of the molecular conjecture"
  , authors := #[inlines!"N. Katoh", inlines!"S.-i. Tanigawa"]
  , journal := inlines!"Discrete Comput. Geom."
  , year := 2011
  , month := none
  , volume := inlines!"45"
  , number := inlines!""
  , pages := some (647, 700)
  , url := some "https://doi.org/10.1007/s00454-011-9348-6"
  }

/-- Paper reference [21]. Conjecture 5 is the conjecture this blueprint's paper settles. -/
@[bib "kiralyTanigawa2019"]
def kiralyTanigawa2019 : Citable := .inProceedings
  { title := inlines!"Rigidity of body-bar-hinge frameworks"
  , authors := #[inlines!"Cs. Király", inlines!"S.-i. Tanigawa"]
  , year := 2019
  , booktitle := inlines!"Handbook of Geometric Constraint Systems Principles, chapter 20"
  , editors := some #[inlines!"M. Sitharam", inlines!"A. St. John", inlines!"J. Sidman"]
  , series := some inlines!"Chapman & Hall/CRC, pp. 435–459"
  , url := some "https://doi.org/10.1201/9781315121116-20"
  }

/-- Paper reference [22]. -/
@[bib "laman1970"]
def laman1970 : Citable := .article
  { title := inlines!"On graphs and rigidity of plane skeletal structures"
  , authors := #[inlines!"G. Laman"]
  , journal := inlines!"J. Engrg. Math."
  , year := 1970
  , month := none
  , volume := inlines!"4"
  , number := inlines!""
  , pages := some (331, 340)
  , url := some "https://doi.org/10.1007/BF01534980"
  }

/-- Paper reference [23]. -/
@[bib "lovaszYemini1982"]
def lovaszYemini1982 : Citable := .article
  { title := inlines!"On generic rigidity in the plane"
  , authors := #[inlines!"L. Lovász", inlines!"Y. Yemini"]
  , journal := inlines!"SIAM J. Algebraic Discrete Methods"
  , year := 1982
  , month := none
  , volume := inlines!"3"
  , number := inlines!""
  , pages := some (91, 98)
  , url := some "https://doi.org/10.1137/0603009"
  }

/-- Paper reference [24]. -/
@[bib "mathlib2020"]
def mathlib2020 : Citable := .inProceedings
  { title := inlines!"The Lean mathematical library"
  , authors := #[inlines!"The mathlib Community"]
  , year := 2020
  , booktitle := inlines!"Proceedings of the 9th ACM SIGPLAN International Conference on Certified Programs and Proofs"
  , series := some inlines!"ACM, pp. 367–381"
  , url := some "https://doi.org/10.1145/3372885.3373824"
  }

/-- Paper reference [25]. -/
@[bib "nashWilliams1964"]
def nashWilliams1964 : Citable := .article
  { title := inlines!"Decomposition of finite graphs into forests"
  , authors := #[inlines!"C. St. J. A. Nash-Williams"]
  , journal := inlines!"J. London Math. Soc."
  , year := 1964
  , month := none
  , volume := inlines!"39"
  , number := inlines!""
  -- One page (12), and `pages` renders a range: "pp. 12-12" is worse than nothing.
  , url := some "https://doi.org/10.1112/jlms/s1-39.1.12"
  }

/-- Paper reference [26]. -/
@[bib "tay1984"]
def tay1984 : Citable := .article
  { title := inlines!"Rigidity of multi-graphs. I. Linking rigid bodies in n-space"
  , authors := #[inlines!"T.-S. Tay"]
  , journal := inlines!"J. Combin. Theory Ser. B"
  , year := 1984
  , month := none
  , volume := inlines!"36"
  , number := inlines!""
  , pages := some (95, 112)
  , url := some "https://doi.org/10.1016/0095-8956(84)90016-9"
  }

/-- Paper reference [27]. -/
@[bib "tay1989"]
def tay1989 : Citable := .article
  { title := inlines!"Linking (n − 2)-dimensional panels in n-space II: (n − 2, 2)-frameworks and body and hinge structures"
  , authors := #[inlines!"T.-S. Tay"]
  , journal := inlines!"Graphs Combin."
  , year := 1989
  , month := none
  , volume := inlines!"5"
  , number := inlines!""
  , pages := some (245, 273)
  , url := some "https://doi.org/10.1007/BF01788678"
  }

/-- Paper reference [28]. -/
@[bib "whiteWhiteley1983"]
def whiteWhiteley1983 : Citable := .article
  { title := inlines!"The algebraic geometry of stresses in frameworks"
  , authors := #[inlines!"N. L. White", inlines!"W. Whiteley"]
  , journal := inlines!"SIAM J. Algebraic Discrete Methods"
  , year := 1983
  , month := none
  , volume := inlines!"4"
  , number := inlines!""
  , pages := some (481, 511)
  , url := some "https://doi.org/10.1137/0604049"
  }

/-- Paper reference [29]. -/
@[bib "whiteWhiteley1987"]
def whiteWhiteley1987 : Citable := .article
  { title := inlines!"The algebraic geometry of motions of bar-and-body frameworks"
  , authors := #[inlines!"N. White", inlines!"W. Whiteley"]
  , journal := inlines!"SIAM J. Algebraic Discrete Methods"
  , year := 1987
  , month := none
  , volume := inlines!"8"
  , number := inlines!""
  , pages := some (1, 32)
  , url := some "https://doi.org/10.1137/0608001"
  }

/-- Paper reference [30]. -/
@[bib "whiteley1988"]
def whiteley1988 : Citable := .article
  { title := inlines!"The union of matroids and the rigidity of frameworks"
  , authors := #[inlines!"W. Whiteley"]
  , journal := inlines!"SIAM J. Discrete Math."
  , year := 1988
  , month := none
  , volume := inlines!"1"
  , number := inlines!""
  , pages := some (237, 255)
  , url := some "https://doi.org/10.1137/0401025"
  }

/-- Paper reference [31]. Conjecture 10.3.2 is Whiteley's R₃ = C¹₂ conjecture. -/
@[bib "whiteley1996"]
def whiteley1996 : Citable := .inProceedings
  { title := inlines!"Some matroids from discrete applied geometry"
  , authors := #[inlines!"W. Whiteley"]
  , year := 1996
  , booktitle := inlines!"Matroid Theory"
  , editors := some #[inlines!"J. E. Bonin", inlines!"J. G. Oxley", inlines!"B. Servatius"]
  , series := some inlines!"Contemporary Mathematics 197, American Mathematical Society, pp. 171–311"
  , url := some "https://doi.org/10.1090/conm/197/02540"
  }

end BodyPinBlueprint.Bib
