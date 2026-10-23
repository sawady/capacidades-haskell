{-# LANGUAGE Haskell2010 #-}
-- | Debe fallar: con la mónada abstracta, ni siquiera se puede usar IO
-- directamente. Es la diferencia con el ejemplo A.1, donde el tipo IO lo
-- permitía todo.
module Main (main) where

import Capacidades

resumen :: (Red m, Consola m) => Url -> m ()
resumen url = do
  pagina <- httpGet url
  putStrLn (primeraLinea pagina)

main :: IO ()
main = return ()
