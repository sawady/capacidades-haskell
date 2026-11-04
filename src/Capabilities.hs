{-# LANGUAGE Haskell2010 #-}
-- | Capabilities as type classes, in Haskell 2010 with no extensions.
--
-- Each class is a permission: a function that needs the network asks for
-- @Net m@, one that prints asks for @Console m@. Since @m@ is abstract, the
-- function cannot do anything beyond what its constraints grant it.
module Capabilities
  ( Url
  , Net (..)
  , Console (..)
  , Files (..)
  , firstLine
  ) where

type Url = String

class Monad m => Net m where
  httpGet :: Url -> m String

class Monad m => Console m where
  printLine :: String -> m ()

class Monad m => Files m where
  readTextFile :: FilePath -> m String

firstLine :: String -> String
firstLine = takeWhile (/= '\n')
