# Audio-To-Text Installer Kit

> Windows installer pipeline for **Audio-To-Text V11** - an offline PyQt6 + faster-whisper transcription app. This repo builds a single distributable `AudioToText_Setup_V11.0.exe`: no Python, no FFmpeg, no setup required on the client machine.

![Version](https://img.shields.io/badge/Installer-2.0-blueviolet?style=flat-square)
![App](https://img.shields.io/badge/App-V11.0-8B5CF6?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.12%20embedded-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11%20x64-0078D6?style=flat-square)
![Builder](https://img.shields.io/badge/Builder-Inno%20Setup%206.x-lightgrey?style=flat-square)

<!-- Screenshot: add docs/screenshot.png of the installed GUI -->

## The Problem

Shipping a Python GUI app that depends on native DLLs (ctranslate2, torch, Qt) is fragile. PyInstaller produces 800+ MB blobs, breaks on native DLLs, and decompresses on every launch. System Python installs collide with whatever the user already has.

## The Solution

An Inno Setup installer that embeds an isolated **Python 3.12 embedded** runtime and **static FFmpeg**, then pip-installs a **strictly pinned** dependency set post-install. Isolation is total: nothing touches the system PATH, registry Python entries, or existing installs.

Dependency versions are pinned to a DLL combination validated against a known PyQt6/ctranslate2 access-violation conflict:

| Package | Version | Why pinned |
|---|---|---|
| ctranslate2 | 4.6.3 | Any newer version untested against PyQt6 DLLs (segfault risk) |
| PyQt6 | 6.7.1 | Validated Qt DLL set |
| torch | 2.6.0+cpu | Required by the app core, CPU index (no CUDA) |
| faster-whisper | 1.1.1 | Matches ctranslate2 4.6.3 |

## Quick Start (build the installer)

```powershell
# 1. Stage everything (downloads Python embedded + FFmpeg, copies the app)
powershell -ExecutionPolicy Bypass -File .\SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1

# 2. Open AudioToText_Installer.iss in Inno Setup 6.x, press Ctrl+F9

# 3. Ship output\AudioToText_Setup_V11.0.exe
```

Requires: Windows 10/11 x64, [Inno Setup 6.x](https://jrsoftware.org/isdl.php), and the Audio-To-Text V11 source project (GUI + `core/` modules + dictionaries).

## Features

- One .exe installer (~60-80 MB), no admin rights required (`PrivilegesRequired=lowest`)
- Python 3.12.8 embedded + static FFmpeg, fully isolated under the install dir
- Pinned pip dependency chain with a hard version guard on ctranslate2
- Detached launcher (`pythonw` + `start`), no console window behind the GUI
- User data (transcriptions, recordings, config) preserved on uninstall and upgrade
- Ollama and Whisper models intentionally excluded (detected/downloaded at runtime)

## Project Structure

```
AudioToText-Installer/
|-- AudioToText_Installer.iss            # Inno Setup script (main deliverable)
|-- SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1  # Stages build\ (downloads + app copy)
|-- scripts/
|   |-- AudioToText.bat                  # Client launcher (installed at {app}\)
|   +-- post_install.bat                 # Pinned pip install (runs during setup)
|-- docs/
|   +-- BUILD_Installer-Guide_27-07-26_V2_ByC.md
|-- assets/                              # icon.ico (optional, auto-detected)
|-- build/                               # Staged by prep-build (gitignored)
+-- output/                              # Compiled installers (gitignored)
```

Installed layout on the client:

```
{app}\
|-- AudioToText.bat            # Double-click launcher
|-- bin\python\                # Python 3.12 embedded + site-packages
|-- bin\ffmpeg\                # ffmpeg.exe + ffprobe.exe
+-- app\                       # GUI + core\ + PROMPTS\ + CORRECTIONS\
    |-- IN\  OUT\  ARCHIVE\    # Working dirs (user data, never deleted)
```

## How this was built

Designed and iterated with Claude (Anthropic) as pair-packager: dependency pinning strategy, DLL conflict diagnosis, and Inno Setup scripting. Architecture decisions (embedded Python over PyInstaller, runtime model download) documented in `docs/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) - Fabian DEBLAIS, 2026.
