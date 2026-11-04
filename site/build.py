#!/usr/bin/env python3
"""Builds site/index.html from site/template.html.

Each marker <!--@file|from|to--> is replaced by the lines of the file that go
from the first one containing "from" to the first later one containing "to",
both included and escaped for HTML; a fourth field +N adds N more lines.
Without "from" and "to" the whole file goes in. Haskell files (.hs) are also
syntax-highlighted here, so the page needs no JavaScript. This way the code on
the page is the same code that ./build.sh compiles, and the outputs are the
ones it saved to outputs/.
"""
import html
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent

KEYWORDS = {
    'case', 'class', 'data', 'deriving', 'do', 'else', 'forall', 'if',
    'import', 'in', 'instance', 'let', 'module', 'newtype', 'of', 'then',
    'type', 'where',
}

SYMBOL = r"[!#$%&*+./<=>?@\\^|~:]"
TOKEN = re.compile(
    r"(?P<meta>\{-#.*?#-\})"
    r"|(?P<comment>\{-.*?-\}|--+(?!" + SYMBOL + r")[^\n]*)"
    r"|(?P<string>\"(?:\\.|[^\"\\\n])*\")"
    r"|(?P<ident>[A-Za-z_][A-Za-z0-9_']*)"
    r"|(?P<char>'(?:\\.|[^'\\\n])')"
    r"|(?P<number>\b\d+\b)",
    re.DOTALL,
)


def span(cls, text):
    return '<span class="%s">%s</span>' % (cls, html.escape(text, quote=False))


def highlight(code):
    out, pos = [], 0
    for m in TOKEN.finditer(code):
        out.append(html.escape(code[pos:m.start()], quote=False))
        kind, text = m.lastgroup, m.group()
        if kind == 'ident':
            if text in KEYWORDS:
                out.append(span('kw', text))
            elif text[0].isupper():
                out.append(span('ty', text))
            else:
                out.append(html.escape(text, quote=False))
        elif kind in ('string', 'char', 'number'):
            out.append(span('str', text))
        elif kind == 'comment':
            out.append(span('com', text))
        else:
            out.append(span('kw', text))
        pos = m.end()
    out.append(html.escape(code[pos:], quote=False))
    return ''.join(out)


def fragment(m):
    parts = m.group(1).split('|')
    lines = (root / parts[0]).read_text(encoding='utf-8').splitlines()
    if len(parts) == 1:
        chosen = lines
    else:
        start, end = parts[1], parts[2]
        i = next(n for n, l in enumerate(lines) if start in l)
        j = next(n for n in range(i, len(lines)) if end in lines[n])
        extra = int(parts[3]) if len(parts) > 3 else 0
        chosen = lines[i:j + 1 + extra]
    text = '\n'.join(chosen).rstrip()
    if parts[0].endswith('.hs'):
        return highlight(text)
    return html.escape(text, quote=False)


template = (root / 'site/template.html').read_text(encoding='utf-8')
page = re.sub(r'<!--@(.+?)-->', fragment, template)
(root / 'site/index.html').write_text(page, encoding='utf-8')
print('site/index.html', len(page), 'bytes', file=sys.stderr)
