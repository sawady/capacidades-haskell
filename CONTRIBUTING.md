# Contribuir / Contributing

*[English below](#english).*

¡Gracias por el interés! Esto es material didáctico: importa tanto que el código compile como
que se entienda.

## Issues

Los issues de GitHub son bienvenidos: errores, un ejemplo o una explicación que no se entiende,
diferencias con otra versión de GHC, ideas para otros estilos de capacidades. Se pueden escribir
en castellano o en inglés. Si querés cambiar algo grande, abrí un issue antes para acordarlo.

## Cómo correrlo y probarlo

Hace falta GHC (por ejemplo, con [GHCup](https://www.haskell.org/ghcup/)); no hace falta `cabal`.

```
./compilar.sh                  # compila y corre src/, comprueba debe-fallar/, regenera salidas/
GHC=ghc-9.6.7 ./compilar.sh    # lo mismo con otra versión de GHC
python3 artefacto/generar.py   # regenera la página desde artefacto/plantilla.html
```

Probar es eso: el script tiene que terminar con 0 fallos (los ejemplos de `src/` compilan y
corren, los de `debe-fallar/` no compilan) y `git diff salidas/` sólo tiene que mostrar los
cambios que esperabas. El CI hace lo mismo con GHC 9.6 a 9.14.

`salidas/` y `artefacto/capacidades.html` se generan con la versión de referencia, GHC 9.12.2.
Si cambiás un ejemplo, commiteá también las salidas y la página regeneradas; si no tenés esa
versión, decilo en el PR.

## Estilo

- Haskell 2010 siempre que se pueda. Cada archivo declara sus extensiones con `LANGUAGE`; si un
  ejemplo necesita una nueva, explicá por qué en un comentario y en la tabla del README.
- Sólo `base`, `mtl` y `transformers`, que vienen con GHC.
- Nombres y comentarios en castellano, como el resto del material. Los dos READMEs se mantienen
  a la par: el de referencia es el castellano.
- La página (`artefacto/capacidades.html`) no se edita a mano: se cambia la plantilla o el código.

## Licencia

Al contribuir, aceptás que el código se publique bajo [MIT](LICENSE) y el texto bajo
[CC BY-SA 4.0](LICENSE-docs), como el resto del repositorio.

---

## English

Thanks for your interest! This is teaching material: it matters as much that the code compiles
as that it is easy to follow.

**Issues.** GitHub issues are welcome, in English or Spanish: bugs, an example or explanation that
is hard to follow, differences with another GHC version, ideas for other capability styles. For
larger changes, please open an issue first.

**Running and testing.** You need GHC (for example through [GHCup](https://www.haskell.org/ghcup/));
`cabal` is not needed.

```
./compilar.sh                  # build and run src/, check debe-fallar/, regenerate salidas/
GHC=ghc-9.6.7 ./compilar.sh    # the same with another GHC version
python3 artefacto/generar.py   # regenerate the page from artefacto/plantilla.html
```

The script must end with 0 failures (the examples in `src/` compile and run, the ones in
`debe-fallar/` are rejected), and `git diff salidas/` must show only the changes you expected. CI
does the same with GHC 9.6 to 9.14. `salidas/` and `artefacto/capacidades.html` are generated with
the reference version, GHC 9.12.2: if you change an example, commit the regenerated outputs and
page too, or say in the PR that you could not.

**Style.** Haskell 2010 whenever possible; every file declares its extensions with `LANGUAGE`, and
a new one needs a comment and a row in the README table. Only `base`, `mtl` and `transformers`.
Names and comments stay in Spanish, like the rest of the material; the Spanish README is the
reference and the English one is kept in sync. The page is never edited by hand.

**License.** By contributing you agree that code is published under [MIT](LICENSE) and text under
[CC BY-SA 4.0](LICENSE-docs), like the rest of the repository.
