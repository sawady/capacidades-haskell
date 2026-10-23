{-# LANGUAGE Haskell2010 #-}
-- | Debe fallar: el programa pide Archivos y el intérprete no lo concede.
-- Elegir el intérprete es elegir qué capacidades se otorgan.
module Main (main) where

import Capacidades

resumenConArchivo :: (Red m, Archivos m, Consola m) => Url -> FilePath -> m ()
resumenConArchivo url ruta = do
  pagina <- httpGet url
  nota <- leerArchivo ruta
  imprimir (primeraLinea pagina ++ " / " ++ nota)

-- | Un intérprete con red y consola, pero sin archivos.
newtype App a = App { correrApp :: IO a }

instance Functor App where
  fmap f (App io) = App (fmap f io)

instance Applicative App where
  pure = App . pure
  App f <*> App x = App (f <*> x)

instance Monad App where
  App io >>= k = App (io >>= correrApp . k)

instance Red App where
  httpGet url = App (return url)

instance Consola App where
  imprimir = App . putStrLn

main :: IO ()
main = correrApp (resumenConArchivo "https://www.unq.edu.ar" "nota.txt")
