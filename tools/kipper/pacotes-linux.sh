#!/usr/bin/env bash
# Gera Kipper-Ubuntu-Debian.deb e Kipper-Fedora.rpm a partir do AppImage do Kipper.
#
# O AppImage já traz o Kipper com tudo de que ele precisa (Qt, FFmpeg, efeitos). Os pacotes
# .deb e .rpm instalam esse mesmo conteúdo em /opt/kipper, com o comando `kipper`, o atalho no
# menu, os ícones, a descrição da loja de aplicativos e o tipo de arquivo .drift. Assim a loja do
# sistema (GNOME Software, Discover) e o dnf/apt instalam e removem o Kipper como qualquer app.
#
# Uso: tools/kipper/pacotes-linux.sh <Kipper-Linux.AppImage | pasta AppDir> <versão> <pasta de saída>
# Precisa de: dpkg-deb (deb) e rpmbuild (rpm). Sem um deles, gera só o outro e avisa.
set -euo pipefail

ENTRADA="$1"
VERSAO="${2#v}"
SAIDA="$(mkdir -p "$3" && cd "$3" && pwd)"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_ID="io.github.kaikydev1jpg.Kipper"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Versão para os gerenciadores: só números e pontos (0.9.2-teste.12 -> 0.9.2~teste.12 no deb).
VERSAO_DEB="${VERSAO//-/\~}"
VERSAO_RPM="${VERSAO%%-*}"
RELEASE_RPM="1"
[ "$VERSAO" != "$VERSAO_RPM" ] && RELEASE_RPM="0.$(echo "${VERSAO#*-}" | tr -c '[:alnum:].\n' '.')"

# ---------- conteúdo ----------
if [ -d "$ENTRADA" ]; then
  APPDIR="$ENTRADA"
else
  chmod +x "$ENTRADA"
  (cd "$TMP" && "$(cd "$(dirname "$ENTRADA")" && pwd)/$(basename "$ENTRADA")" --appimage-extract >/dev/null)
  APPDIR="$TMP/squashfs-root"
fi
[ -x "$APPDIR/AppRun" ] || [ -x "$APPDIR/usr/bin/drift" ] || { echo "Não achei o Kipper em $ENTRADA" >&2; exit 1; }

RAIZ="$TMP/raiz"
mkdir -p "$RAIZ/opt/kipper" "$RAIZ/usr/bin" "$RAIZ/usr/share/applications" \
         "$RAIZ/usr/share/metainfo" "$RAIZ/usr/share/mime/packages"
cp -a "$APPDIR/." "$RAIZ/opt/kipper/"
# O AppRun do linuxdeploy acha tudo relativo a ele mesmo; sem AppRun (pasta de teste), usa o binário.
cat > "$RAIZ/usr/bin/kipper" <<'SH'
#!/bin/sh
# Abre o Kipper instalado em /opt/kipper.
if [ -x /opt/kipper/AppRun ]; then exec /opt/kipper/AppRun "$@"; fi
exec /opt/kipper/usr/bin/drift "$@"
SH
chmod 755 "$RAIZ/usr/bin/kipper"

sed -e 's/^Exec=drift /Exec=kipper /' "$ROOT/packaging/kipper/$APP_ID.desktop" > "$RAIZ/usr/share/applications/$APP_ID.desktop"
cp "$ROOT/packaging/kipper/$APP_ID.metainfo.xml" "$RAIZ/usr/share/metainfo/$APP_ID.metainfo.xml"
sed -e "s/org\.cutwire\.Drift/$APP_ID/g" "$ROOT/flatpak/org.cutwire.Drift.xml" > "$RAIZ/usr/share/mime/packages/$APP_ID.xml"
for s in 64 128 256 512; do
  mkdir -p "$RAIZ/usr/share/icons/hicolor/${s}x${s}/apps"
  cp "$ROOT/flatpak/share/icons/hicolor/${s}x${s}/apps/org.cutwire.Drift.png" \
     "$RAIZ/usr/share/icons/hicolor/${s}x${s}/apps/$APP_ID.png"
done
mkdir -p "$RAIZ/usr/share/icons/hicolor/scalable/apps"
cp "$ROOT/resources/branding/kipper-icon.svg" "$RAIZ/usr/share/icons/hicolor/scalable/apps/$APP_ID.svg"
mkdir -p "$RAIZ/usr/share/doc/kipper"
cp "$ROOT/LICENSE" "$RAIZ/usr/share/doc/kipper/LICENSE"

TAMANHO_KB=$(du -sk "$RAIZ" | cut -f1)

# ---------- .deb ----------
if command -v dpkg-deb >/dev/null 2>&1; then
  DEB="$TMP/deb"
  cp -a "$RAIZ" "$DEB"
  mkdir -p "$DEB/DEBIAN"
  cat > "$DEB/DEBIAN/control" <<EOF
Package: kipper
Version: $VERSAO_DEB
Architecture: amd64
Maintainer: Kipper <https://github.com/kaikydev1-jpg/KIPPER/issues>
Installed-Size: $TAMANHO_KB
Depends: libc6 (>= 2.35), libgl1, libegl1, libfontconfig1, libfreetype6, libx11-6, libx11-xcb1, libxcb1, libxkbcommon0, libxkbcommon-x11-0, libdbus-1-3, libasound2t64 | libasound2
Recommends: libpulse0, libva2, libva-drm2
Section: video
Priority: optional
Homepage: https://github.com/kaikydev1-jpg/KIPPER
Description: Editor de vídeo gratuito, do primeiro corte ao filme inteiro
 Kipper é um editor de vídeo gratuito e de código aberto, sem marca d'água,
 sem conta e sem assinatura. Legendas automáticas, correção de cor,
 quadros-chave, máscaras, mais de 150 transições e exportação até 4K.
 Baseado no Drift, da CutWire Studios.
EOF
  cat > "$DEB/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v update-mime-database >/dev/null 2>&1 && update-mime-database /usr/share/mime || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
exit 0
EOF
  cp "$DEB/DEBIAN/postinst" "$DEB/DEBIAN/postrm"
  chmod 755 "$DEB/DEBIAN/postinst" "$DEB/DEBIAN/postrm"
  dpkg-deb --root-owner-group -Zxz --build "$DEB" "$SAIDA/Kipper-Ubuntu-Debian.deb" >/dev/null
  echo "$SAIDA/Kipper-Ubuntu-Debian.deb"
else
  echo "aviso: sem dpkg-deb, o .deb não foi gerado" >&2
fi

# ---------- .rpm ----------
if command -v rpmbuild >/dev/null 2>&1; then
  TOP="$TMP/rpm"
  mkdir -p "$TOP"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
  cat > "$TOP/SPECS/kipper.spec" <<EOF
Name:           kipper
Version:        $VERSAO_RPM
Release:        $RELEASE_RPM
Summary:        Editor de vídeo gratuito, do primeiro corte ao filme inteiro
License:        GPL-3.0-or-later
URL:            https://github.com/kaikydev1-jpg/KIPPER
BuildArch:      x86_64
# O Kipper leva as próprias bibliotecas (Qt, FFmpeg); só o básico do sistema é preciso.
AutoReqProv:    no
Requires:       glibc, libglvnd-glx, libglvnd-egl, fontconfig, freetype, libX11, libX11-xcb, libxcb, libxkbcommon, libxkbcommon-x11, dbus-libs, alsa-lib
Recommends:     pulseaudio-libs, libva

%global debug_package %{nil}
%global _binary_payload w19.zstdio
%global __os_install_post %{nil}
%global _build_id_links none

%description
Kipper é um editor de vídeo gratuito e de código aberto, sem marca d'água,
sem conta e sem assinatura. Legendas automáticas, correção de cor,
quadros-chave, máscaras, mais de 150 transições e exportação até 4K.
Baseado no Drift, da CutWire Studios.

%install
mkdir -p %{buildroot}
cp -a $RAIZ/. %{buildroot}/

%post
update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || :
update-mime-database /usr/share/mime >/dev/null 2>&1 || :
gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || :

%postun
update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || :
update-mime-database /usr/share/mime >/dev/null 2>&1 || :

%files
/opt/kipper
/usr/bin/kipper
/usr/share/applications/$APP_ID.desktop
/usr/share/metainfo/$APP_ID.metainfo.xml
/usr/share/mime/packages/$APP_ID.xml
/usr/share/icons/hicolor/*/apps/$APP_ID.*
%license /usr/share/doc/kipper/LICENSE
EOF
  rpmbuild --quiet --define "_topdir $TOP" -bb "$TOP/SPECS/kipper.spec" >/dev/null
  cp "$TOP"/RPMS/x86_64/kipper-*.rpm "$SAIDA/Kipper-Fedora.rpm"
  echo "$SAIDA/Kipper-Fedora.rpm"
else
  echo "aviso: sem rpmbuild, o .rpm não foi gerado" >&2
fi
