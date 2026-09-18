# Audio-To-Text

> **Offline AI transcription for Windows.** Drop an audio or video file, get an accurate, corrected, domain-aware transcript - powered by Whisper, running 100% locally. No cloud, no subscription, no data leaving your machine.

![App](https://img.shields.io/badge/App-V11.1-8B5CF6?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11%20x64-0078D6?style=flat-square)
![Privacy](https://img.shields.io/badge/Privacy-100%25%20local-success?style=flat-square)

<!-- Screenshot: add docs/screenshot.png of the GUI here -->

## What it does

Audio-To-Text is a desktop app (PyQt6 dark UI) built on **faster-whisper** that turns recordings - meetings, site visits, dictations, interviews, videos - into clean text:

- **Drag and drop** audio/video (mp3, wav, m4a, mp4, mov, mkv...) or **record live** from the microphone (VU meter, pause/resume, silence trimming)
- **25 built-in domain dictionaries** (construction/BTP, NVH, medicine, law, accounting, mechanics, agile, and more) inject specialized vocabulary so technical terms come out right
- **Automatic domain detection** and smart file renaming via a local LLM (Ollama, optional) - and it can even generate a new domain dictionary on the fly
- **Post-processing**: regex correction dictionaries, ghost-phrase removal, confidence scoring with weak-word flagging
- **Exports**: TXT, Word (.docx), subtitles (.srt) with timestamps, AI summary (via Ollama)
- **4 speed/quality modes** (Fast to Multi-Pass), batch up to 500 files, ETA and live progress
- **Fully offline** - transcription runs on your CPU; the only downloads are the Whisper model (first run) and optional Ollama

## Install (users)

1. Download **`AudioToText_Setup_V11.1.exe`** from the [latest Release](../../releases/latest)
2. Double-click, follow the wizard (internet required once: dependencies ~400 MB, 3-10 min)
3. Launch from the desktop shortcut - drop a file, press GO

No Python, no FFmpeg, no command line. Everything is embedded and isolated in the install folder; uninstalling never touches your transcriptions.

Optional: install [Ollama](https://ollama.ai) + `qwen2.5:14b` to unlock auto domain detection, summaries, and smart renaming. The app works fully without it.

## How it works

| Layer | Tech |
|---|---|
| Transcription | faster-whisper 1.1.1 / ctranslate2 4.6.3 (CPU, pinned DLL-safe combo) |
| GUI | PyQt6 6.7.1, dark industrial theme, modular core (config/engine/workers/ui) |
| Audio | Embedded static FFmpeg (decode, probe, silence removal) |
| AI extras | Local Ollama (domain detection, summaries, renaming, dict generation) |
| Runtime | Python 3.12 embedded, fully isolated - zero impact on system PATH |

---

## For developers: building the installer

This repository contains the **installer kit** (Inno Setup pipeline) that produces the distributable .exe.

```powershell
# 1. Stage: downloads Python embedded + FFmpeg, copies the app source
powershell -ExecutionPolicy Bypass -File .\SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1 -SourceDir "path\to\app\source"

# 2. Compile: open AudioToText_Installer.iss in Inno Setup 6.x, Ctrl+F9
# 3. Ship output\AudioToText_Setup_V11.1.exe
```

Key design choices: Python embedded over PyInstaller (no 800 MB blob, no DLL roulette), strictly pinned pip dependencies with a hard ctranslate2==4.6.3 guard (validated against a known PyQt6 DLL access-violation), `python312._pth` pre-patched in the build, self-logging post-install (`logs\post_install.log` on every client machine). Full details in [docs/](docs/) and [CHANGELOG.md](CHANGELOG.md).

```
AudToText/
|-- AudioToText_Installer.iss              # Inno Setup script
|-- SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1  # Build staging (downloads + copy)
|-- scripts/                               # Client launcher + pinned pip post-install
|-- docs/                                  # Build guide
|-- build/ output/                         # Staged artifacts (gitignored)
```

## Credits

Developed by Fabian DEBLAIS, pair-built with Claude (Anthropic): architecture, DLL conflict diagnosis, packaging pipeline.

## License

[MIT](LICENSE) - Fabian DEBLAIS, 2026.
