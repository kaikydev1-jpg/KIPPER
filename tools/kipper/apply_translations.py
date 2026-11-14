#!/usr/bin/env python3
"""Preenche traduções vazias de i18n/drift_pt_BR.ts a partir de arquivos JSON.

Uso: apply_translations.py todo.json pt00.json pt01.json ...
todo.json lista as mensagens vazias (contexto, texto original, plural) na ordem dos
índices; cada ptNN.json mapeia índice -> tradução (lista de duas formas no plural).
Escreve direto no .ts, sem mexer no resto do arquivo.
"""
import html, json, re, sys
from pathlib import Path

ts_path = Path(__file__).resolve().parents[2] / "i18n" / "drift_pt_BR.ts"
todo = json.load(open(sys.argv[1], encoding="utf-8"))
tr = {}
for f in sys.argv[2:]:
    tr.update(json.load(open(f, encoding="utf-8")))

text = ts_path.read_text(encoding="utf-8")
esc = lambda s: html.escape(s, quote=False).replace('"', "&quot;").replace("'", "&apos;")
done = 0
missing = []
# Índice: (contexto, fonte) -> posição de cada <message>.
ctx_re = re.compile(r"<context>\s*<name>(.*?)</name>(.*?)</context>", re.S)
out = []
pos = 0
by_key = {}
for t in todo:
    by_key.setdefault((t["ctx"], t["src"]), []).append(t)
for cm in ctx_re.finditer(text):
    ctx = html.unescape(cm.group(1))
    body = cm.group(2)
    def fix(mm):
        global done
        msg = mm.group(0)
        src_m = re.search(r"<source>(.*?)</source>", msg, re.S)
        if not src_m:
            return msg
        src = html.unescape(src_m.group(1))
        cands = by_key.get((ctx, src))
        if not cands:
            return msg
        t = cands[0]
        val = tr.get(str(t["i"]))
        if val is None:
            missing.append(t["i"])
            return msg
        if t["num"]:
            forms = val if isinstance(val, list) else [val, val]
            new_tr = "<translation>" + "".join(f"\n            <numerusform>{esc(f)}</numerusform>" for f in forms) + "\n        </translation>"
            msg2 = re.sub(r"<translation[^>]*>.*?</translation>", new_tr, msg, count=1, flags=re.S)
        else:
            msg2 = re.sub(r"<translation[^>]*>(\s*)</translation>|<translation[^>]*/>",
                          lambda _: f"<translation>{esc(val)}</translation>", msg, count=1)
        if msg2 != msg:
            done += 1
        return msg2
    new_body = re.sub(r"<message[^>]*>.*?</message>", fix, body, flags=re.S)
    out.append(text[pos:cm.start(2)])
    out.append(new_body)
    pos = cm.end(2)
out.append(text[pos:])
ts_path.write_text("".join(out), encoding="utf-8")
print(f"{done} traduções aplicadas; sem tradução: {len(missing)} {missing[:10]}")
