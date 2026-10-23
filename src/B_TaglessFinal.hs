{-# LANGUAGE Haskell2010 #-}
-- Las funciones sin firma son a propósito: muestran lo que GHC infiere.
{-# OPTIONS_GHC -Wno-missing-signatures #-}
-- | B. Tagless final: capacidades como clases de tipos.
--
-- El mismo programa que en A, pero las capacidades llegan por restricciones
-- de clase en lugar de argumentos. Es Haskell 2010 sin extensiones.
module Main (main) where

import Capacidades
import Control.Monad.Trans.State (State, modify, runState)

-- | Sin firma de tipos a propósito: GHC infiere
-- @resumen :: (Red m, Consola m) => Url -> m ()@.
-- Las restricciones inferidas son exactamente las capacidades que usa el
-- código. Eso es lo que el oráculo de la tesis necesita saber.
resumen url = do
  pagina <- httpGet url
  imprimir (primeraLinea pagina)

-- | Usa también archivos: GHC infiere @(Red m, Archivos m, Consola m)@.
resumenConArchivo url ruta = do
  pagina <- httpGet url
  nota <- leerArchivo ruta
  imprimir (primeraLinea pagina ++ " / " ++ nota)

-- * Intérprete 1: IO

-- | Una mónada propia sobre IO. Sólo tiene las capacidades para las que
-- escribimos una instancia: no hay instancia de 'Archivos' para 'App'.
newtype App a = App { correrApp :: IO a }

instance Functor App where
  fmap f (App io) = App (fmap f io)

instance Applicative App where
  pure = App . pure
  App f <*> App x = App (f <*> x)

instance Monad App where
  App io >>= k = App (io >>= correrApp . k)

instance Red App where
  httpGet url = App (return ("<título de " ++ url ++ ">\nresto de la página"))

instance Consola App where
  imprimir = App . putStrLn

-- * Intérprete 2: puro, para pruebas

-- | El mismo programa, interpretado sin IO: la consola acumula líneas en una
-- lista y la red responde desde una tabla fija.
newtype Prueba a = Prueba { correrPrueba :: State [String] a }

instance Functor Prueba where
  fmap f (Prueba s) = Prueba (fmap f s)

instance Applicative Prueba where
  pure = Prueba . pure
  Prueba f <*> Prueba x = Prueba (f <*> x)

instance Monad Prueba where
  Prueba s >>= k = Prueba (s >>= correrPrueba . k)

instance Red Prueba where
  httpGet url = return ("página de prueba para " ++ url)

instance Consola Prueba where
  imprimir linea = Prueba (modify (++ [linea]))

instance Archivos Prueba where
  leerArchivo ruta = return ("contenido simulado de " ++ ruta)

main :: IO ()
main = do
  putStrLn "Intérprete IO:"
  correrApp (resumen "https://www.unq.edu.ar")
  putStrLn "Intérprete de prueba (salida capturada en una lista):"
  let ((), salida) = runState (correrPrueba (resumen "https://www.unq.edu.ar")) []
  mapM_ putStrLn salida
  let ((), salida2) = runState (correrPrueba (resumenConArchivo "https://www.unq.edu.ar" "nota.txt")) []
  mapM_ putStrLn salida2
  -- correrApp (resumenConArchivo ...) no compila: App no concede Archivos.
