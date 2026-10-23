#!/usr/bin/env bash
# Compila y corre cada ejemplo de src/, comprueba que los de debe-fallar/ no
# compilen, y guarda todo lo que se ve en salidas/.
set -uo pipefail
cd "$(dirname "$0")"
export PATH="$HOME/.ghcup/bin:$PATH"
GHC="ghc -Wall -isrc -outputdir build"
mkdir -p build salidas
fallos=0

ghc --version > salidas/ghc-version.txt

for f in src/[A-Z]*_*.hs; do
  n=$(basename "$f" .hs)
  if $GHC -o "build/$n" "$f" > "build/$n.log" 2>&1; then
    "./build/$n" > "salidas/$n.txt" 2>&1
    echo "ok        $n"
  else
    cat "build/$n.log"; echo "NO COMPILA $n"; fallos=$((fallos + 1))
  fi
done

for f in debe-fallar/*.hs; do
  n=$(basename "$f" .hs)
  if $GHC -v0 -fno-code "$f" > "salidas/debe-fallar-$n.txt" 2>&1; then
    echo "COMPILÓ (debía fallar) $n"; fallos=$((fallos + 1))
  else
    echo "falla bien $n"
  fi
done

# Los tipos que GHC infiere para las funciones sin firma del ejemplo B
$GHC -v0 -Wno-missing-signatures -e ':t resumen' -e ':t resumenConArchivo' src/B_TaglessFinal.hs > salidas/B_tipos-inferidos.txt 2>&1

exit $fallos
