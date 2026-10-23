{-# LANGUAGE Haskell2010 #-}
-- | A. Sólo tipos: qué dice el tipo y qué no.
--
-- Tres versiones del mismo programa: bajar una página e imprimir su primera
-- línea.
module Main (main) where

import Capacidades (Url, primeraLinea)
import System.Environment (getEnvironment)

-- * 1. Con IO, el tipo no dice qué recursos se usan

-- | El tipo dice «hace IO», y nada más. Esta versión lee el entorno del
-- proceso sin que nadie se lo haya pedido, y el tipo no cambia.
resumenIO :: (Url -> IO String) -> Url -> IO ()
resumenIO bajar url = do
  pagina <- bajar url
  putStrLn (primeraLinea pagina)
  entorno <- getEnvironment
  putStrLn ("  (leyó " ++ show (length entorno) ++ " variables de entorno sin permiso)")

-- * 2. Capacidades como registros de funciones, todavía sobre IO

-- | Permiso para usar la red.
newtype RedIO = RedIO { httpGetIO :: Url -> IO String }

-- | Permiso para imprimir.
newtype ConsolaIO = ConsolaIO { imprimirIO :: String -> IO () }

-- | El tipo ahora nombra las capacidades que recibe, pero el resultado
-- sigue siendo @IO ()@: la función todavía podría hacer cualquier otra
-- cosa (es la «autoridad ambiente» de IO).
resumenRegistro :: RedIO -> ConsolaIO -> Url -> IO ()
resumenRegistro red consola url = do
  pagina <- httpGetIO red url
  imprimirIO consola (primeraLinea pagina)

-- * 3. Registros de funciones sobre una mónada abstracta

-- | Con @m@ abstracto, la función sólo puede hacer lo que le dan los
-- registros: no conoce IO, así que no puede leer el entorno ni escribir un
-- archivo. Es Haskell 2010 puro. La diferencia con las clases de tipos
-- (módulo B) es que acá las capacidades se pasan a mano, como argumentos.
data Red m = Red { httpGet :: Url -> m String }

data Consola m = Consola { imprimir :: String -> m () }

resumen :: Monad m => Red m -> Consola m -> Url -> m ()
resumen red consola url = do
  pagina <- httpGet red url
  imprimir consola (primeraLinea pagina)

-- | Una red simulada, para que el ejemplo no dependa de Internet.
bajarSimulado :: Url -> IO String
bajarSimulado url = return ("<título de " ++ url ++ ">\nresto de la página")

main :: IO ()
main = do
  putStrLn "1. Sólo IO:"
  resumenIO bajarSimulado "https://www.unq.edu.ar"
  putStrLn "2. Registros sobre IO:"
  resumenRegistro (RedIO bajarSimulado) (ConsolaIO putStrLn) "https://www.unq.edu.ar"
  putStrLn "3. Registros sobre una mónada abstracta:"
  resumen (Red bajarSimulado) (Consola putStrLn) "https://www.unq.edu.ar"
