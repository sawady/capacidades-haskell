{-# LANGUAGE FlexibleContexts #-}
-- | Must fail: the signature only admits Net in the row, but the body
-- prints. It is the same rejection as in B, now with effect rows.
module Main (main) where

import Effects

netOnly :: Member Net es => Url -> Eff es ()
netOnly url = do
  page <- httpGet url
  printLine page

main :: IO ()
main = return ()
