{-# LANGUAGE Haskell2010 #-}
-- The functions without signatures are on purpose: they show what GHC infers.
{-# OPTIONS_GHC -Wno-missing-signatures #-}
-- | B. Tagless final: capabilities as type classes.
--
-- The same program as in A, but the capabilities arrive as class
-- constraints instead of arguments. This is Haskell 2010 with no extensions.
module Main (main) where

import Capabilities
import Control.Monad.Trans.State (State, modify, runState)

-- | No type signature on purpose: GHC infers
-- @summary :: (Net m, Console m) => Url -> m ()@.
-- The inferred constraints are exactly the capabilities the code uses.
-- That is what the thesis's oracle needs to know.
summary url = do
  page <- httpGet url
  printLine (firstLine page)

-- | Also uses files: GHC infers @(Net m, Files m, Console m)@.
summaryWithFile url path = do
  page <- httpGet url
  note <- readTextFile path
  printLine (firstLine page ++ " / " ++ note)

-- * Interpreter 1: IO

-- | Our own monad over IO. It only has the capabilities we wrote an
-- instance for: there is no 'Files' instance for 'App'.
newtype App a = App { runApp :: IO a }

instance Functor App where
  fmap f (App io) = App (fmap f io)

instance Applicative App where
  pure = App . pure
  App f <*> App x = App (f <*> x)

instance Monad App where
  App io >>= k = App (io >>= runApp . k)

instance Net App where
  httpGet url = App (return ("<title of " ++ url ++ ">\nrest of the page"))

instance Console App where
  printLine = App . putStrLn

-- * Interpreter 2: pure, for testing

-- | The same program, interpreted without IO: the console collects lines in
-- a list and the network answers from a fixed table.
newtype Test a = Test { runTest :: State [String] a }

instance Functor Test where
  fmap f (Test s) = Test (fmap f s)

instance Applicative Test where
  pure = Test . pure
  Test f <*> Test x = Test (f <*> x)

instance Monad Test where
  Test s >>= k = Test (s >>= runTest . k)

instance Net Test where
  httpGet url = return ("test page for " ++ url)

instance Console Test where
  printLine line = Test (modify (++ [line]))

instance Files Test where
  readTextFile path = return ("simulated contents of " ++ path)

main :: IO ()
main = do
  putStrLn "IO interpreter:"
  runApp (summary "https://example.org")
  putStrLn "Test interpreter (output captured in a list):"
  let ((), output) = runState (runTest (summary "https://example.org")) []
  mapM_ putStrLn output
  let ((), output2) = runState (runTest (summaryWithFile "https://example.org" "note.txt")) []
  mapM_ putStrLn output2
  -- runApp (summaryWithFile ...) does not compile: App does not grant Files.
