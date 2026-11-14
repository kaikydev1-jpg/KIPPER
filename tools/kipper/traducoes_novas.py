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
    "The update didn’t finish installing. You can install it from the terminal:":
        "A atualização não terminou de instalar. Dá para instalar pelo terminal:",
    "Copy command": "Copiar comando",
    "Command copied": "Comando copiado",
    # Atualização do Drift de 14/11/2026 (linha do tempo e aviso de travamento).
    "Enable": "Ativar",
    "Disable": "Desativar",
    "Enable or disable selected clips": "Ativar ou desativar os clipes selecionados",
    "No space to place the clip there": "Não há espaço para colocar o clipe aí",
    "Enable clips": "Ativar clipes",
    "Disable clips": "Desativar clipes",
    "Clips enabled": "Clipes ativados",
    "Clips disabled": "Clipes desativados",
    "Enable clip": "Ativar clipe",
    "Disable clip": "Desativar clipe",
    "Kipper crashed the last time it ran": "O Kipper travou da última vez que foi aberto",
    "Kipper did not close properly last time": "O Kipper não fechou direito da última vez",
    "If it keeps happening, you can start in safe mode, which uses the default graphics backend and loads no add-ons for this session.":
        "Se continuar acontecendo, você pode abrir no modo de segurança, que usa o motor gráfico padrão e não carrega complementos nesta sessão.",
    "Kipper closed unexpectedly during your last session.": "O Kipper fechou de repente da última vez que foi usado.",
    # Exportar (os textos vêm do motor de exportação).
    "Same as project": "Igual ao projeto",
    "Same as project · %1×%2": "Igual ao projeto · %1×%2",
    "Same as project (%1 fps)": "Igual ao projeto (%1 fps)",
    "23.976 fps (NTSC film)": "23,976 fps (cinema NTSC)",
    "25 fps (PAL)": "25 fps (PAL)",
    "29.97 fps (NTSC)": "29,97 fps (NTSC)",
    "59.94 fps (NTSC)": "59,94 fps (NTSC)",
    "Invalid export range": "Trecho de exportação inválido",
    "Export range is empty": "O trecho para exportar está vazio",
    "Timeline is empty": "A linha do tempo está vazia",
    "Export cancelled": "Exportação cancelada",
    "Export failed": "A exportação falhou",
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
