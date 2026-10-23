{-# LANGUAGE FlexibleContexts #-}
-- | D. Sistemas de efectos con filas.
--
-- El programa es polimórfico en la fila @es@: funciona en cualquier fila que
-- contenga Red y Consola. Los manejadores de "Efectos" sacan un efecto por
-- vez; el orden en que se aplican decide cómo se interpreta cada uno.
module Main (main) where

import Efectos

-- * El programa: polimórfico en la fila

-- | Funciona en cualquier fila que tenga Red y Consola.
resumen :: (Miembro Red es, Miembro Consola es) => Url -> Eff es ()
resumen url = do
  pagina <- httpGet url
  imprimir (takeWhile (/= '\n') pagina)

tabla :: Url -> String
tabla url = "<título de " ++ url ++ ">\nresto de la página"

main :: IO ()
main = do
  putStrLn "Fila [Red, Consola], manejada sin IO:"
  let ((), lineas) = correr (consolaPura (manejarRed tabla (resumen "https://www.unq.edu.ar")))
  mapM_ putStrLn lineas
  putStrLn "Fila [Red, Consola, EnIO], manejada con IO real:"
  correrIO (consolaIO (manejarRed tabla (resumen "https://www.unq.edu.ar")))
