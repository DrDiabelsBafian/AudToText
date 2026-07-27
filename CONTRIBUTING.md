# Contributing to AudioToText-Installer

## How to contribute

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m "Add: my feature"`)
4. Push to your branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## Commit conventions

- `Add:` - new feature or file
- `Fix:` - bug fix
- `Refactor:` - code restructuring (no behavior change)
- `Docs:` - documentation only

## Code style

- Batch files (.bat): 100% ASCII, no accented characters (Windows-1252 execution),
  always quote paths (`"%APP_DIR%"`)
- PowerShell (.ps1): ASCII-only console output, `$ErrorActionPreference = "Continue"`
  with targeted try/catch, end with summary + `Read-Host` pause
- Inno Setup (.iss): keep `PrivilegesRequired=lowest`, never delete user data
  on uninstall (OUT/, IN/, ARCHIVE/, .audioToText.cfg)

## Hard rules (do not break)

- Python stays 3.12.x (ctranslate2/faster-whisper constraint)
- ctranslate2 stays pinned to 4.6.3 unless the full DLL combination with PyQt6
  has been re-tested (known access-violation conflict)
- No PyInstaller, no bundled Ollama, no bundled Whisper models

## Bug reports

Open a GitHub Issue with:
- Steps to reproduce
- Expected vs actual behavior
- Windows version + install path (Program Files vs AppData)
