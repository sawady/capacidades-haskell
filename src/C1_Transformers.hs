{-# LANGUAGE Haskell2010 #-}
-- | C1. Transformadores de mónadas con @transformers@, en Haskell 2010.
--
-- Cada capa de la pila es una capacidad: 'ReaderT' da acceso a una
-- configuración, 'StateT' a un contador. El tipo nombra la pila concreta,
-- con un orden fijo, y para usar una capa interna hay que levantar a mano
-- con 'lift'.
module Main (main) where

import Capacidades (Url, primeraLinea)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Reader (ReaderT, ask, runReaderT)
import Control.Monad.Trans.State (StateT, get, modify, runStateT)

data Config = Config { servidor :: Url }

-- | La pila: configuración, encima de un contador, encima de IO.
type App = ReaderT Config (StateT Int IO)

bajar :: Url -> App String
bajar url = do
  lift (modify (+ 1))                     -- capa StateT: una capa abajo
  return ("<título de " ++ url ++ ">\nresto")

resumen :: String -> App ()
resumen ruta = do
  cfg <- ask                               -- capa ReaderT: la de arriba
  pagina <- bajar (servidor cfg ++ ruta)
  n <- lift get
  lift (lift (putStrLn (primeraLinea pagina ++ " (pedido " ++ show n ++ ")")))
  -- IO está en el fondo de la pila: con lift (lift ...) se puede hacer
  -- cualquier IO. Los transformadores ordenan las capacidades, pero no
  -- sacan la autoridad ambiente de IO.

main :: IO ()
main = do
  ((), pedidos) <- runStateT (runReaderT (resumen "/posgrado" >> resumen "/carreras") cfg) 0
  putStrLn ("Pedidos hechos: " ++ show pedidos)
  where
    cfg = Config "https://www.unq.edu.ar"
