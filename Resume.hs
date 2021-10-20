{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE ExplicitForAll         #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE KindSignatures         #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE PolyKinds              #-}
{-# LANGUAGE QuasiQuotes            #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE TypeApplications       #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeOperators          #-}

module Resume (resume) where


import           Data.Kind
import           Data.Proxy
import qualified Data.Text    as T
import           GHC.TypeLits
import           Str          (r)
import           Tex

-- | my resume supports two langauges.
data Lang = Lang { english :: T.Text
                 , chinese :: T.Text
                 }
          | Default T.Text

-- | my resume

instance Mark Lang 2 T.Text where
  mark (Default de) = mark de
  mark (Lang cn en) = mark (cn :> en :> X)

-- | versioned
l :: T.Text -> T.Text -> MyResume
l e c = mark $ Lang e c

type MyResume = Resume 2 T.Text

name :: MyResume
name = l "Jinyang Yao" "姚锦洋"

resume :: MyResume
resume = foldResume . fmap line $
       [ "\\documentclass{resume}"
       , "\\begin{document}"
       , "\\pagenumbering{gobble}"
       , name
       , basicInfo
       , education
       , experience
       , projects
       , skills
       , misc
       , "\\end{document}"
       ]

basicInfo :: MyResume
basicInfo =
  foldResume . fmap line $
    [ "\\basicInfo{" , email , phone, "}" ]
  where
    email = inlineinfo "email"   "jinyangyaop@gmail.com"
    phone = inlineinfo "phone"   "+1 250 899 2600"

education :: MyResume
education
  = section "Education"
  . foldResume
  $ [ datasubsection ((textbf university) <> univAddr) "2017 - 2021"
    , br
    , foldResume
        [ textit (major <> majored <> ", ")
        , textit (minor <> minored <> ", ")
        , "86.9/100, "
        , "GPA 3.95/4.33"
        ]
    ]
  where
    university = l "University of British Columbia, " "英属哥伦比亚大学, "
    univAddr = l "BC, Canada, " "BC, 加拿大, "
    major = l "Major: " "本科： "
    majored = l "Computer Science" "计算机科学"
    minor = l "Minor: " "辅修："
    minored =  l "Mathematics" "数学"

itemSection :: MyResume -> [MyResume] -> MyResume
itemSection name = section name . itemize . fmap item

projects :: MyResume
projects = itemSection "Projects" [ cppparsec , tml , blgol60 , bonkml ]
  where
    cppparsec = foldResume
      [ datasubsection (textbf "cppparsec") "ailrk.com/ailrk/cppparsec" <> br
      ,  "A monadic parser combinator library in C++"
      ]

    tml = foldResume
      [ datasubsection (textbf "tml") "ailrk.com/ailrk/tml" <> br
      , "Untyped lambda calculus written in c++ template"
      ]

    blgol60 = foldResume
      [ datasubsection (textbf "blgol60") "ailrk.com/ailrk/blgol60" <> br
      , "Algol 60 implementation with Haskell forntend and C++ backend"
      ]

    bonkml = foldResume
      [ datasubsection (textbf "bonkml") "ailrk.com/ailrk/bonkml" <> br
      , "Standard ml like langauge writtin with ocaml frontend and rust backend"
      ]

skills :: MyResume
skills = itemSection "Skills" [ lang , compiler , webdev , platform ]
  where
    lang = (textbf (l "Programming Language:" "编程语言:")) <> l
      [r| Faimiliar wide range of planauges and programming styles.
          //
          Most used: C++, Haskell, Python, Ocaml, Rust, Typescript
          Familiar: Commonlisp, C#, Java, Coq, Lean
      |]
      [r| some text |]
    compiler = (textbf (l "Compiler: " "编译器")) <> l
      [r| Familiar with LLVM pass and LLVM IR, garbage collecting mechanisms,
          various parsing theory and techniques.
      |]
      [r| some text |]
    pl = (textbf (l "Programming language theory: " "编程语言理论")) <> l
      [r|  Familiar with lambda calculus and it's type level extensions along
           lambda cube.
           Familiar with operational and denotational semantics of ML family
           languages.
           Familiar with martin lof type theory
      |]
      [r| some text |]
    webdev = (textbf (l "Web programming: " "Web 开发")) <> l
      [r| Familiar with flask and react frame work, have experience with
          RESTFUL API designing and data organization.
          Understand various concurrency models. Familiar with libuv.
      |]
      [r| some text |]
    platform = (textbf (l "Platform: " "平台")) <> l
      [r| Familiar with system programming under linux |]
      [r| some text |]

misc :: MyResume
misc = itemSection "Misc" [ home , github, natlang ]
  where
    home = "Home: https://ailrk.github.io/home"
    github = "Github: https://github.com/ailrk/resume"
    natlang = (textbf (l "Natural langauge: " "自然语言")) <> l
      [r| some text |]
      [r| some text |]

experience :: MyResume
experience
  = itemSection "Experience "
    [ chongqingUni2019
    , ubchonor2020
    ]
  where
    chongqingUni2019 =
      (textbf (l "Chonqing University Environment and Ecology department: "
                 ""))
      <> l
      [r| Developed an optimization program to find the optimal building
          design that balances construction cost, comfortness, and energy
          cosumption.
          //
          Developed a webplatform that store, organize, analyze, and
          demonstrate data of from temperature humidity collected from sensors
          across long distance.
      |]
      [r| some text |]
    ubchonor2020 =
      (textbf (l "UBC computer science honor program"
                 ""))
      <> l
      [r| Deve|]
      [r| some text |]
