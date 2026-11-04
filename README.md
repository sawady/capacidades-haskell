# Capabilities in Haskell

[![build](https://github.com/sawady/haskell-capabilities/actions/workflows/build.yml/badge.svg)](https://github.com/sawady/haskell-capabilities/actions/workflows/build.yml)
[![Sponsor](https://img.shields.io/github/sponsors/sawady?label=Sponsor&logo=GitHub)](https://github.com/sponsors/sawady)

Four ways of stating, in the type of a Haskell program, which resources it may use:

- types only,
- type classes in the *tagless final* style,
- monad transformers,
- effect systems with rows.

All the examples solve the same problem: download a page and print its first line.
The network is simulated.

**Read the guide:** https://sawady.github.io/haskell-capabilities/ explains the four styles and
compares them, with the code and the GHC errors from this repository.

This is supporting material for the doctoral plan «Restringir antes que validar» ("Restrict before
validating", Universidad Nacional de Quilmes, UNQ). The thesis needs a program's capabilities
(network, files, console) to be in its type, so that an oracle can reject whatever was not granted
while a language model writes the code.

The project was originally written in Spanish, as `capacidades-haskell`; that version is kept
at the tag [`v-es`](https://github.com/sawady/haskell-capabilities/tree/v-es) (commit `4d808dd`).

## How to run it

```
./build.sh
```

It needs GHC. It only uses `base`, `mtl` and `transformers`, which ship with GHC, so `cabal` is not
needed. The script:

- builds and runs each example in `src/`;
- checks that the ones in `must-fail/` do **not** compile;
- saves to `outputs/` everything that is shown, including GHC's error messages.

The examples run with a fixed environment (only `LANG` and `PATH`), so that the outputs do not
change from one machine to another. The script exits with the number of failures: 0 if everything
went as expected.

The reference version is GHC 9.12.2, installed with GHCup: `outputs/` and the page were generated
with it. To try another version:

```
GHC=ghc-9.6.7 ./build.sh
```

CI (`.github/workflows/build.yml`) runs the script with GHC 9.6.7, 9.8.4, 9.10.3, 9.12.2 and, as
experimental, 9.14.1. With the reference version it compares `outputs/` and the page exactly
against what is in the repository. With the others, GHC's error messages only differ in blank
lines, so the comparison ignores them. GHC 9.14.1 compiles everything and rejects what it should,
but when showing B's inferred types it expands the synonyms (`[Char]` instead of `Url` and
`FilePath`), so its comparison fails without breaking CI.

## The examples

| File | What it shows | Language |
|:--|:--|:--|
| `src/A_TypesOnly.hs` | With `IO` the type does not say what is used. Records of functions name the capabilities, and over an abstract monad they also enforce them. | Haskell 2010 |
| `src/B_TaglessFinal.hs` | Capabilities as single-parameter classes (from `src/Capabilities.hs`). GHC **infers** which capabilities each function uses. Two interpreters: IO and a pure one for testing. | Haskell 2010 |
| `src/C1_Transformers.hs` | A concrete `transformers` stack, with `lift` by hand. | Haskell 2010 |
| `src/C2_Mtl.hs` | mtl style: the same stack behind classes. A capability of our own that goes through the stack. | Haskell 2010 + `FlexibleContexts` |
| `src/D_EffectRows.hs` and `src/Effects.hs` | A hand-made effect system with rows, in about 120 lines: the row is a type-level list. | Haskell 2010 + 7 extensions |
| `must-fail/B_CapabilityNotGranted.hs` | The signature grants network and console, and the body reads a file. | Haskell 2010 |
| `must-fail/B_DirectIO.hs` | With the abstract monad, not even IO can be used directly. | Haskell 2010 |
| `must-fail/B_InterpreterLacksCapability.hs` | The program asks for files and the interpreter does not grant them. | Haskell 2010 |
| `must-fail/D_EffectNotInRow.hs` | The row only has network, and the body prints. | with extensions |

## Which extensions are needed, and why

| Style | Extensions | Why |
|:--|:--|:--|
| Tagless final with single-parameter classes | none | `class Monad m => Net m` is Haskell 2010 |
| Transformers (`transformers`) | none | Stacks are ordinary types |
| mtl style | `FlexibleContexts` in the code that uses it | `MonadReader Config m` mentions a concrete type. The library, in addition, uses `MultiParamTypeClasses` and `FunctionalDependencies` |
| Effect rows | `DataKinds`, `GADTs`, `KindSignatures`, `TypeOperators`, `MultiParamTypeClasses`, `FlexibleInstances`, `FlexibleContexts`, `EmptyCase` | The row is a list of types. Effects are GADTs. Row membership is a two-parameter class with overlapping instances |

A clarification about "Haskell 2010": the 2010 report does not have `Applicative` as a superclass
of `Monad`, and GHC does. The examples write that instance, as current GHC requires.

## The explanatory page

The guide is published at https://sawady.github.io/haskell-capabilities/. Its source is
`site/index.html`, a single HTML file with no scripts and no external dependencies. It is not
edited by hand: it is generated from `site/template.html` with

```
./build.sh && python3 site/build.py
```

The generator inserts into the template the fragments of `src/`, `must-fail/` and `outputs/`, and
highlights the Haskell code, so the code and the errors on the page are always the ones the script
compiles. `.github/workflows/pages.yml` publishes it to GitHub Pages.

## Contributing

Issues are welcome: see [`CONTRIBUTING.md`](CONTRIBUTING.md). Changes are listed in
[`CHANGELOG.md`](CHANGELOG.md).

## Sponsoring

This project is free software. If it is useful to you, you can support its development through
[GitHub Sponsors](https://github.com/sponsors/sawady).

## License

- The code (`src/`, `must-fail/`, `build.sh`, `site/build.py` and the CI workflows) is under the
  BSD 3-Clause license: see [`LICENSE`](LICENSE).
- The text (this README and the explanatory page, `site/template.html` and `site/index.html`) is
  under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/): see
  [`LICENSE-docs`](LICENSE-docs). Code fragments that appear in the text remain under BSD 3-Clause.
