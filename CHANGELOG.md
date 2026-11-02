# Registro de cambios

Los cambios notables de este proyecto se anotan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). Todavía no hay
versiones publicadas.

## [Unreleased]

### Agregado

- Ejemplos de capacidades en Haskell en cuatro estilos: sólo tipos, tagless final,
  transformadores (`transformers` y estilo mtl) y un sistema de efectos con filas hecho a mano.
- Ejemplos en `debe-fallar/` que GHC tiene que rechazar.
- `compilar.sh`: compila y corre los ejemplos, comprueba que los de `debe-fallar/` no compilen y
  guarda todo lo que se ve en `salidas/`, incluidos los mensajes de error de GHC.
- Página explicativa que compara los cuatro estilos, generada con `artefacto/generar.py` desde una
  plantilla y los fragmentos de `src/`, `debe-fallar/` y `salidas/`. Enlaza al repositorio.
- Licencias: MIT para el código y CC BY-SA 4.0 para el texto.
- CI con GHC 9.6.7, 9.8.4, 9.10.3, 9.12.2 (referencia) y 9.14.1 (experimental), que compara las
  salidas y la página con las del repositorio.
- `README.en.md`, traducción al inglés, y la nota sobre cómo muestra GHC 9.14 los tipos inferidos
  de B.
- `CONTRIBUTING.md` y este registro de cambios.

### Cambiado

- `compilar.sh` elige la versión de GHC con `GHC=ghc-X.Y.Z`, compila en una carpeta por versión,
  sólo agrega GHCup al `PATH` si no hay un `ghc` a mano, y también cuenta como fallo un ejemplo
  que no corre.

### Arreglado

- `salidas/A_SoloTipos.txt` cambiaba de una máquina a otra (contaba las variables de entorno): los
  ejemplos corren ahora con un entorno fijo.

[Unreleased]: https://github.com/sawady/capacidades-haskell/commits/main
