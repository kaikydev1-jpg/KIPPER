#!/usr/bin/env python3
"""Gera os ícones do Kipper para o Android a partir do pinguim (resources/branding/kipper-icon.svg).

- android/res/drawable/ic_launcher_background.xml   fundo claro (#f6f5f2)
- android/res/drawable/ic_launcher_foreground.xml   o pinguim, dentro da área segura do ícone adaptativo
- android/res/drawable/ic_launcher_monochrome.xml   o pinguim de uma cor só (ícones temáticos do Android 13+)
- android/res/mipmap-*/ic_launcher*.png             ícones comuns (Android antigo), com rsvg-convert

Uso: python3 tools/kipper/android-icones.py
"""
import pathlib
import re
import subprocess

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SVG = RAIZ / "resources/branding/kipper-icon.svg"
RES = RAIZ / "android/res"
CLARO = "#F6F5F2"
ESCURO = "#111111"


def circulo(cx, cy, r):
    return f"M{cx - r},{cy} a{r},{r} 0 1,0 {2 * r},0 a{r},{r} 0 1,0 {-2 * r},0 Z"


def pecas():
    """Os caminhos do pinguim, na ordem do desenho: (nome, pathData, preenchimento, traço?)."""
    svg = SVG.read_text(encoding="utf-8")
    grupo = svg[svg.index('<g id="kipper-penguin">'):]
    saida = []
    for m in re.finditer(r'<path d="([^"]+)" fill="([^"]+)"( stroke="[^"]+" stroke-width="([\d.]+)")?', grupo):
        saida.append(("path", m.group(1), m.group(2).upper(), m.group(4)))
    for m in re.finditer(r'<circle cx="([\d.]+)" cy="([\d.]+)" r="([\d.]+)" fill="([^"]+)"', grupo):
        cx, cy, r = (float(m.group(i)) for i in (1, 2, 3))
        saida.append(("circle", circulo(cx, cy, r), m.group(4).upper(), None))
    return saida


def cabecalho():
    # 108dp no total; o desenho de 512 unidades fica nos 72dp do meio (como no ícone do Drift), e o
    # pinguim, já reduzido no SVG, cabe nos 66dp da área segura.
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- GERADO por tools/kipper/android-icones.py a partir de resources/branding/kipper-icon.svg. -->\n'
            '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
            '    android:width="108dp"\n    android:height="108dp"\n'
            '    android:viewportWidth="768"\n    android:viewportHeight="768">\n')


# translate(256 262) scale(0.92) translate(-256 -270) do SVG: escala em volta de (256,270), sobe 8.
GRUPO = ('    <group android:translateX="128" android:translateY="128">\n'
         '      <group android:pivotX="256" android:pivotY="270" android:scaleX="0.92" android:scaleY="0.92"'
         ' android:translateY="-8">\n')
FIM_GRUPO = "      </group>\n    </group>\n</vector>\n"


def frente():
    linhas = [cabecalho(), GRUPO]
    for _, d, cor, traco in pecas():
        linhas.append(f'        <path android:fillColor="{cor}" android:pathData="{d}"')
        if traco:
            linhas.append(f'\n            android:strokeColor="{CLARO}" android:strokeWidth="{traco}"'
                          ' android:strokeLineJoin="round"')
        linhas.append(" />\n")
    linhas.append(FIM_GRUPO)
    return "".join(linhas)


def monocromatico():
    # Uma cor só: o corpo com a barriga vazada (evenOdd), e os olhos e o bico por cima.
    p = pecas()
    corpo = [d for k, d, cor, t in p if k == "path" and cor == ESCURO and not t]
    asas = [d for k, d, cor, t in p if t]
    barriga = [d for k, d, cor, t in p if k == "path" and cor == CLARO]
    olhos = [d for k, d, cor, t in p if k == "circle" and cor == ESCURO]
    bico = corpo[-1]  # o último caminho escuro é o bico
    corpo_sem_bico = corpo[:-1]
    linhas = [cabecalho(), GRUPO]
    linhas.append('        <path android:fillColor="#FFFFFF" android:fillType="evenOdd" android:pathData="'
                  + " ".join(corpo_sem_bico + barriga) + '" />\n')
    for d in asas + olhos + [bico]:
        linhas.append(f'        <path android:fillColor="#FFFFFF" android:pathData="{d}" />\n')
    linhas.append(FIM_GRUPO)
    return "".join(linhas)


def fundo():
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- GERADO por tools/kipper/android-icones.py: o fundo claro do ícone do Kipper. -->\n'
            '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
            '    android:width="108dp"\n    android:height="108dp"\n'
            '    android:viewportWidth="108"\n    android:viewportHeight="108">\n'
            f'    <path android:fillColor="{CLARO}" android:pathData="M0,0 H108 V108 H0 Z" />\n'
            '</vector>\n')


def main():
    (RES / "drawable/ic_launcher_background.xml").write_text(fundo(), encoding="utf-8")
    (RES / "drawable/ic_launcher_foreground.xml").write_text(frente(), encoding="utf-8")
    (RES / "drawable/ic_launcher_monochrome.xml").write_text(monocromatico(), encoding="utf-8")
    for pasta, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        for nome in ("ic_launcher.png", "ic_launcher_round.png"):
            destino = RES / f"mipmap-{pasta}" / nome
            subprocess.run(["rsvg-convert", "-w", str(px), "-h", str(px), "-o", str(destino), str(SVG)], check=True)
    print("ícones do Android gerados")


if __name__ == "__main__":
    main()
