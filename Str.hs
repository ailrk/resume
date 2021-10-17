module Str where

import Language.Haskell.TH
import Language.Haskell.TH.Quote

r :: QuasiQuoter
r = QuasiQuoter
  { quoteExp = return . LitE . StringL . newLines
  , quotePat = const (error "expression only")
  , quoteType = const (error "expression only")
  , quoteDec = const (error "expression only")
  }

newLines :: String -> String
newLines [] = []
newLines ('\r':'\n':cs) = '\n':newLines cs
newLines (c:cs) = c:newLines cs
