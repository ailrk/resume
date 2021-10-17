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

module Resume where


import           Data.Kind
import           Data.Proxy
import qualified Data.Text    as T
import           GHC.TypeLits
import           Tex
import Str (r)

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
       , "\\end{document}"
       ]

basicInfo :: MyResume
basicInfo =
  foldResume . fmap line $
    [ "\basicInfo{"
    , "\\email{", email, " } \\textperiodcentered\\"
    , "\\phone{", phone, "} \\textperiodcentered\\"
    , "\\home{", home, "} \\textperiodcentered\\"
    , "\\github[billryan8]{", github, "}}"
    , "}"
    ]
  where
    email = "jinyangyaop@gmail.com"
    phone = "+1 250 899 2600"
    home = "https://ailrk.github.io/home"
    github = "https://github.com/ailrk/resume"

education :: MyResume
education
  = section "Education"
  . foldResume
  $ [ datasubsection university univAddr "2017 - 2021"
    , br
    , foldResume
        [ textit major <> majored <> ", "
        , textit minor <> minored <> ", "
        , textit "86.9/100, "
        , textit "GPA 3.95/4.33"
        ]
    ]
  where
    university = l "University of British Columbia, " "英属哥伦比亚大学, "
    univAddr = l "BC, Canada, " "BC, 加拿大, "
    major = l "Major: " "本科： "
    majored = l "Computer Science" "计算机科学"
    minor = l "Minor: " "辅修："
    minored =  l "Mathematics" "数学"


projects :: MyResume
projects
  = section "Project"
  . foldResume
  $ [
    ]

skills :: MyResume
skills
  = section "Experience"
  . foldResume
  $ []

experience :: MyResume
experience
  = section "Experience"
  . foldResume
  $ []
  where
    chongqingUni2019 = l
      [r|
        Developed optmizing algorithm to find the optimal building design
        Developed a web platform that collect sensor data across long
        distances
     ...
      |]

      [r|
        asd
      |]


