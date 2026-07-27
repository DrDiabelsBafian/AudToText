# Changelog

All notable changes to the installer kit. Format: Keep a Changelog, semver on the kit version.

## [2.0] - 2026-07-27

Kit synced to Audio-To-Text V11 (modular). First GitHub-ready release.

### Added
- `scripts/AudioToText.bat` launcher: detached pythonw process, no console,
  embedded FFmpeg prepended to PATH (client has no AI_CORE wrappers)
- torch 2.6.0 CPU install in `post_install.bat` (required by `core/config.py`)
- sounddevice, numpy, python-docx (mic recording + DOCX export)
- Hard post-install guard: fails if ctranslate2 is not exactly 4.6.3
- Prep-build `-SourceDir` / `-SkipDownloads` parameters, build warnings summary
- Repo hygiene: README, LICENSE (MIT), CONTRIBUTING, .gitignore

### Changed
- `AppVersion` 4.1 -> 11.0
- `.iss` installs `app\` recursively: GUI + `core/` modules + dictionaries
  (V1 copied a single monolithic .py - would not boot V11)
- All pip dependencies strictly pinned (ctranslate2==4.6.3, PyQt6==6.7.1,
  faster-whisper==1.1.1) to the validated DLL combination
- Working dirs aligned to V11 layout (IN/OUT/etc. next to the GUI script)
- `SetupIconFile` conditional: kit compiles without an icon
- Prep-build: `$ErrorActionPreference = "Continue"` + targeted try/catch

### Removed
- `config.json` generation and custom output-dir wizard page: V11 self-manages
  its hidden `.audioToText.cfg` with a different schema (the old file was dead weight)

## [1.0] - 2026-02-19

Initial kit: .iss targeting GUI V4.1 monolith, prep-build V1, post_install V1
(unpinned dependencies), build guide.
