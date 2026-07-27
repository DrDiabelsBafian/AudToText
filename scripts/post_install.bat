@echo off
:: ============================================================
:: Post-Install: pip install dependencies (V2 - 23-07-26)
:: Called by Inno Setup during installation
:: Arg1 = APP_DIR (install path)
::
:: V2 CHANGES (DLL safety - see Beta Audio venv reference):
::   - ALL versions pinned: ctranslate2==4.6.3 PyQt6==6.7.1
::     faster-whisper==1.1.1 torch==2.6.0+cpu
::   - torch CPU added (required by core/config.py)
::   - sounddevice numpy python-docx requests added (mic, DOCX export)
::   - ctranslate2 version guard in verification step
:: NEVER upgrade ctranslate2 beyond 4.6.3 without full DLL test
:: ============================================================

set "APP_DIR=%~1"
if "%APP_DIR%"=="" set "APP_DIR=%~dp0.."

set "PYTHON=%APP_DIR%\bin\python\python.exe"

echo ============================================
echo  Audio-To-Text - Installation dependances
echo ============================================
echo.

:: Check Python
if not exist "%PYTHON%" (
    echo [FAIL] Python introuvable: %PYTHON%
    exit /b 1
)

echo [1/5] Mise a jour pip...
"%PYTHON%" -m pip install --upgrade pip --no-warn-script-location --quiet 2>nul

echo [2/5] Installation torch CPU (environ 200 MB, patienter)...
"%PYTHON%" -m pip install torch==2.6.0 --index-url https://download.pytorch.org/whl/cpu --no-warn-script-location --quiet
if errorlevel 1 (
    echo [WARN] torch install failed, retry verbose...
    "%PYTHON%" -m pip install torch==2.6.0 --index-url https://download.pytorch.org/whl/cpu --no-warn-script-location
)

echo [3/5] Installation combo pinne (PyQt6 + ctranslate2 + faster-whisper)...
"%PYTHON%" -m pip install PyQt6==6.7.1 ctranslate2==4.6.3 faster-whisper==1.1.1 --no-warn-script-location --quiet
if errorlevel 1 (
    echo [WARN] combo install failed, retry verbose...
    "%PYTHON%" -m pip install PyQt6==6.7.1 ctranslate2==4.6.3 faster-whisper==1.1.1 --no-warn-script-location
)

echo [4/5] Installation deps annexes (micro + DOCX)...
"%PYTHON%" -m pip install sounddevice numpy python-docx requests --no-warn-script-location --quiet
if errorlevel 1 (
    echo [WARN] annex deps install failed, retry verbose...
    "%PYTHON%" -m pip install sounddevice numpy python-docx requests --no-warn-script-location
)

echo [5/5] Verification...
set "VERIFY_FAIL=0"

"%PYTHON%" -c "import torch; print('[OK] torch', torch.__version__)"
if errorlevel 1 set "VERIFY_FAIL=1"

"%PYTHON%" -c "import PyQt6.QtCore; print('[OK] PyQt6', PyQt6.QtCore.PYQT_VERSION_STR)"
if errorlevel 1 set "VERIFY_FAIL=1"

"%PYTHON%" -c "import faster_whisper; print('[OK] faster-whisper')"
if errorlevel 1 set "VERIFY_FAIL=1"

:: Guard critique: ctranslate2 doit etre EXACTEMENT 4.6.3
"%PYTHON%" -c "import ctranslate2, sys; v = ctranslate2.__version__; print('[OK] ctranslate2', v); sys.exit(0 if v == '4.6.3' else 2)"
if errorlevel 2 (
    echo [FAIL] ctranslate2 PAS en 4.6.3 - risque segfault DLL avec PyQt6
    set "VERIFY_FAIL=1"
) else (
    if errorlevel 1 set "VERIFY_FAIL=1"
)

"%PYTHON%" -c "import sounddevice, numpy; print('[OK] sounddevice + numpy', numpy.__version__)"
if errorlevel 1 echo [WARN] sounddevice/numpy absent - bouton micro desactive

"%PYTHON%" -c "import docx; print('[OK] python-docx')"
if errorlevel 1 echo [WARN] python-docx absent - export DOCX desactive

echo.
if "%VERIFY_FAIL%"=="1" (
    echo ============================================
    echo  Installation INCOMPLETE - voir erreurs ci-dessus
    echo ============================================
    exit /b 1
)

echo ============================================
echo  Installation terminee
echo ============================================

exit /b 0
