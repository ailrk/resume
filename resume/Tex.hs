{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE ConstraintKinds        #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE ExplicitForAll         #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs                  #-}
{-# LANGUAGE KindSignatures         #-}
{-# LANGUAGE PolyKinds              #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE TypeApplications       #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE UndecidableInstances   #-}
module Tex where

import           Data.Kind
import           Data.Proxy
import qualified Data.Text    as T
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

instance Functor (MultiText n) where
  fmap _ NT        = NT
  fmap f (MT x xs) = MT (f x) (fmap f xs)

-- | monoids for multiwords
instance Monoid a => Semigroup (MultiText n a) where
  NT <> m = m
  m <> NT = m
  (MT m ms) <> (MT n ns) = MT (m <> n) (ms' <> ns')
    where
      ms' :: m ~ (n - 1) => MultiText m a
      ms' = ms'

      ns' :: m ~ (n - 1) => MultiText m a
      ns' = ns'

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

instance Monoid a => Monoid (Tex n a) where
  mempty = S mempty


-- | resume is an endomorphism under function composition
newtype Resume n a = Resume { unResume :: Tex n a -> Tex n a }

instance Monoid a => Semigroup (Resume n a) where
  (Resume x) <> (Resume y) = Resume $ y . x
instance Monoid a => Monoid (Resume n a) where
  mempty = Resume id


