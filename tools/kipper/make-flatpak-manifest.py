#!/usr/bin/env python3
"""Gera flatpak/io.github.kaikydev1jpg.Kipper.yml a partir do manifesto do Drift.

Rode de novo depois de puxar atualizações do Drift (o manifesto dele muda com elas):
    python3 tools/kipper/make-flatpak-manifest.py

Diferenças em relação ao do Drift:
- ID io.github.kaikydev1jpg.Kipper (o mesmo pacote serve de Kipper-Flatpak e Kipper-Matsu-OS);
- permissões para o aviso de versão nova e para instalar a atualização com um clique
  (org.freedesktop.Notifications e org.freedesktop.Flatpak, padrão dos apps, seção 7);
- todos os efeitos, transições e efeitos de áudio vêm junto (DRIFT_BUNDLE_CORE_PACKAGES_ONLY=OFF);
- a QWindowKit (barra de título integrada) entra como fonte, porque o Flatpak compila sem internet.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "flatpak" / "org.cutwire.Drift.yml"
DST = ROOT / "flatpak" / "io.github.kaikydev1jpg.Kipper.yml"
QWK_URL = "https://github.com/stdware/qwindowkit.git"


def qwk_commit() -> str:
    cmake = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
    m = re.search(r"FetchContent_Declare\(qwindowkit.*?GIT_TAG\s+([0-9a-f]{40})", cmake, re.S)
    if not m:
        sys.exit("não achei o commit da QWindowKit no CMakeLists.txt")
    return m.group(1)


def main() -> int:
    t = SRC.read_text(encoding="utf-8")

    def sub(old, new, count=1):
        nonlocal t
        if old not in t:
            sys.exit(f"o manifesto do Drift mudou, não achei: {old!r}")
        t = t.replace(old, new, count)

    header = ("# GERADO por tools/kipper/make-flatpak-manifest.py a partir de org.cutwire.Drift.yml.\n"
              "# Não edite à mão: mude o script e rode de novo.\n")
    sub("app-id: org.cutwire.Drift\n", "app-id: io.github.kaikydev1jpg.Kipper\n")
    sub("  - --device=dri\n", "  - --device=dri\n"
        "  # Kipper: aviso de versão nova e atualização com um clique (flatpak-spawn --host flatpak install).\n"
        "  - --talk-name=org.freedesktop.Notifications\n"
        "  - --talk-name=org.freedesktop.Flatpak\n")
    sub("        -DDRIFT_BUNDLE_CORE_PACKAGES_ONLY=ON\n",
        "        -DDRIFT_BUNDLE_CORE_PACKAGES_ONLY=OFF\n"
        "        -DFETCHCONTENT_SOURCE_DIR_QWINDOWKIT=$PWD/third_party/qwindowkit\n")
    sub("      # Audio effect DSP. Only juce_dsp and its dependencies are compiled; nothing GUI-facing.\n",
        "      # Kipper: barra de título integrada (QWindowKit, Apache-2.0), mesmo commit do CMakeLists.txt.\n"
        "      - type: git\n"
        f"        url: {QWK_URL}\n"
        f"        commit: {qwk_commit()}\n"
        "        dest: third_party/qwindowkit\n"
        "      # Audio effect DSP. Only juce_dsp and its dependencies are compiled; nothing GUI-facing.\n")
    t = t.replace("org.cutwire.Drift", "io.github.kaikydev1jpg.Kipper")
    DST.write_text(header + t, encoding="utf-8")
    print(DST.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())
