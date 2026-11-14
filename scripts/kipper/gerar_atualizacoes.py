#!/usr/bin/env python3
"""Gera o atualizacoes.json e o SHA256SUMS.txt publicados junto com cada versão do Kipper.

O app lê releases/latest/download/atualizacoes.json uma vez por dia (dá para desligar nas
configurações; nada sobre a pessoa é enviado). Se a versão for mais nova, avisa e, no clique,
baixa só o arquivo do tipo de instalação daquele computador e confere o SHA-256.

Uso: gerar_atualizacoes.py VERSAO PASTA_DOS_ARQUIVOS
Escreve PASTA/atualizacoes.json e PASTA/SHA256SUMS.txt.
"""
import hashlib
import json
import pathlib
import sys

REPO = "kaikydev1-jpg/KIPPER"
TIPOS = {
    "windows": "Kipper-Windows.exe",
    "fedora": "Kipper-Fedora.rpm",
    "debian": "Kipper-Ubuntu-Debian.deb",
    "appimage": "Kipper-Linux.AppImage",
    "flatpak": "Kipper-Flatpak.flatpak",
    "matsu": "Kipper-Matsu-OS.flatpak",
}


def sha256(caminho: pathlib.Path) -> str:
    h = hashlib.sha256()
    with caminho.open("rb") as f:
        for bloco in iter(lambda: f.read(1 << 20), b""):
            h.update(bloco)
    return h.hexdigest()


def main() -> int:
    versao = sys.argv[1].lstrip("v")
    pasta = pathlib.Path(sys.argv[2])
    raiz = pathlib.Path(__file__).resolve().parents[2]
    resumo_arq = raiz / ".github/release/resumo-kipper.txt"
    resumo = resumo_arq.read_text(encoding="utf-8").strip() if resumo_arq.exists() else ""

    somas = {}
    for arq in sorted(p for p in pasta.iterdir() if p.is_file() and p.name not in ("SHA256SUMS.txt", "atualizacoes.json")):
        somas[arq.name] = sha256(arq)
    (pasta / "SHA256SUMS.txt").write_text("".join(f"{s}  {n}\n" for n, s in somas.items()), encoding="utf-8")

    base = f"https://github.com/{REPO}/releases/download/v{versao}"
    dados = {
        "versao_manifesto": 1,
        "app": {
            "versao": versao,
            "pagina": f"https://github.com/{REPO}/releases/tag/v{versao}",
            # Uma linha do que mudou: aparece na faixa "versão nova" da janela.
            "notas": resumo,
        },
        "arquivos": {
            tipo: {"nome": nome, "url": f"{base}/{nome}", "sha256": somas.get(nome, "")}
            for tipo, nome in TIPOS.items() if nome in somas
        },
        "somas": f"{base}/SHA256SUMS.txt",
    }
    (pasta / "atualizacoes.json").write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"gerados {pasta / 'atualizacoes.json'} e {pasta / 'SHA256SUMS.txt'} ({len(somas)} arquivos)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
