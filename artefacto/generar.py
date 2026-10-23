#!/usr/bin/env python3
"""Arma artefacto/capacidades.html a partir de artefacto/plantilla.html.

Cada marca <!--@archivo|desde|hasta--> se reemplaza por las líneas del archivo
que van desde la primera que contiene «desde» hasta la primera posterior que
contiene «hasta», ambas incluidas y escapadas para HTML; un cuarto campo +N
agrega N líneas más. Sin «desde» ni «hasta»
entra el archivo entero. Así el código de la página es el mismo que compila
./compilar.sh, y las salidas son las que guardó en salidas/.
"""
import html
import pathlib
import re
import sys

raiz = pathlib.Path(__file__).resolve().parent.parent


def fragmento(m):
    partes = m.group(1).split('|')
    lineas = (raiz / partes[0]).read_text(encoding='utf-8').splitlines()
    if len(partes) == 1:
        elegidas = lineas
    else:
        desde, hasta = partes[1], partes[2]
        i = next(n for n, l in enumerate(lineas) if desde in l)
        j = next(n for n in range(i, len(lineas)) if hasta in lineas[n])
        extra = int(partes[3]) if len(partes) > 3 else 0
        elegidas = lineas[i:j + 1 + extra]
    return html.escape('\n'.join(elegidas).rstrip(), quote=False)


plantilla = (raiz / 'artefacto/plantilla.html').read_text(encoding='utf-8')
salida = re.sub(r'<!--@(.+?)-->', fragmento, plantilla)
(raiz / 'artefacto/capacidades.html').write_text(salida, encoding='utf-8')
print('artefacto/capacidades.html', len(salida), 'bytes', file=sys.stderr)
