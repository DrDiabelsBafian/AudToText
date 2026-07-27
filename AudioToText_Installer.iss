; ============================================================
; INSTALLER Inno Setup - Audio-To-Text
; Version: 2.0 | Build: 27-07-26 | Target GUI: V11.0 (modular)
; Requires: Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
;
; V2 CHANGES vs V1 (19-02-26):
;   - AppVersion 4.1 -> 11.0
;   - app\ installed recursively: GUI + core\ + PROMPTS\ + CORRECTIONS\
;   - Removed config.json generation (V11 self-manages .audioToText.cfg)
;   - Removed custom output-dir wizard page (obsolete with V11 config)
;   - Workspace dirs = V11 layout (IN/OUT/etc. next to the GUI script)
;   - python312._pth patch simplified (GUI self-inserts its dir in sys.path)
;   - SetupIconFile conditional (compiles without icon)
; ============================================================

#define MyAppName "Audio-To-Text"
#define MyAppVersion "11.0"
#define MyAppPublisher "Fabian DEBLAIS"
#define MyAppExeName "AudioToText.bat"

[Setup]
AppId={{A2T-FABIAN-2026-AUDIO-TO-TEXT}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\AudioToText
DefaultGroupName={#MyAppName}
OutputDir=output
OutputBaseFilename=AudioToText_Setup_V{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
#if FileExists(AddBackslash(SourcePath) + "assets\icon.ico")
SetupIconFile=assets\icon.ico
UninstallDisplayIcon={app}\assets\icon.ico
#endif
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Messages]
french.WelcomeLabel2=Cet assistant va installer Audio-To-Text V11 sur votre ordinateur.%n%nIl va configurer :%n  - Python 3.12 (embarque)%n  - FFmpeg (embarque)%n  - PyQt6, faster-whisper, torch CPU (telechargement auto, ~400 MB)%n%nConnexion internet requise pour la premiere installation.

; ============================================================
; FILES
; ============================================================
[Files]
; Python 3.12 embedded (pre-extrait dans build\python)
Source: "build\python\*"; DestDir: "{app}\bin\python"; Flags: ignoreversion recursesubdirs

; FFmpeg static (pre-extrait)
Source: "build\ffmpeg\ffmpeg.exe"; DestDir: "{app}\bin\ffmpeg"; Flags: ignoreversion
Source: "build\ffmpeg\ffprobe.exe"; DestDir: "{app}\bin\ffmpeg"; Flags: ignoreversion skipifsourcedoesntexist

; get-pip.py
Source: "build\get-pip.py"; DestDir: "{app}\bin"; Flags: ignoreversion

; App V11 COMPLETE: GUI + core\ + PROMPTS\ + CORRECTIONS\ (recursif)
; Le contenu est prepare par SCRIPT_Prep-Build (copie depuis le projet dev)
Source: "build\app\*"; DestDir: "{app}\app"; Flags: ignoreversion recursesubdirs createallsubdirs

; Scripts
Source: "build\scripts\AudioToText.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\scripts\post_install.bat"; DestDir: "{app}\bin"; Flags: ignoreversion

; Assets
Source: "assets\icon.ico"; DestDir: "{app}\assets"; Flags: ignoreversion skipifsourcedoesntexist

; ============================================================
; DIRECTORIES - layout V11: dossiers de travail A COTE du script GUI
; (core/config.py resout les chemins relativement au dossier de l'app;
;  la GUI les recree au boot mais on les pre-cree pour l'uninstall propre)
; ============================================================
[Dirs]
Name: "{app}\app\IN"
Name: "{app}\app\OUT"
Name: "{app}\app\DICTIONNAIRE"
Name: "{app}\app\CORRECTIONS"
Name: "{app}\app\ARCHIVE"
Name: "{app}\app\TEMP"
Name: "{app}\app\ARCHIVE_CR"
Name: "{app}\logs"

; ============================================================
; ICONS
; ============================================================
[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\assets\icon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\assets\icon.ico"; Tasks: desktopicon
Name: "{group}\Dossier Transcriptions (OUT)"; Filename: "{app}\app\OUT"
Name: "{group}\Desinstaller {#MyAppName}"; Filename: "{uninstallexe}"

[Tasks]
Name: "desktopicon"; Description: "Creer un raccourci sur le Bureau"; GroupDescription: "Raccourcis:"

; ============================================================
; POST-INSTALL - pip + dependances pinnees
; ============================================================
[Run]
; Etape 1 : bootstrap pip dans le Python embedded
Filename: "{app}\bin\python\python.exe"; Parameters: """{app}\bin\get-pip.py"" --no-warn-script-location"; WorkingDir: "{app}\bin"; StatusMsg: "Installation de pip..."; Flags: runhidden waituntilterminated

; Etape 2 : dependances Python PINNEES (torch CPU + PyQt6 6.7.1 + ctranslate2 4.6.3 + faster-whisper 1.1.1)
Filename: "{app}\bin\post_install.bat"; Parameters: """{app}"""; WorkingDir: "{app}"; StatusMsg: "Installation des dependances (torch, PyQt6, faster-whisper) - environ 400 MB, patienter..."; Flags: runhidden waituntilterminated

; Etape 3 : lancer l'app apres install (optionnel)
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer Audio-To-Text maintenant"; Flags: nowait postinstall skipifsilent shellexec

; ============================================================
; REGISTRY
; ============================================================
[Registry]
Root: HKCU; Subkey: "Software\AudioToText"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\AudioToText"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey

; ============================================================
; UNINSTALL - on ne supprime JAMAIS les donnees utilisateur
; (OUT, IN, ARCHIVE, ARCHIVE_CR et .audioToText.cfg sont preserves)
; ============================================================
[UninstallDelete]
Type: filesandordirs; Name: "{app}\bin\python\Lib"
Type: filesandordirs; Name: "{app}\bin\python\Scripts"
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\app\TEMP"
Type: filesandordirs; Name: "{app}\app\__pycache__"
Type: filesandordirs; Name: "{app}\app\core\__pycache__"

; ============================================================
; CODE - patch python312._pth (active import site pour pip)
; NOTE: pas de chemin app ici, la GUI fait sys.path.insert(0, ...)
; ============================================================
[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    SaveStringToFile(
      ExpandConstant('{app}\bin\python\python312._pth'),
      'python312.zip' + #13#10 +
      '.' + #13#10 +
      'Lib\site-packages' + #13#10 +
      'import site' + #13#10,
      False
    );
  end;
end;

