{-# LANGUAGE Haskell2010 #-}
{-# LANGUAGE FlexibleContexts #-}
-- Las instancias de Red para los transformadores quedan acá para que el
-- ejemplo se lea completo; en un proyecto irían junto a la clase.
{-# OPTIONS_GHC -Wno-orphans #-}
-- | C2. Estilo mtl: transformadores detrás de clases.
--
-- Las clases de mtl ('MonadReader', 'MonadState') son tagless final con
-- clases de dos parámetros: @MonadReader Config m@ es «m puede leer una
-- Config». La biblioteca necesita MultiParamTypeClasses y
-- FunctionalDependencies; el código que la usa necesita FlexibleContexts,
-- porque la restricción menciona un tipo concreto ('Config').
--
-- Además se ve cómo una capacidad propia ('Red') atraviesa la pila: hace
-- falta una instancia por cada transformador (el «problema n²» de mtl).
module Main (main) where

import Capacidades (Red (..), Url, primeraLinea)
import Control.Monad.Reader (MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.State (MonadState, StateT, get, modify, runStateT)
import Control.Monad.Trans.Class (lift)

data Config = Config { servidor :: Url }

-- | Sin pila concreta: pide las capacidades como restricciones. Es el mismo
-- programa que en C1, sin ningún 'lift'.
resumen :: (MonadReader Config m, MonadState Int m, Red m) => String -> m String
resumen ruta = do
  cfg <- ask
  modify (+ 1)
  pagina <- httpGet (servidor cfg ++ ruta)
  n <- get
  return (primeraLinea pagina ++ " (pedido " ++ show n ++ ")")

-- * Una base con la capacidad Red, y las instancias para atravesar la pila

newtype Base a = Base { correrBase :: IO a }

instance Functor Base where
  fmap f (Base io) = Base (fmap f io)

instance Applicative Base where
  pure = Base . pure
  Base f <*> Base x = Base (f <*> x)

instance Monad Base where
  Base io >>= k = Base (io >>= correrBase . k)

instance Red Base where
  httpGet url = Base (return ("<título de " ++ url ++ ">\nresto"))

-- | Una instancia por transformador para que Red atraviese cada capa.
instance Red m => Red (ReaderT r m) where
  httpGet = lift . httpGet

instance Red m => Red (StateT s m) where
  httpGet = lift . httpGet

main :: IO ()
main = do
  (lineas, pedidos) <- correrBase (runStateT (runReaderT programa cfg) 0)
  mapM_ putStrLn lineas
  putStrLn ("Pedidos hechos: " ++ show pedidos)
  where
    cfg = Config "https://www.unq.edu.ar"
    programa = mapM resumen ["/posgrado", "/carreras"]
