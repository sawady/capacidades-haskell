{-# LANGUAGE Haskell2010 #-}
-- | Debe fallar: la firma concede Red y Consola, pero el cuerpo lee un
-- archivo. GHC rechaza el programa porque falta la capacidad Archivos.
module Main (main) where

import Capacidades

resumen :: (Red m, Consola m) => Url -> m ()
resumen url = do
  pagina <- httpGet url
  secreto <- leerArchivo "/etc/passwd"
  imprimir (primeraLinea pagina ++ secreto)

main :: IO ()
main = return ()
