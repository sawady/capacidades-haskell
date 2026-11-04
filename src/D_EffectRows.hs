{-# LANGUAGE FlexibleContexts #-}
-- | D. Effect systems with rows.
--
-- The program is polymorphic in the row @es@: it works in any row that
-- contains Net and Console. The handlers in "Effects" remove one effect at
-- a time; the order in which they are applied decides how each one is
-- interpreted.
module Main (main) where

import Effects

-- * The program: polymorphic in the row

-- | Works in any row that has Net and Console.
summary :: (Member Net es, Member Console es) => Url -> Eff es ()
summary url = do
  page <- httpGet url
  printLine (takeWhile (/= '\n') page)

fakePages :: Url -> String
fakePages url = "<title of " ++ url ++ ">\nrest of the page"

main :: IO ()
main = do
  putStrLn "Row [Net, Console], handled without IO:"
  let ((), output) = run (handleConsolePure (handleNet fakePages (summary "https://example.org")))
  mapM_ putStrLn output
  putStrLn "Row [Net, Console, EmbedIO], handled with real IO:"
  runIO (handleConsoleIO (handleNet fakePages (summary "https://example.org")))
