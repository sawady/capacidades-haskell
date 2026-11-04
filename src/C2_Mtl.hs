{-# LANGUAGE Haskell2010 #-}
{-# LANGUAGE FlexibleContexts #-}
-- The Net instances for the transformers stay here so that the example reads
-- in one place; in a real project they would live next to the class.
{-# OPTIONS_GHC -Wno-orphans #-}
-- | C2. mtl style: transformers behind classes.
--
-- The mtl classes ('MonadReader', 'MonadState') are tagless final with
-- two-parameter classes: @MonadReader Config m@ means "m can read a
-- Config". The library needs MultiParamTypeClasses and
-- FunctionalDependencies; the code that uses it needs FlexibleContexts,
-- because the constraint mentions a concrete type ('Config').
--
-- It also shows how a capability of our own ('Net') goes through the stack:
-- it takes one instance per transformer (mtl's "n² problem").
module Main (main) where

import Capabilities (Net (..), Url, firstLine)
import Control.Monad.Reader (MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.State (MonadState, StateT, get, modify, runStateT)
import Control.Monad.Trans.Class (lift)

data Config = Config { server :: Url }

-- | No concrete stack: it asks for the capabilities as constraints. It is
-- the same program as in C1, without a single 'lift'.
summary :: (MonadReader Config m, MonadState Int m, Net m) => String -> m String
summary path = do
  cfg <- ask
  modify (+ 1)
  page <- httpGet (server cfg ++ path)
  n <- get
  return (firstLine page ++ " (request " ++ show n ++ ")")

-- * A base monad with the Net capability, and the instances to go through the stack

newtype Base a = Base { runBase :: IO a }

instance Functor Base where
  fmap f (Base io) = Base (fmap f io)

instance Applicative Base where
  pure = Base . pure
  Base f <*> Base x = Base (f <*> x)

instance Monad Base where
  Base io >>= k = Base (io >>= runBase . k)

instance Net Base where
  httpGet url = Base (return ("<title of " ++ url ++ ">\nrest"))

-- | One instance per transformer, so that Net goes through each layer.
instance Net m => Net (ReaderT r m) where
  httpGet = lift . httpGet

instance Net m => Net (StateT s m) where
  httpGet = lift . httpGet

main :: IO ()
main = do
  (results, requests) <- runBase (runStateT (runReaderT program cfg) 0)
  mapM_ putStrLn results
  putStrLn ("Requests made: " ++ show requests)
  where
    cfg = Config "https://example.org"
    program = mapM summary ["/docs", "/blog"]
