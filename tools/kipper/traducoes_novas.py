#!/usr/bin/env python3
"""Preenche no i18n/drift_pt_BR.ts as frases novas do Kipper que ainda estão vazias.

Rode depois de `cmake --build build --target update_translations`. Só mexe em frases
vazias cujo texto original esteja na lista abaixo; o resto do arquivo fica como está.
"""
import html
import re
from pathlib import Path

PT = {
    "Create project": "Criar projeto",
    "Start from scratch. Drop in your videos, photos and music.": "Comece do zero. Arraste seus vídeos, fotos e músicas.",
    "Vertical · 9:16": "Em pé · 9:16",
    "TikTok, Reels and Shorts": "TikTok, Reels e Shorts",
    "Landscape · 16:9": "Deitado · 16:9",
    "YouTube and TV": "YouTube e TV",
    "Square · 1:1": "Quadrado · 1:1",
    "Instagram feed": "Feed do Instagram",
}

ts = Path(__file__).resolve().parents[2] / "i18n" / "drift_pt_BR.ts"
text = ts.read_text(encoding="utf-8")
feitas = 0
for src, dst in PT.items():
    pat = re.compile(r"(<source>" + re.escape(html.escape(src, quote=False)) + r"</source>\s*(?:<comment>.*?</comment>\s*)?)"
                     r"(?:<translation type=\"unfinished\">\s*</translation>|<translation type=\"unfinished\"/>|<translation>\s*</translation>)", re.S)
    text, n = pat.subn(lambda m: m.group(1) + "<translation>" + html.escape(dst, quote=False) + "</translation>", text)
    feitas += n
ts.write_text(text, encoding="utf-8")
print(f"{feitas} frases preenchidas")
