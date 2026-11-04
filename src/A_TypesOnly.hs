{-# LANGUAGE Haskell2010 #-}
-- | A. Types only: what the type says and what it does not.
--
-- Three versions of the same program: download a page and print its first
-- line.
module Main (main) where

import Capabilities (Url, firstLine)
import System.Environment (getEnvironment)

-- * 1. With IO, the type does not say which resources are used

-- | The type says "does IO", and nothing else. This version reads the
-- process environment without anyone asking it to, and the type does not
-- change.
summaryIO :: (Url -> IO String) -> Url -> IO ()
summaryIO fetch url = do
  page <- fetch url
  putStrLn (firstLine page)
  env <- getEnvironment
  putStrLn ("  (read " ++ show (length env) ++ " environment variables without permission)")

-- * 2. Capabilities as records of functions, still over IO

-- | Permission to use the network.
newtype NetIO = NetIO { httpGetIO :: Url -> IO String }

-- | Permission to print.
newtype ConsoleIO = ConsoleIO { printLineIO :: String -> IO () }

-- | The type now names the capabilities it receives, but the result is
-- still @IO ()@: the function could still do anything else (that is the
-- "ambient authority" of IO).
summaryRecords :: NetIO -> ConsoleIO -> Url -> IO ()
summaryRecords net console url = do
  page <- httpGetIO net url
  printLineIO console (firstLine page)

-- * 3. Records of functions over an abstract monad

-- | With an abstract @m@, the function can only do what the records give
-- it: it does not know IO, so it cannot read the environment or write a
-- file. This is plain Haskell 2010. The difference from type classes
-- (module B) is that here the capabilities are passed by hand, as
-- arguments.
data Net m = Net { httpGet :: Url -> m String }

data Console m = Console { printLine :: String -> m () }

summary :: Monad m => Net m -> Console m -> Url -> m ()
summary net console url = do
  page <- httpGet net url
  printLine console (firstLine page)

-- | A simulated network, so that the example does not depend on the
-- Internet.
fakeFetch :: Url -> IO String
fakeFetch url = return ("<title of " ++ url ++ ">\nrest of the page")

main :: IO ()
main = do
  putStrLn "1. IO only:"
  summaryIO fakeFetch "https://example.org"
  putStrLn "2. Records over IO:"
  summaryRecords (NetIO fakeFetch) (ConsoleIO putStrLn) "https://example.org"
  putStrLn "3. Records over an abstract monad:"
  summary (Net fakeFetch) (Console putStrLn) "https://example.org"
