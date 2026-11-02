# Capabilities in Haskell

[![compilar](https://github.com/sawady/capacidades-haskell/actions/workflows/compilar.yml/badge.svg)](https://github.com/sawady/capacidades-haskell/actions/workflows/compilar.yml)

*[Versión en español](README.md)* — this is a translation of the Spanish README, which is the
reference version.

Four ways of stating, in the type of a Haskell program, which resources it may use:

- types alone,
- type classes in the *tagless final* style,
- monad transformers,
- effect systems with rows.

All the examples solve the same problem: download a page and print its first line.
The network is simulated.

This is supporting material for the doctoral plan «Restringir antes que validar» ("Restrict before
validating", Universidad Nacional de Quilmes, UNQ). The thesis needs a program's capabilities
(network, files, console) to be in its type, so that an oracle can reject whatever was not granted
while a language model writes the code.

> **A note on language.** The code, its comments, the file names and the program output are in
> Spanish. A short glossary of the names that matter most: *capacidad* = capability, *Red* =
> Network, *Consola* = Console, *Archivos* = Files, *httpGet* / *imprimir* / *leerArchivo* = HTTP
> get / print / read file, *resumen* = summary (the example program), *primeraLinea* = first line,
> *intérprete* = interpreter, *Eff* / *Miembro* / *fila* = Eff / Member / row, *manejar* = handle,
> *correr* = run, *compilar* = compile, *salidas* = outputs, *debe-fallar* = must-fail.

## How to run it

```
./compilar.sh
```

It needs GHC. It only uses `base`, `mtl` and `transformers`, which ship with GHC, so `cabal` is not
needed. The script:

- compiles and runs each example in `src/`;
- checks that the ones in `debe-fallar/` do **not** compile;
- saves to `salidas/` everything that is shown, including GHC's error messages.

The examples run with a fixed environment (only `LANG` and `PATH`), so that the outputs do not
change from one machine to another. The script exits with the number of failures: 0 if everything
went as expected.

The reference version is GHC 9.12.2, installed with GHCup: `salidas/` and the page were generated
with it. To try another version:

```
GHC=ghc-9.6.7 ./compilar.sh
```

CI (`.github/workflows/compilar.yml`) runs the script with GHC 9.6.7, 9.8.4, 9.10.3, 9.12.2 and,
as experimental, 9.14.1. With the reference version it compares `salidas/` and the page exactly
against what is in the repository. With the others, GHC's error messages only differ in blank
lines, so the comparison ignores them. GHC 9.14.1 compiles everything and rejects what it should,
but when showing B's inferred types it expands the synonyms (`[Char]` instead of `Url` and
`FilePath`), so its comparison fails without breaking CI.

## The examples

| File | What it shows | Language |
|:--|:--|:--|
| `src/A_SoloTipos.hs` | With `IO` the type does not say what is used. Records of functions name the capabilities, and over an abstract monad they also enforce them. | Haskell 2010 |
| `src/B_TaglessFinal.hs` | Capabilities as single-parameter classes. GHC **infers** which capabilities each function uses. Two interpreters: IO and a pure one for testing. | Haskell 2010 |
| `src/C1_Transformers.hs` | A concrete `transformers` stack, with `lift` by hand. | Haskell 2010 |
| `src/C2_Mtl.hs` | mtl style: the same stack behind classes. A custom capability that goes through the stack. | Haskell 2010 + `FlexibleContexts` |
| `src/D_FilasDeEfectos.hs` and `src/Efectos.hs` | A hand-made effect system with rows, in about 120 lines: the row is a type-level list. | Haskell 2010 + 7 extensions |
| `debe-fallar/B_CapacidadNoConcedida.hs` | The signature grants network and console, and the body reads a file. | Haskell 2010 |
| `debe-fallar/B_IODirecto.hs` | With the abstract monad, not even IO can be used directly. | Haskell 2010 |
| `debe-fallar/B_InterpreteSinCapacidad.hs` | The program asks for files and the interpreter does not grant them. | Haskell 2010 |
| `debe-fallar/D_EfectoFueraDeLaFila.hs` | The row only has network, and the body prints. | with extensions |

## Which extensions are needed, and why

| Style | Extensions | Why |
|:--|:--|:--|
| Tagless final with single-parameter classes | none | `class Monad m => Red m` is Haskell 2010 |
| Transformers (`transformers`) | none | Stacks are ordinary types |
| mtl style | `FlexibleContexts` in the code that uses it | `MonadReader Config m` mentions a concrete type. The library, in addition, uses `MultiParamTypeClasses` and `FunctionalDependencies` |
| Effect rows | `DataKinds`, `GADTs`, `KindSignatures`, `TypeOperators`, `MultiParamTypeClasses`, `FlexibleInstances`, `FlexibleContexts`, `EmptyCase` | The row is a list of types. Effects are GADTs. Row membership is a two-parameter class with overlapping instances |

A clarification about «Haskell 2010»: the 2010 report does not have `Applicative` as a superclass
of `Monad`, and GHC does. The examples write that instance, as current GHC requires.

## The explanatory page

`artefacto/capacidades.html` (in Spanish) explains the four styles and compares them. It was
published as an artifact at https://claude.ai/artifact/TDu94XyfdQX54Eak8AyqLp. It is not edited by
hand: it is generated from `artefacto/plantilla.html` with

```
./compilar.sh && python3 artefacto/generar.py
```

The generator inserts into the template the fragments of `src/`, `debe-fallar/` and `salidas/`, so
the code and the errors on the page are always the ones the script compiles.

## Contributing

Issues are welcome: see [`CONTRIBUTING.md`](CONTRIBUTING.md). Changes are listed (in Spanish) in
[`CHANGELOG.md`](CHANGELOG.md).

## License

- The code (`src/`, `debe-fallar/`, `compilar.sh`, `artefacto/generar.py` and CI) is under the
  MIT license: see [`LICENSE`](LICENSE).
- The text (the README in Spanish, this translation and the explanatory page,
  `artefacto/plantilla.html` and `artefacto/capacidades.html`) is under
  [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/): see
  [`LICENSE-docs`](LICENSE-docs). Code fragments that appear in the text remain under MIT.
