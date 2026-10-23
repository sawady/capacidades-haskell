# Capacidades en Haskell

Cuatro maneras de decir, en el tipo de un programa Haskell, qué recursos puede usar:

- sólo tipos,
- clases de tipos al estilo *tagless final*,
- transformadores de mónadas,
- sistemas de efectos con filas.

Todos los ejemplos resuelven el mismo problema: bajar una página e imprimir su primera línea.
La red está simulada.

Es material de apoyo para el plan de doctorado «Restringir antes que validar» (UNQ). La tesis
necesita que las capacidades de un programa (red, archivos, consola) estén en su tipo, para que
un oráculo pueda rechazar lo que no se concedió mientras un modelo de lenguaje escribe el código.

## Cómo correrlo

```
./compilar.sh
```

Necesita GHC; se probó con 9.12.2 instalado con GHCup. Sólo usa `base`, `mtl` y `transformers`,
que vienen con GHC, así que no hace falta `cabal`. El script:

- compila y corre cada ejemplo de `src/`;
- comprueba que los de `debe-fallar/` **no** compilen;
- guarda en `salidas/` todo lo que se ve, incluidos los mensajes de error de GHC.

## Los ejemplos

| Archivo | Qué muestra | Lenguaje |
|:--|:--|:--|
| `src/A_SoloTipos.hs` | Con `IO` el tipo no dice qué se usa. Los registros de funciones nombran las capacidades, y sobre una mónada abstracta además las hacen cumplir. | Haskell 2010 |
| `src/B_TaglessFinal.hs` | Capacidades como clases de un parámetro. GHC **infiere** qué capacidades usa cada función. Dos intérpretes: IO y uno puro para pruebas. | Haskell 2010 |
| `src/C1_Transformers.hs` | Una pila concreta de `transformers`, con `lift` a mano. | Haskell 2010 |
| `src/C2_Mtl.hs` | Estilo mtl: la misma pila detrás de clases. Una capacidad propia que atraviesa la pila. | Haskell 2010 + `FlexibleContexts` |
| `src/D_FilasDeEfectos.hs` y `src/Efectos.hs` | Un sistema de efectos con filas hecho a mano, en unas 100 líneas: la fila es una lista a nivel de tipos. | Haskell 2010 + 7 extensiones |
| `debe-fallar/B_CapacidadNoConcedida.hs` | La firma concede red y consola, y el cuerpo lee un archivo. | Haskell 2010 |
| `debe-fallar/B_IODirecto.hs` | Con la mónada abstracta, ni siquiera se puede usar IO directamente. | Haskell 2010 |
| `debe-fallar/B_InterpreteSinCapacidad.hs` | El programa pide archivos y el intérprete no los concede. | Haskell 2010 |
| `debe-fallar/D_EfectoFueraDeLaFila.hs` | La fila sólo tiene red, y el cuerpo imprime. | con extensiones |

## Qué extensiones hacen falta, y por qué

| Estilo | Extensiones | Por qué |
|:--|:--|:--|
| Tagless final con clases de un parámetro | ninguna | `class Monad m => Red m` es Haskell 2010 |
| Transformadores (`transformers`) | ninguna | Las pilas son tipos comunes |
| Estilo mtl | `FlexibleContexts` en el código que la usa | `MonadReader Config m` menciona un tipo concreto. La biblioteca, además, usa `MultiParamTypeClasses` y `FunctionalDependencies` |
| Filas de efectos | `DataKinds`, `GADTs`, `KindSignatures`, `TypeOperators`, `MultiParamTypeClasses`, `FlexibleInstances`, `FlexibleContexts`, `EmptyCase` | La fila es una lista de tipos. Los efectos son GADTs. La pertenencia a la fila es una clase de dos parámetros con instancias superpuestas |

Una aclaración sobre «Haskell 2010»: el informe de 2010 no tiene `Applicative` como superclase
de `Monad`, y GHC sí. Los ejemplos escriben esa instancia, como pide el GHC actual.
