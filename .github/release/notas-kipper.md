**Kipper {{VERSAO}}**: editor de vídeo gratuito e de código aberto, do primeiro corte ao filme inteiro. Sem marca d'água, sem conta e sem assinatura. Tudo roda no seu computador, sem telemetria.

## Instalar pelo terminal (qualquer Linux)
Descobre o seu sistema (Matsu OS, Fedora, Fedora Atomic, Ubuntu, Debian, Mint…), baixa a versão certa, confere o SHA-256 e instala:
```bash
curl -fsSL https://github.com/kaikydev1-jpg/KIPPER/releases/latest/download/instalar.sh | bash
```

## Baixe para o seu sistema

### Windows 10 e 11
**[Kipper-Windows.exe](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Windows.exe)**
- Abra o arquivo e siga o instalador. **Não pede administrador.**
- Se aparecer "O Windows protegeu o computador", clique em **Mais informações → Executar assim mesmo** (o instalador ainda não tem assinatura digital).

### Fedora (Workstation, KDE e outras edições)
**[Kipper-Fedora.rpm](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Fedora.rpm)**
```bash
sudo dnf install ./Kipper-Fedora.rpm
```

### Fedora Atomic (Silverblue, Kinoite, Bazzite, Bluefin, Aurora)
**[Kipper-Flatpak.flatpak](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Flatpak.flatpak)**
```bash
flatpak install --user ./Kipper-Flatpak.flatpak
```
Instala sem reiniciar. Na primeira vez, baixa a base do KDE pelo Flathub. Serve também para qualquer distro com Flatpak.

### Matsu OS (Matsu 27 OS e as versões dos próximos anos)
**[Kipper-Matsu-OS.flatpak](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Matsu-OS.flatpak)**
- Já abre com o visual do Matsu OS: as bolinhas com as cores do sistema, o cinza em segundo plano e os símbolos ao passar o mouse.
- Abra o arquivo baixado na loja de aplicativos do sistema, ou pelo terminal:
```bash
flatpak install --user ./Kipper-Matsu-OS.flatpak
```

### Ubuntu, Debian, Linux Mint, Pop!_OS, Zorin
**[Kipper-Ubuntu-Debian.deb](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Ubuntu-Debian.deb)**
```bash
sudo apt install ./Kipper-Ubuntu-Debian.deb
```

### Celular Android
**[Kipper-Android.apk](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Android.apk)**
- Baixe pelo navegador do celular e abra o arquivo. Na primeira vez, o Android pede para permitir instalar apps baixados pelo navegador.
- Celular antigo (32 bits)? Use o **[Kipper-Android-32bits.apk](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Android-32bits.apk)**.
- Depois de instalado, o Kipper avisa quando sair versão nova e se atualiza pelo próprio app.

### Arch, openSUSE e outras distros
**[Kipper-Linux.AppImage](https://github.com/kaikydev1-jpg/KIPPER/releases/download/v{{VERSAO}}/Kipper-Linux.AppImage)**
```bash
chmod +x Kipper-Linux.AppImage && ./Kipper-Linux.AppImage
```
Não instala nada e não precisa de libfuse2. Também dá para usar o Flatpak.

## Conferir os arquivos
As somas SHA-256 de todos os arquivos estão em **SHA256SUMS.txt**.

## Créditos
O Kipper é software livre (GPL-3.0-or-later), baseado no [Drift](https://github.com/CutWire-Studios/Drift), da CutWire Studios, com ideias de design do [Concat](https://github.com/jub0t/Concat).

## Novo nesta versão
