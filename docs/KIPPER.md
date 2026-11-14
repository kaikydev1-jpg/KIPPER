# Kipper: como o projeto está montado

O Kipper é o Drift (CutWire Studios, GPLv3) com outra cara e outro nome. A regra é mudar o
mínimo no código do Drift, para continuar dando para puxar as correções dele.

## Base e origem

- Histórico completo do Drift neste repositório (remoto `drift` =
  `https://github.com/CutWire-Studios/Drift`). Para trazer correções:
  ```bash
  git fetch drift main
  git merge drift/main
  python3 tools/kipper/rebrand.py              # troca "Drift" por "Kipper" no texto novo
  python3 tools/kipper/make-flatpak-manifest.py # refaz o manifesto do Flatpak do Kipper
  ```
- **Regra do criador:** quando o Drift lançar atualização, trazer para o Kipper, principalmente
  correção de algo crítico (travamento, perda de projeto, segurança). Depois do merge: frases novas
  traduzidas (`tools/kipper/traducoes_novas.py`, aproveitando a tradução do Drift quando existir),
  testes passando e uma rodada dos instaladores.
- Nomes internos continuam os do Drift (`import Drift`, binário `drift`, extensões `.drift`,
  variáveis `DRIFT_*`). Só o que a pessoa vê muda.
- Concat (jub0t/Concat, AGPL) entrou só como referência de visual; nenhum código dele foi copiado.

## O que é do Kipper

| Onde | O quê |
|---|---|
| `CMakeLists.txt` | ID `io.github.kaikydev1jpg.Kipper`, nome Kipper, idiomas (pt-BR e inglês), QWindowKit, loja da CutWire desligada, atualizações do KIPPER |
| `src/ui/window/WindowChrome.*` | Barra de título integrada: estilo e lado dos botões (gtk-decoration-layout, portal, kwinrc, settings.ini), Matsu OS pelo os-release, ligação com a QWindowKit em todas as janelas |
| `src/qml/components/shell/WindowControls.qml` | Desenho dos botões: Windows 11, GNOME, KDE, Mac e Matsu OS (bolinhas 12 px, cores exatas do padrão) |
| `src/qml/components/shell/WindowTitleBar.qml` | Faixa de título das janelas secundárias |
| `src/qml/components/assets/AssetsPanelTopTabs.qml` | Abas do painel de mídia no alto, como no CapCut |
| `src/qml/PropertiesPanel.qml` | Abas do painel de ajustes no alto (usa a faixa que o Drift tinha no celular) |
| `resources/themes/dark.json`, `light.json` | Tema do Kipper: fundo quase preto, ciano `#1ECBE1`, cursor branco, cores de clipe do CapCut |
| `src/app/crash/CrashReporter.cpp` | Sem telemetria: envio de travamento desligado de vez |
| `src/app/online/updates/UpdateChecker.cpp` | Atualização pelo `atualizacoes.json` do KIPPER (o Drift usava DNS da CutWire) |
| `src/app/main.cpp` | Nome do app, correção do travamento da tela de abertura depois do aviso de travamento |
| `i18n/drift_pt_BR.ts` | Tradução completa para o português do Brasil |
| `resources/branding/` | Logo do pinguim (SVG) |
| `packaging/kipper/` | Atalho do menu e descrição da loja de aplicativos |
| `installer/windows/Kipper.iss` | Instalador do Windows (por usuário, sem administrador, pt-BR) |
| `flatpak/io.github.kaikydev1jpg.Kipper.yml` | Manifesto do Flatpak, GERADO por `tools/kipper/make-flatpak-manifest.py` |
| `tools/kipper/pacotes-linux.sh` | `.deb` e `.rpm` a partir do AppImage (em `/opt/kipper`, comando `kipper`) |
| `scripts/kipper/instalar.sh` | Instalador pelo terminal |
| `scripts/kipper/gerar_atualizacoes.py` | `atualizacoes.json` e `SHA256SUMS.txt` |
| `.github/workflows/kipper-instaladores.yml` | Gera todos os arquivos; tag `vX.Y.Z` cria só um RASCUNHO de versão |
| `site/` | Site de apresentação (HTML/CSS/JS puro, para a Vercel) |
| `tests/tst_windowchrome.cpp` | Testes da escolha dos botões e do Matsu OS |

## Testar na mão (Linux)

- `KIPPER_WINDOW_STYLE=windows|gnome|kde|mac|matsu ./build/drift` força um estilo de botões.
- `KIPPER_OS_RELEASE=/caminho/os-release` finge outro sistema (ex.: Matsu OS).
- `KIPPER_DECORATION_LAYOUT="close,minimize,maximize:"` finge o lado dos botões.
- `KIPPER_SYSTEM_TITLEBAR=1` volta para a barra do sistema (só para diagnóstico).
- `KIPPER_UPDATE_MANIFEST=http://127.0.0.1:porta/atualizacoes.json` testa a atualização com um
  servidor local (só aceita endereços deste computador).
- `./build/drift --agent-access` liga a porta de agente (MCP), que dá para usar para montar
  projetos de teste (`import_media`, `place_clip`, `add_text`, `set_project_setup`...).

## Em aberto

- **Complementos (fontes, LUTs, modelos das legendas automáticas):** o Drift baixa de um servidor
  da CutWire (`drift-addons.cutwire.org`). Efeitos, transições e efeitos de áudio já vêm junto com
  o Kipper. O ideal é o Kipper ter cópia própria desses pacotes (GitHub Releases + índice no site).
- **Atualização com um clique:** Windows (instalador silencioso, sem pedir administrador), AppImage
  (troca o arquivo), `.deb` (`pkexec apt-get install -y`), `.rpm` (`pkexec dnf install -y`) e
  Flatpak/Matsu OS (`flatpak-spawn --host flatpak install --reinstall --bundle`, depois
  `flatpak run`). Se a instalação não terminar, a próxima abertura mostra o comando para instalar à
  mão o arquivo já baixado. Testado de ponta a ponta só o `.deb`, aqui (com um `pkexec` falso, sem
  polkit); os scripts do `.rpm` e do Flatpak rodam em `tests/tst_kipperupdate.cpp` com programas
  falsos. Fedora Atomic (rpm em camada) ainda abre a página da versão.
- **Testes no Windows:** o Drift corrigiu em 14/11/2026 (f5fe6930) o `McpTest::proxyOpsCreateCheckAndRemove`
  (o proxy era apagado com leitores ainda abertos). Nas versões de teste o instalador do Windows sai
  mesmo com teste falhando (o trabalho fica vermelho); na oficial, bloqueia.
- **Leve em repouso (bandeja, instância única):** para um editor de vídeo, ficar perto do relógio
  não faz muito sentido. Ainda não foi avaliado nem mexido.
- **Windows:** compila no GitHub Actions; ainda não foi aberto numa máquina Windows de verdade.
- **Celular (APK):** depois do computador, como combinado. O Drift já tem a versão Android.
