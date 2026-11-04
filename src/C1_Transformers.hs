{-# LANGUAGE Haskell2010 #-}
-- | C1. Monad transformers with @transformers@, in Haskell 2010.
--
-- Each layer of the stack is a capability: 'ReaderT' gives access to a
-- configuration, 'StateT' to a counter. The type names the concrete stack,
-- in a fixed order, and using an inner layer means lifting by hand with
-- 'lift'.
module Main (main) where

import Capabilities (Url, firstLine)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Reader (ReaderT, ask, runReaderT)
import Control.Monad.Trans.State (StateT, get, modify, runStateT)

data Config = Config { server :: Url }

-- | The stack: configuration, on top of a counter, on top of IO.
type App = ReaderT Config (StateT Int IO)

fetch :: Url -> App String
fetch url = do
  lift (modify (+ 1))                     -- StateT layer: one layer down
  return ("<title of " ++ url ++ ">\nrest")

summary :: String -> App ()
summary path = do
  cfg <- ask                               -- ReaderT layer: the top one
  page <- fetch (server cfg ++ path)
  n <- lift get
  lift (lift (putStrLn (firstLine page ++ " (request " ++ show n ++ ")")))
  -- IO is at the bottom of the stack: with lift (lift ...) any IO can be
  -- done. Transformers put the capabilities in order, but they do not
  -- remove the ambient authority of IO.

main :: IO ()
main = do
  ((), requests) <- runStateT (runReaderT (summary "/docs" >> summary "/blog") cfg) 0
  putStrLn ("Requests made: " ++ show requests)
  where
    cfg = Config "https://example.org"
