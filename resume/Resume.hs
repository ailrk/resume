{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE ExplicitForAll         #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs                  #-}
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

data Lang = Lang { cn :: T.Text
                 , en :: T.Text
                 }
          | Default T.Text

class Injective a b  where to :: a -> b
class (Injective a b, Injective b a) => Iso a b where from :: b -> a

instance Injective Lang (Tex 2 T.Text) where
  to (Lang cn en) = W (MT cn (MT en NT))
  to (Default de) = S de

instance Injective (Tex 2 T.Text) Lang where
  to (W (MT cn (MT en NT))) = Lang cn en
  to (S a)                  = Default a
