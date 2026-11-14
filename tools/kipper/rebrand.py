#!/usr/bin/env python3
"""Troca o nome Drift por Kipper só no texto que a pessoa vê.

Mexe apenas em frases traduzíveis (qsTr, tr, translate, QT_TR_NOOP...) no
código e nos catálogos de tradução i18n/drift.ts e i18n/drift_pt_BR.ts, com a
mesma regra nos dois lados, para as traduções continuarem casando. Nomes
internos (import Drift, chaves de configuração, extensões .drift) ficam como
estão, o que mantém fácil puxar correções do Drift original.

Pode rodar de novo depois de um merge do Drift: é idempotente.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# Menções que falam do Drift de verdade e devem continuar.
KEEP_AFTER = re.compile(r"(?= Forge|-Assets| team\b| Studios|-Addons)")
KEEP_BEFORE = ("equipe do ", "equipe Drift", "CutWire ")


def rebrand(text: str) -> str:
    text = text.replace("CutWire Drift", "Kipper")
    out = []
    pos = 0
    for m in re.finditer(r"\bDrift\b", text):
        out.append(text[pos:m.start()])
        before = text[max(0, m.start() - 12):m.start()]
        keep = KEEP_AFTER.match(text, m.end()) or any(before.endswith(b) for b in KEEP_BEFORE)
        out.append("Drift" if keep else "Kipper")
        pos = m.end()
    out.append(text[pos:])
    return "".join(out)


STR = r'"(?:[^"\\\n]|\\.)*"'
# Abertura de uma chamada de tradução, logo antes do primeiro texto.
OPENERS = re.compile(
    r"(?:\bqsTr|\btr|\btrReport|\bQT_TR_NOOP|\bQT_TR_N_NOOP|\bqsTrNoOp)\s*\(\s*$"
    r"|(?:\btranslate|\bqsTranslate|\bQT_TRANSLATE_NOOP|\bQT_TRANSLATE_N_NOOP|\bqsTranslateNoOp)\s*\(\s*" + STR + r"\s*,\s*$"
)
STR_RE = re.compile(STR)


def in_translation_call(src: str, start: int) -> bool:
    # Volta pelos textos colados (concatenação do C++) até achar a abertura.
    i = start
    while True:
        head = src[:i].rstrip()
        # QML emenda textos com "+"; o C++ só os encosta.
        if head.endswith("+"):
            head = head[:-1].rstrip()
        m = re.search(STR + r"$", head)
        if m and not OPENERS.search(head):
            i = m.start()
            continue
        return bool(OPENERS.search(src[max(0, i - 400):i]))


def process_source(path: Path) -> bool:
    src = path.read_text(encoding="utf-8")
    if "Drift" not in src:
        return False
    out = []
    pos = 0
    for m in STR_RE.finditer(src):
        lit = m.group(0)
        if "Drift" in lit and in_translation_call(src, m.start()):
            new = rebrand(lit)
            if new != lit:
                out.append(src[pos:m.start()])
                out.append(new)
                pos = m.end()
    if not out:
        return False
    out.append(src[pos:])
    path.write_text("".join(out), encoding="utf-8")
    return True


def process_ts(path: Path) -> bool:
    ts = path.read_text(encoding="utf-8")

    def fix(m):
        return m.group(1) + rebrand(m.group(2)) + m.group(3)

    new = re.sub(r"(<(?:source|translation|numerusform|comment|extracomment)[^>]*>)(.*?)(</(?:source|translation|numerusform|comment|extracomment)>)",
                 fix, ts, flags=re.S)
    if new != ts:
        path.write_text(new, encoding="utf-8")
        return True
    return False


def main() -> int:
    changed = []
    for ext in ("*.qml", "*.cpp", "*.h", "*.js"):
        for p in (ROOT / "src").rglob(ext):
            if process_source(p):
                changed.append(p)
    for name in ("drift.ts", "drift_pt_BR.ts"):
        p = ROOT / "i18n" / name
        if p.exists() and process_ts(p):
            changed.append(p)
    for p in changed:
        print(p.relative_to(ROOT))
    print(f"{len(changed)} arquivos alterados", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
