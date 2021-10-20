{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE ConstraintKinds        #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE ExplicitForAll         #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs                  #-}
{-# LANGUAGE InstanceSigs           #-}
{-# LANGUAGE KindSignatures         #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE PolyKinds              #-}
{-# LANGUAGE QuasiQuotes            #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeApplications       #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE UndecidableInstances   #-}
module Tex
  ( Mark(..)
  , Resume(..)
  , foldResume
  , R(..)
  , p
  , line
  , HList(..)
  , br
  , section
  , datasubsection
  , Itemize(..)
  , item
  , textit
  , textbf
  , inlineinfo
  )
  where

import           Data.Kind
import           Data.Proxy
import           Data.String
import qualified Data.Text          as T
import           Data.Type.Equality
import           GHC.TypeLits

type x > y = CmpNat x y ~ 'GT

-- | multitext are fixed sized list
data MultiText (n :: Nat) a where
  NT :: MultiText 0 a
  MT :: a -> MultiText (n - 1) a -> MultiText n a

data Tex (n :: Nat) a = W (MultiText n a) | S a

toList :: MultiText n a -> [a]
toList NT        = []
toList (MT m ms) = m:toList ms

singleton :: a -> MultiText 1 a
singleton a = MT a NT

instance Functor (MultiText n) where
  fmap _ NT        = NT
  fmap f (MT x xs) = MT (f x) (fmap f xs)

-- | monoids for multiwords
instance Monoid a => Semigroup (MultiText n a) where
  NT <> m = m
  m <> NT = m
  (MT m ms) <> (MT n ns) = MT (m <> n) (ms' <> ns')
    where
      ms' :: m ~ (n - 1) => MultiText m a; ms' = ms'
      ns' :: m ~ (n - 1) => MultiText m a; ns' = ns'

instance ( Monoid a
         , Monoid (MultiText (n - 1) a)
         , n > 0)
        => Monoid (MultiText n a) where
  mempty = MT mempty mempty

instance {-# OVERLAPS #-} (Monoid a)
        => Monoid (MultiText 0 a) where
  mempty = NT

instance Monoid a => Semigroup (Tex n a) where
  (W w1) <> (W w2) = W (w1 <> w2)
  (W w) <> (S s)   = W (fmap (<>s) w)
  (S s) <> (W w)   = W (fmap (s<>) w)
  (S s1) <> (S s2) = S (s1 <> s2)

instance Monoid a => Monoid (Tex n a) where mempty = S mempty

-- | resume is an endomorphism under function composition
newtype Resume n a = Resume { unResume :: Tex n a -> Tex n a }

instance IsString (Resume n T.Text) where
  fromString n = Resume (S (T.pack n) <>)

instance Monoid a => Semigroup (Resume n a) where
  (Resume x) <> (Resume y) = Resume $ y . x
instance Monoid a => Monoid (Resume n a) where mempty = Resume id

foldResume :: Monoid a => [Resume n a] -> Resume n a
foldResume = mconcat

data HList as where
  X :: HList '[]
  (:>) :: a -> HList as -> HList (a ': as)
infixr 5 :>

class Mark m n a where mark :: m -> Resume n a
instance Monoid a => Mark a n a where mark text = Resume $ \t -> S text <> t

instance (Monoid a
         , a ~ T.Text )
         => Mark (HList '[]) 0 a where
  mark X = Resume $ \t -> W (hlist2mt X) <> t

instance ( Monoid a
         , ass ~ (a ': as)
         , AllText ass
         , Mark (HList as) (n - 1) a
         , HList2MultiText as (n - 1))
         => Mark (HList (a ': as)) n T.Text where
  mark as = Resume $ \t -> W (hlist2mt as) <> t

-- | allowing to count list size.
class HList2MultiText xs (n :: Nat) where
  hlist2mt :: HList xs -> MultiText n T.Text

instance HList2MultiText '[] 0 where hlist2mt X = NT

instance ( xxs ~ (x ': xs)
         , AllText xxs
         , HList2MultiText xs (n - 1))
         => HList2MultiText (x ': xs) n where
  hlist2mt (y :> ys) = MT y (hlist2mt ys)

type family IsText a :: Constraint where IsText T.Text = ()
type family AllText xs :: Constraint where
  AllText  '[] = ()
  AllText (a ': as) = (a ~ T.Text, AllText as)

type family Size xs :: Nat where
  Size '[] = 0
  Size (x ': xs) = 1 + Size xs

--------------
-- combinators

type R n = Resume n T.Text

p :: Monoid a => a -> Resume n a
p text = Resume $ \t -> S text <> t

line ::  R n -> R n
line text = (text <> "\n")

br = line "\\"

section ::  R n -> R n -> R n
section name body = mconcat [ "\\section{\\ " <> name <> "}" , body , "\n" ]

datasubsection :: R n -> R n -> R n
datasubsection name time
  = foldResume $
  ["\\datedsubsection ", name, "{", time, "}"]

class Itemize a r | r -> a where itemize :: a -> r

instance Itemize ([R n]) (R n -> R n) where
  itemize items parsep = foldResume
           [ line ("\\begin{itemize}" <> parsep)
           , foldResume . fmap line $ items
           , line "\\end{itemize}"
           ]

instance Itemize ([R n]) (R n) where
  itemize items = foldResume
           [ line "\\begin{itemize}"
           , foldResume . fmap line $ items
           , line "\\end{itemize}"
           ]

item :: R n -> R n
item = (line "\\item " <>)

textit :: R n -> R n
textit t = "\\textit{" <> t <> "}"

textbf :: R n -> R n
textbf t = "\\textbf{" <> t <> "}"

inlineinfo :: R n -> R n -> R n
inlineinfo tag tagval =
  mconcat ["\\", tag, "{", tagval, " } \\textperiodcentered\\"]
