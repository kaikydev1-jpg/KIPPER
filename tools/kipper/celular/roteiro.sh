#!/usr/bin/env bash
# Kipper: roda um roteiro de toques no Android virtual e tira prints (usado pelo
# .github/workflows/kipper-celular.yml).
#
# Uso: roteiro.sh PACOTE "passo; passo; ..."
#
# Passos (posições em dp, a medida do Android; o script converte para pixels):
#   start                abre o Kipper          stop        fecha o Kipper
#   print NOME           tira um print          wait S      espera S segundos
#   tap X Y              toca                   hold X Y    segura (toque longo)
#   swipe X1 Y1 X2 Y2 [ms]                      arrastar
#   key NOME|CÓDIGO      tecla (back, home, enter ou o número do keyevent)
#   text PALAVRAS        digita
#   share ARQUIVO        compartilha com o Kipper um vídeo da galeria (ex.: exemplo-empe.mp4)
set -u
PKG="$1"
ROTEIRO="$2"
mkdir -p prints
DENS=$(adb shell wm density | grep -o '[0-9]\+' | tail -1)
ESCALA=$(awk -v d="$DENS" 'BEGIN { printf "%.4f", d / 160 }')
echo "densidade $DENS (escala $ESCALA)"
n=0
px() { awk -v v="$1" -v e="$ESCALA" 'BEGIN { printf "%d", v * e + 0.5 }'; }
shot() {
  n=$((n + 1))
  local f
  f=$(printf 'prints/%02d-%s.png' "$n" "${1:-tela}")
  adb exec-out screencap -p > "$f"
  echo "print $f"
}

IFS=';' read -ra PASSOS <<< "$ROTEIRO"
for passo in "${PASSOS[@]}"; do
  read -ra p <<< "$passo"
  [ ${#p[@]} -gt 0 ] || continue
  echo "> ${p[*]}"
  case "${p[0]}" in
    start) adb shell am start -W -n "$PKG/org.cutwire.drift.DriftActivity" >/dev/null ;;
    stop) adb shell am force-stop "$PKG" ;;
    print) shot "${p[1]:-tela}" ;;
    wait) sleep "${p[1]:-1}" ;;
    tap) adb shell input tap "$(px "${p[1]}")" "$(px "${p[2]}")" ;;
    hold) adb shell input swipe "$(px "${p[1]}")" "$(px "${p[2]}")" "$(px "${p[1]}")" "$(px "${p[2]}")" 900 ;;
    swipe) adb shell input swipe "$(px "${p[1]}")" "$(px "${p[2]}")" "$(px "${p[3]}")" "$(px "${p[4]}")" "${p[5]:-350}" ;;
    key)
      case "${p[1]}" in
        back) k=4 ;; home) k=3 ;; enter) k=66 ;; *) k="${p[1]}" ;;
      esac
      adb shell input keyevent "$k" ;;
    text) adb shell input text "$(printf '%s' "${p[*]:1}" | sed 's/ /%s/g')" ;;
    share)
      id=$(adb shell content query --uri content://media/external/video/media --projection _id:_display_name \
             | grep "_display_name=${p[1]}" | sed -E 's/.*_id=([0-9]+).*/\1/' | head -n 1)
      echo "vídeo ${p[1]}: id ${id:-?}"
      adb shell am start -a android.intent.action.SEND -t video/mp4 \
        --eu android.intent.extra.STREAM "content://media/external/video/media/$id" \
        --grant-read-uri-permission -n "$PKG/org.cutwire.drift.DriftActivity" >/dev/null ;;
    *) echo "passo desconhecido: ${p[0]}" ;;
  esac
  sleep 0.6
done
# O que o Kipper escreveu no registro do Android (erros, avisos do Qt, travamentos).
adb logcat -d -v time > prints/logcat-completo.txt 2>/dev/null || true
grep -iE 'drift|kipper|qt|AndroidRuntime|FATAL|libc|DEBUG ' prints/logcat-completo.txt > prints/logcat.txt || true
echo "fim: $n prints"
