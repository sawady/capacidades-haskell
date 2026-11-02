#!/usr/bin/env bash
# Compila y corre cada ejemplo de src/, comprueba que los de debe-fallar/ no
# compilen, y guarda todo lo que se ve en salidas/.
#
# Por defecto usa el `ghc` del PATH (o el de GHCup). Para probar otra versión:
#   GHC=ghc-9.6.7 ./compilar.sh
# Sale con la cantidad de fallos: 0 si todo anduvo como se esperaba.
set -uo pipefail
cd "$(dirname "$0")"
command -v "${GHC:-ghc}" > /dev/null || export PATH="$HOME/.ghcup/bin:$PATH"
ghc="${GHC:-ghc}"
version=$("$ghc" --numeric-version) || { echo "No encuentro $ghc"; exit 1; }
build="build/$version"
GHCC="$ghc -Wall -isrc -outputdir $build"
mkdir -p "$build" salidas
fallos=0

# Los ejemplos corren con un entorno fijo para que las salidas sean
# reproducibles: A_SoloTipos cuenta las variables de entorno (siempre ven dos),
# y sin una codificación UTF-8 los acentos no se pueden imprimir.
entorno=(env -i "LANG=${LC_ALL:-${LANG:-C.UTF-8}}" PATH=/usr/bin:/bin)

"$ghc" --version > salidas/ghc-version.txt

for f in src/[A-Z]*_*.hs; do
  n=$(basename "$f" .hs)
  if $GHCC -o "$build/$n" "$f" > "$build/$n.log" 2>&1; then
    if "${entorno[@]}" "./$build/$n" > "salidas/$n.txt" 2>&1; then
      echo "ok        $n"
    else
      cat "salidas/$n.txt"; echo "FALLÓ AL CORRER $n"; fallos=$((fallos + 1))
    fi
  else
    cat "$build/$n.log"; echo "NO COMPILA $n"; fallos=$((fallos + 1))
  fi
done

for f in debe-fallar/*.hs; do
  n=$(basename "$f" .hs)
  if $GHCC -v0 -fno-code "$f" > "salidas/debe-fallar-$n.txt" 2>&1; then
    echo "COMPILÓ (debía fallar) $n"; fallos=$((fallos + 1))
  else
    echo "falla bien $n"
  fi
done

# Los tipos que GHC infiere para las funciones sin firma del ejemplo B
if ! $GHCC -v0 -Wno-missing-signatures -e ':t resumen' -e ':t resumenConArchivo' \
    src/B_TaglessFinal.hs > salidas/B_tipos-inferidos.txt 2>&1; then
  cat salidas/B_tipos-inferidos.txt; echo "FALLÓ ghc -e (tipos inferidos de B)"; fallos=$((fallos + 1))
fi

exit $fallos
