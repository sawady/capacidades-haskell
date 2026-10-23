{-# LANGUAGE FlexibleContexts #-}
-- | Debe fallar: la firma sólo admite Red en la fila, pero el cuerpo
-- imprime. Es el mismo rechazo que en B, ahora con filas de efectos.
module Main (main) where

import Efectos

soloRed :: Miembro Red es => Url -> Eff es ()
soloRed url = do
  pagina <- httpGet url
  imprimir pagina

main :: IO ()
main = return ()
