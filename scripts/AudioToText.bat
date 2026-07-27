@echo off
:: ============================================================
:: AudioToText.bat - Lanceur (V1 - 27-07-26)
:: Double-clic -> GUI PyQt6 sans console visible
::
:: - pythonw.exe embedded + start "" = processus detache
::   (regle projet: jamais de console derriere la fenetre)
:: - bin\ffmpeg ajoute au PATH: la GUI appelle 'ffmpeg'/'ffprobe'
::   par nom via subprocess (le client n'a pas AI_CORE)
:: - cd vers app\ : les dossiers IN/OUT/PROMPTS/CORRECTIONS
::   sont resolus par core\config.py relativement au script GUI
:: ============================================================

set "APP_DIR=%~dp0"
set "PATH=%APP_DIR%bin\ffmpeg;%APP_DIR%bin\python;%APP_DIR%bin\python\Scripts;%PATH%"

if not exist "%APP_DIR%bin\python\pythonw.exe" (
    echo [FAIL] Python embedded introuvable: %APP_DIR%bin\python\pythonw.exe
    echo Reinstaller Audio-To-Text.
    pause
    exit /b 1
)

if not exist "%APP_DIR%app\GUI_Audio-To-Text.py" (
    echo [FAIL] Application introuvable: %APP_DIR%app\GUI_Audio-To-Text.py
    echo Reinstaller Audio-To-Text.
    pause
    exit /b 1
)

cd /d "%APP_DIR%app"
start "" "%APP_DIR%bin\python\pythonw.exe" "%APP_DIR%app\GUI_Audio-To-Text.py"
exit /b 0
