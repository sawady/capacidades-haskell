# Capacidades en Haskell

[![compilar](https://github.com/sawady/capacidades-haskell/actions/workflows/compilar.yml/badge.svg)](https://github.com/sawady/capacidades-haskell/actions/workflows/compilar.yml)

*[English version](README.en.md)*

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

Necesita GHC. Sólo usa `base`, `mtl` y `transformers`, que vienen con GHC, así que no hace falta
`cabal`. El script:

- compila y corre cada ejemplo de `src/`;
- comprueba que los de `debe-fallar/` **no** compilen;
- guarda en `salidas/` todo lo que se ve, incluidos los mensajes de error de GHC.

Los ejemplos corren con un entorno fijo (sólo `LANG` y `PATH`), para que las salidas no cambien de
una máquina a otra. El script termina con la cantidad de fallos: 0 si todo salió como se esperaba.

La versión de referencia es GHC 9.12.2, instalado con GHCup: con ella se generaron `salidas/` y la
página. Para probar otra versión:

```
GHC=ghc-9.6.7 ./compilar.sh
```

El CI (`.github/workflows/compilar.yml`) corre el script con GHC 9.6.7, 9.8.4, 9.10.3, 9.12.2 y,
como experimental, 9.14.1. Con la versión de referencia compara `salidas/` y la página
exactamente con lo que está en el repositorio. Con las demás, los mensajes de error de GHC sólo
cambian en líneas en blanco, así que la comparación las ignora. GHC 9.14.1 compila todo y rechaza
lo que debe, pero al mostrar los tipos inferidos de B expande los sinónimos (`[Char]` en lugar de
`Url` y `FilePath`), así que su comparación falla sin romper el CI.

## Los ejemplos

| Archivo | Qué muestra | Lenguaje |
|:--|:--|:--|
| `src/A_SoloTipos.hs` | Con `IO` el tipo no dice qué se usa. Los registros de funciones nombran las capacidades, y sobre una mónada abstracta además las hacen cumplir. | Haskell 2010 |
| `src/B_TaglessFinal.hs` | Capacidades como clases de un parámetro. GHC **infiere** qué capacidades usa cada función. Dos intérpretes: IO y uno puro para pruebas. | Haskell 2010 |
| `src/C1_Transformers.hs` | Una pila concreta de `transformers`, con `lift` a mano. | Haskell 2010 |
| `src/C2_Mtl.hs` | Estilo mtl: la misma pila detrás de clases. Una capacidad propia que atraviesa la pila. | Haskell 2010 + `FlexibleContexts` |
| `src/D_FilasDeEfectos.hs` y `src/Efectos.hs` | Un sistema de efectos con filas hecho a mano, en unas 120 líneas: la fila es una lista a nivel de tipos. | Haskell 2010 + 7 extensiones |
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

## La página explicativa

`artefacto/capacidades.html` explica los cuatro estilos y los compara. Se publicó como artefacto
en https://claude.ai/artifact/TDu94XyfdQX54Eak8AyqLp. No se edita a mano: se genera desde
`artefacto/plantilla.html` con

```
./compilar.sh && python3 artefacto/generar.py
```

El generador inserta en la plantilla los fragmentos de `src/`, `debe-fallar/` y `salidas/`, así
que el código y los errores de la página son siempre los que compila el script.

## Contribuir

Los issues son bienvenidos: ver [`CONTRIBUTING.md`](CONTRIBUTING.md). Los cambios están en
[`CHANGELOG.md`](CHANGELOG.md).

## Licencia

- El código (`src/`, `debe-fallar/`, `compilar.sh`, `artefacto/generar.py` y el CI) está bajo
  licencia MIT: ver [`LICENSE`](LICENSE).
- El texto (este README, `README.en.md` y la página explicativa, `artefacto/plantilla.html` y
  `artefacto/capacidades.html`) está bajo
  [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.es): ver
  [`LICENSE-docs`](LICENSE-docs). Los fragmentos de código que aparecen en el texto siguen bajo MIT.
