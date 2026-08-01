@echo off
:: ============================================================
:: Post-Install: pip install dependencies (V3 - 31-07-26)
:: Called by Inno Setup during installation
:: Arg1 = APP_DIR (install path)
::
:: V3 CHANGES:
::   - SELF-LOGGING: toute la sortie va dans logs\post_install.log
::     (indispensable: Inno runhidden avale stdout/stderr)
::   - Diagnostics env en tete de log (python, pip, reseau pypi)
::   - Pip VERBOSE (--quiet retire) pour diagnostic complet
:: V2: pins ctranslate2==4.6.3 PyQt6==6.7.1 torch==2.6.0+cpu
::     faster-whisper==1.1.1 + sounddevice numpy python-docx requests
:: NEVER upgrade ctranslate2 beyond 4.6.3 without full DLL test
:: ============================================================

set "APP_DIR=%~1"
if "%APP_DIR%"=="" set "APP_DIR=%~dp0.."

set "PYTHON=%APP_DIR%\bin\python\python.exe"
set "LOGDIR=%APP_DIR%\logs"
set "LOGFILE=%LOGDIR%\post_install.log"

if not exist "%LOGDIR%" mkdir "%LOGDIR%" 2>nul

call :main > "%LOGFILE%" 2>&1
exit /b %errorlevel%

:: ============================================================
:main
echo ============================================
echo  Audio-To-Text - Installation dependances V3
echo  %date% %time%
echo ============================================
echo.

:: --- Diagnostics environnement ---
echo [DIAG] APP_DIR = %APP_DIR%
echo [DIAG] PYTHON  = %PYTHON%
echo [DIAG] CD      = %cd%
echo [DIAG] USERPROFILE = %USERPROFILE%

if not exist "%PYTHON%" (
    echo [FAIL] Python introuvable: %PYTHON%
    exit /b 1
)

"%PYTHON%" --version
if errorlevel 1 (
    echo [FAIL] python.exe ne s'execute pas - code %errorlevel%
    exit /b 1
)

"%PYTHON%" -m pip --version
if errorlevel 1 (
    echo [FAIL] pip absent ou casse - code %errorlevel%
    exit /b 1
)

"%PYTHON%" -c "import urllib.request; urllib.request.urlopen('https://pypi.org', timeout=15); print('[DIAG] Reseau pypi.org OK')"
if errorlevel 1 echo [WARN] pypi.org inaccessible depuis ce contexte - les pip vont echouer

echo.
echo [1/4] Installation torch CPU (environ 200 MB, patienter)...
"%PYTHON%" -m pip install torch==2.6.0 --index-url https://download.pytorch.org/whl/cpu --no-warn-script-location
if errorlevel 1 echo [WARN] torch install code %errorlevel%

echo.
echo [2/4] Installation combo pinne (PyQt6 + ctranslate2 + faster-whisper)...
"%PYTHON%" -m pip install PyQt6==6.7.1 ctranslate2==4.6.3 faster-whisper==1.1.1 --no-warn-script-location
if errorlevel 1 echo [WARN] combo install code %errorlevel%

echo.
echo [3/4] Installation deps annexes (micro + DOCX + requests)...
"%PYTHON%" -m pip install sounddevice numpy python-docx requests --no-warn-script-location
if errorlevel 1 echo [WARN] annex deps code %errorlevel%

echo.
echo [4/4] Verification...
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

"%PYTHON%" -c "import requests; print('[OK] requests')"
if errorlevel 1 set "VERIFY_FAIL=1"

echo.
if "%VERIFY_FAIL%"=="1" (
    echo ============================================
    echo  Installation INCOMPLETE - voir erreurs ci-dessus
    echo ============================================
    exit /b 1
)

echo ============================================
echo  Installation terminee %date% %time%
echo ============================================
exit /b 0
