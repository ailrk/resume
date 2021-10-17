{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE ExplicitForAll         #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE KindSignatures         #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE PolyKinds              #-}
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

-- | my resume supports two langauges.
data Lang = Lang { cn :: T.Text
                 , en :: T.Text
                 }
          | Default T.Text

-- | my resume

instance Mark Lang 2 T.Text where
  mark (Default de) = mark de
  mark (Lang cn en) = mark (cn :> en :> X)

type MyResume = Resume 2 T.Text

v :: T.Text -> T.Text -> MyResume
v c e = mark $ Lang c e

name :: MyResume
name = v "姚锦洋" "Jinyang Yao"

resume :: MyResume
resume = foldResume . fmap line $
       [ "\\documentclass{resume}"
       , "\\begin{document}"
       , "\\pagenumbering{gobble}"
       , name
       , basicInfo
       , "\\end{document}"
       ]

basicInfo :: MyResume
basicInfo =
  foldResume . fmap line $
    [ "\basicInfo{"
    , "\\email{yuanbin2014@gmail.com} \\textperiodcentered\\"
    , "\\phone{(+86) 131-221-87xxx} \\textperiodcentered\\"
    , "\\linkedin[billryan8]{https://www.linkedin.com/in/billryan8}}"
    , "}"
    ]

education :: MyResume
education
  = section "Education"
  $ foldResume
  $ [ datasubsection
        (v "University of British Columbia, " "英蜀哥伦比亚大学, ")
        (v "BC, Canada, " "BC, 加拿大, ")
        "2017 - 2021"
    , br
    , foldResume [ textit (v "Major: " "本科： ")
                 , v "Computer Science" "计算机科学"
                 , ", "
                 , textit (v "Minor: " "辅修：")
                 , v "Mathematics" "数学"
                 , ", "
                 , textit "86.9/100, "
                 , textit "GPA 3.95/4.33"
                 ]
    ]


experience :: MyResume
experience
  = section "Experience"
  $ foldResume
  $ [ datasubsection
        (v "University of British Columbia, " "英蜀哥伦比亚大学, ")
        (v "BC, Canada, " "BC, 加拿大, ")
        "2017 - 2021"
    , br
    , foldResume [ textit (v "Major: " "本科： ")
                 , v "Computer Science" "计算机科学"
                 , ", "
                 , textit (v "Minor: " "辅修：")
                 , v "Mathematics" "数学"
                 , ", "
                 , textit "86.9/100, "
                 , textit "GPA 3.95/4.33"
                 ]
    ]
