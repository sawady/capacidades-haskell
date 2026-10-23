{-# LANGUAGE DataKinds #-}
{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeOperators #-}
-- | Sistema de efectos con filas, hecho a mano (lo usa el ejemplo D).
--
-- Una computación de tipo @Eff es a@ puede usar los efectos de la lista
-- @es@ (la «fila»). Una función polimórfica en @es@ que pide
-- @Miembro Red es@ funciona en cualquier fila que contenga Red: eso es el
-- polimorfismo de filas. Un manejador saca un efecto de la fila y lo
-- interpreta; cuando la fila queda vacía, la computación es pura.
--
-- Es una versión mínima de lo que hacen bibliotecas como effectful,
-- polysemy o fused-effects, y lenguajes como Koka. Necesita varias
-- extensiones: la fila es una lista a nivel de tipos.
module Efectos
  ( Url
  , Eff
  , Miembro
  , Red (..)
  , Consola (..)
  , EnIO (..)
  , httpGet
  , imprimir
  , manejarRed
  , consolaPura
  , consolaIO
  , correr
  , correrIO
  ) where

import Data.Kind (Type)

type Url = String

-- * La fila y la unión abierta

-- | Un pedido de alguno de los efectos de la fila @es@.
data Union (es :: [Type -> Type]) (a :: Type) where
  Aqui :: e a -> Union (e ': es) a
  Alla :: Union es a -> Union (e ': es) a

-- | @Miembro e es@: el efecto @e@ está en la fila @es@.
class Miembro (e :: Type -> Type) (es :: [Type -> Type]) where
  inyectar :: e a -> Union es a

instance {-# OVERLAPPING #-} Miembro e (e ': es) where
  inyectar = Aqui

instance Miembro e es => Miembro e (f ': es) where
  inyectar = Alla . inyectar

-- * La mónada de efectos (una mónada libre sobre la unión)

data Eff (es :: [Type -> Type]) a where
  Puro :: a -> Eff es a
  Pedir :: Union es x -> (x -> Eff es a) -> Eff es a

instance Functor (Eff es) where
  fmap f (Puro a) = Puro (f a)
  fmap f (Pedir u k) = Pedir u (fmap f . k)

instance Applicative (Eff es) where
  pure = Puro
  mf <*> mx = mf >>= \f -> fmap f mx

instance Monad (Eff es) where
  Puro a >>= f = f a
  Pedir u k >>= f = Pedir u (\x -> k x >>= f)

enviar :: Miembro e es => e a -> Eff es a
enviar op = Pedir (inyectar op) Puro

-- * Los efectos: sólo declaran operaciones, no dicen cómo se hacen

data Red a where
  HttpGet :: Url -> Red String

data Consola a where
  Imprimir :: String -> Consola ()

-- | Embebe IO como un efecto más, que va al final de la fila.
data EnIO a where
  EnIO :: IO a -> EnIO a

httpGet :: Miembro Red es => Url -> Eff es String
httpGet = enviar . HttpGet

imprimir :: Miembro Consola es => String -> Eff es ()
imprimir = enviar . Imprimir

-- * Manejadores: cada uno saca un efecto de la fila

-- | Interpreta Red con una tabla fija.
manejarRed :: (Url -> String) -> Eff (Red ': es) a -> Eff es a
manejarRed _ (Puro a) = Puro a
manejarRed tabla (Pedir (Aqui (HttpGet url)) k) = manejarRed tabla (k (tabla url))
manejarRed tabla (Pedir (Alla u) k) = Pedir u (manejarRed tabla . k)

-- | Interpreta Consola sin IO, acumulando las líneas.
consolaPura :: Eff (Consola ': es) a -> Eff es (a, [String])
consolaPura (Puro a) = Puro (a, [])
consolaPura (Pedir (Aqui (Imprimir s)) k) = do
  (a, resto) <- consolaPura (k ())
  return (a, s : resto)
consolaPura (Pedir (Alla u) k) = Pedir u (consolaPura . k)

-- | Interpreta Consola con IO real, que tiene que estar más abajo en la fila.
consolaIO :: Miembro EnIO es => Eff (Consola ': es) a -> Eff es a
consolaIO (Puro a) = Puro a
consolaIO (Pedir (Aqui (Imprimir s)) k) = enviar (EnIO (putStrLn s)) >>= consolaIO . k
consolaIO (Pedir (Alla u) k) = Pedir u (consolaIO . k)

-- | Con la fila vacía no queda ningún efecto: el resultado es puro.
correr :: Eff '[] a -> a
correr (Puro a) = a
correr (Pedir u _) = case u of {}

correrIO :: Eff '[EnIO] a -> IO a
correrIO (Puro a) = return a
correrIO (Pedir (Aqui (EnIO io)) k) = io >>= correrIO . k
correrIO (Pedir (Alla u) _) = case u of {}
