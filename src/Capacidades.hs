{-# LANGUAGE Haskell2010 #-}
-- | Capacidades como clases de tipos, en Haskell 2010 sin extensiones.
--
-- Cada clase es un permiso: una función que necesita la red pide @Red m@,
-- una que imprime pide @Consola m@. Como @m@ es abstracto, la función no
-- puede hacer nada más que lo que sus restricciones le conceden.
module Capacidades
  ( Url
  , Red (..)
  , Consola (..)
  , Archivos (..)
  , primeraLinea
  ) where

type Url = String

class Monad m => Red m where
  httpGet :: Url -> m String

class Monad m => Consola m where
  imprimir :: String -> m ()

class Monad m => Archivos m where
  leerArchivo :: FilePath -> m String

primeraLinea :: String -> String
primeraLinea = takeWhile (/= '\n')
