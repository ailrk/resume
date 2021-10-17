{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE CPP #-}

module Main where

import System.IO

#ifdef ming32_HOST_OS
import System.FilePath.Windows as P
#else
import System.FilePath.Posix as P
#endif


main :: IO ()
main = putStrLn "Hello, Haskell!"
