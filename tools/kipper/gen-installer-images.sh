#!/bin/bash
# Gera as imagens do instalador do Windows (Inno Setup) a partir da logo do Kipper.
# Uso: tools/kipper/gen-installer-images.sh   (precisa de rsvg-convert e ImageMagick)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/installer/windows"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ICON="$ROOT/resources/branding/kipper-icon.svg"

# Faixa da esquerda (boas-vindas e conclusão): 202x386 a 100%.
cat > "$TMP/wizard.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="202" height="386" viewBox="0 0 202 386">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#1b1b1e"/>
      <stop offset="1" stop-color="#0b0b0c"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.5" cy="0.36" r="0.55">
      <stop offset="0" stop-color="#1ECBE1" stop-opacity="0.18"/>
      <stop offset="1" stop-color="#1ECBE1" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="202" height="386" fill="url(#bg)"/>
  <rect width="202" height="386" fill="url(#glow)"/>
  <text x="101" y="240" text-anchor="middle" font-family="Noto Sans, DejaVu Sans, sans-serif" font-size="30" font-weight="700" fill="#f4f3ef">Kipper</text>
  <rect x="86" y="256" width="30" height="3" rx="1.5" fill="#1ECBE1"/>
  <text x="101" y="286" text-anchor="middle" font-family="Noto Sans, DejaVu Sans, sans-serif" font-size="11" fill="#9a9aa0">editor de vídeo</text>
</svg>
SVG

# Ícone pequeno do canto das outras páginas: 58x58 a 100%.
cat > "$TMP/small.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="58" height="58" viewBox="0 0 58 58">
  <rect width="58" height="58" fill="#ffffff"/>
</svg>
SVG

for pct in 100 125 150 200; do
  w=$(( 202 * pct / 100 )); h=$(( 386 * pct / 100 ))
  rsvg-convert -w "$w" -h "$h" "$TMP/wizard.svg" -o "$TMP/wizard-$pct.png"
  # O pinguim é colado por cima (o rsvg não carrega imagens externas por segurança).
  i=$(( 104 * pct / 100 )); x=$(( 49 * pct / 100 )); y=$(( 88 * pct / 100 ))
  rsvg-convert -w "$i" -h "$i" "$ICON" -o "$TMP/icon-$pct.png"
  convert "$TMP/wizard-$pct.png" "$TMP/icon-$pct.png" -geometry "+$x+$y" -composite \
    -background '#0b0b0c' -alpha remove -alpha off -type TrueColor "BMP3:$OUT/kipper-wizard-$pct.bmp"
  s=$(( 58 * pct / 100 ))
  rsvg-convert -w "$s" -h "$s" "$TMP/small.svg" -o "$TMP/small-$pct.png"
  si=$(( 52 * pct / 100 )); so=$(( 3 * pct / 100 ))
  rsvg-convert -w "$si" -h "$si" "$ICON" -o "$TMP/sicon-$pct.png"
  convert "$TMP/small-$pct.png" "$TMP/sicon-$pct.png" -geometry "+$so+$so" -composite \
    -background '#ffffff' -alpha remove -alpha off -type TrueColor "BMP3:$OUT/kipper-small-$pct.bmp"
done
ls -la "$OUT"/kipper-*.bmp
