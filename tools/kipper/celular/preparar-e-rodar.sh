#!/usr/bin/env bash
# Kipper: prepara o Android virtual (instala o APK, põe vídeos de exemplo na galeria) e roda o
# roteiro de toques. Chamado pelo .github/workflows/kipper-celular.yml dentro do emulador.
set -u
PKG="${PKG:-io.github.kaikydev1jpg.kipper.teste}"
APK=$(ls apk/*.apk | head -n 1)
echo "instalando $APK"
adb install -r -g "$APK"
for f in exemplo-empe.mp4 exemplo-deitado.mp4; do
  [ -f "$f" ] && adb push "$f" "/sdcard/Movies/$f" >/dev/null
done
adb shell content call --uri content://media --method scan_volume --arg external_primary >/dev/null 2>&1 || true
for f in exemplo-empe.mp4 exemplo-deitado.mp4; do
  adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Movies/$f" >/dev/null 2>&1 || true
done
adb shell settings put system screen_off_timeout 1800000 || true
adb shell wm size
adb logcat -c || true
bash tools/kipper/celular/roteiro.sh "$PKG" "${ROTEIRO:-start; wait 40; print inicio}"
