; Instalador do Kipper para Windows 10 e 11 (Inno Setup 6).
;
; Padrão dos apps do criador: instala só para o usuário (não pede administrador), em português
; do Brasil (inglês como opção), com visual moderno e a marca do Kipper. O arquivo final se chama
; Kipper-Windows.exe (o fluxo do GitHub Actions renomeia).
;
;    /DMyAppVersion=x.y.z  versão gravada no instalador e em Aplicativos instalados
;    /DMyAppSource=pasta   pasta com drift.exe e tudo que o windeployqt copiou
;    /DNightly             canal de teste: outro AppId, outro nome, convive com a versão oficial
;
; Nunca mude o AppId: é ele que faz o instalador atualizar a instalação existente no lugar,
; em vez de deixar duas cópias.

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#ifndef MyAppSource
  #define MyAppSource "dist\\bin"
#endif

#ifdef Arm64
  #define Arch "arm64"
  #define MyArchSpec "arm64"
#else
  #define Arch "x64"
  #define MyArchSpec "x64compatible"
#endif

#ifdef Nightly
  #define MyAppName "Kipper Teste"
  #define MyAppId "AA6D313C-E1E4-4A4E-83DF-A58A45CEF6CF"
  #define MyOutputBase "Kipper-Windows-Teste-" + Arch
#else
  #define MyAppName "Kipper"
  #define MyAppId "B94B2C08-26D6-4BD0-B329-C1C6AE4A08EC"
  #define MyOutputBase "Kipper-Windows-" + Arch
#endif
#define MyAppPublisher "Kipper"
; O executável compilado se chama drift.exe (nome interno do código do Drift); instalado, vira
; Kipper.exe, que é o que aparece no Gerenciador de Tarefas e nos atalhos.
#define MyAppExeName "Kipper.exe"

[Setup]
AppId={{{#MyAppId}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://github.com/kaikydev1-jpg/KIPPER
AppSupportURL=https://github.com/kaikydev1-jpg/KIPPER/issues
AppUpdatesURL=https://github.com/kaikydev1-jpg/KIPPER/releases
AppCopyright=GPL-3.0-or-later · Baseado no Drift, da CutWire Studios
VersionInfoVersion={#MyAppVersion}
VersionInfoDescription=Instalador do {#MyAppName}

; Só para o usuário, sem administrador: vai para %LOCALAPPDATA%\Programs\Kipper.
PrivilegesRequired=lowest
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Pasta escolhida automaticamente; numa atualização nem pergunta.
DisableDirPage=auto
DisableReadyPage=yes
UsePreviousAppDir=yes
CloseApplications=yes
RestartApplications=no

ArchitecturesAllowed={#MyArchSpec}
ArchitecturesInstallIn64BitMode={#MyArchSpec}
MinVersion=10.0.17763
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes

; Visual: estilo moderno, um pouco maior, com as imagens do pinguim.
WizardStyle=modern
WizardSizePercent=110
WizardResizable=no
WizardImageFile=kipper-wizard-100.bmp,kipper-wizard-125.bmp,kipper-wizard-150.bmp,kipper-wizard-200.bmp
WizardSmallImageFile=kipper-small-100.bmp,kipper-small-125.bmp,kipper-small-150.bmp,kipper-small-200.bmp
WizardImageStretch=yes
SetupIconFile=..\..\resources\windows\drift.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
#ifndef Nightly
ChangesAssociations=yes
#endif
OutputDir=output
OutputBaseFilename={#MyOutputBase}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
brazilianportuguese.OpenProjectWith=Projeto do Kipper
english.OpenProjectWith=Kipper project

[Messages]
; Textos das páginas de boas-vindas e de conclusão no tom do Kipper.
brazilianportuguese.WelcomeLabel1=Boas-vindas ao [name]
brazilianportuguese.WelcomeLabel2=Editor de vídeo gratuito, do primeiro corte ao filme inteiro.%n%nSem marca d'água, sem conta e sem assinatura. Tudo roda no seu computador.%n%nO [name] vai ser instalado só para o seu usuário, sem pedir administrador.
brazilianportuguese.FinishedHeadingLabel=Tudo pronto
brazilianportuguese.FinishedLabelNoIcons=O [name] foi instalado.
brazilianportuguese.FinishedLabel=O [name] foi instalado. Ele está no menu Iniciar.
english.WelcomeLabel1=Welcome to [name]
english.WelcomeLabel2=A free video editor, from your first cut to a whole film.%n%nNo watermark, no account and no subscription. Everything runs on your computer.%n%n[name] installs for your user only, without asking for administrator.
english.FinishedHeadingLabel=All set
english.FinishedLabelNoIcons=[name] is installed.
english.FinishedLabel=[name] is installed. You can find it in the Start menu.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[InstallDelete]
; Restos de uma versão anterior com outro nome do executável.
Type: files; Name: "{app}\drift.exe"

[Files]
; Recursivo: além do executável e do Qt, leva as pastas effects\, transitions\,
; effect-templates\ e audio-effects\, que o app procura ao lado do executável.
Source: "{#MyAppSource}\drift.exe"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Flags: ignoreversion
Source: "{#MyAppSource}\*"; DestDir: "{app}"; Excludes: "drift.exe"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "io.github.kaikydev1jpg.Kipper"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

#ifndef Nightly
; Abrir arquivos .drift (projetos) com o Kipper. HKA = registro do próprio usuário quando a
; instalação é por usuário, então também não precisa de administrador.
[Registry]
Root: HKA; Subkey: "Software\Classes\.drift"; ValueType: string; ValueName: ""; ValueData: "Kipper.Project"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\Kipper.Project"; ValueType: string; ValueName: ""; ValueData: "{cm:OpenProjectWith}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Kipper.Project\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\Kipper.Project\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
#endif

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
; Atualização com um clique: o app roda o instalador com /S /DRIFTUPDATE=1 e espera abrir de novo.
Filename: "{app}\{#MyAppExeName}"; Flags: nowait; Check: LaunchAfterSilentUpdate

[Code]
function LaunchAfterSilentUpdate: Boolean;
begin
  Result := (ExpandConstant('{param:DRIFTUPDATE|}') = '1') or (ExpandConstant('{param:KIPPERUPDATE|}') = '1');
end;
