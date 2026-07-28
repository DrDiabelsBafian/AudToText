# ============================================================
# SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1
# Prepare le dossier build\ pour Inno Setup - cible GUI V11 (modulaire)
#
# USAGE: powershell -ExecutionPolicy Bypass -File .\SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1
#        Options: -SourceDir "chemin projet dev" -SkipDownloads
#
# V2 CHANGES vs V1 (19-02-26):
#   - Copie la structure V11: GUI + core\*.py (plus de monolithe)
#   - Copie les dictionnaires: PROMPTS\ CORRECTIONS\ DICTIONNAIRE\ (ceux presents)
#   - Copie scripts\ du repo vers build\scripts\ (lanceur + post_install)
#   - Source par defaut: Desktop\Beta Audio (projet V11)
#   - ErrorActionPreference Continue + try/catch cibles (regle 30)
# ============================================================

param(
    [string]$SourceDir = (Join-Path ([Environment]::GetFolderPath("Desktop")) "Beta Audio"),
    [switch]$SkipDownloads
)

$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$buildDir = Join-Path $PSScriptRoot "build"
$warnings = @()

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Audio-To-Text V11 - Preparation Build" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Source app: $SourceDir" -ForegroundColor DarkGray
Write-Host ""

# --- [0/5] Arborescence ---
$dirs = @("build\python", "build\ffmpeg", "build\app", "build\scripts", "output", "assets")
foreach ($d in $dirs) {
    $path = Join-Path $PSScriptRoot $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "[OK] Cree: $d" -ForegroundColor Green
    }
}

# --- [1/5] Python 3.12 Embedded ---
$pyDir = Join-Path $buildDir "python"
if ($SkipDownloads) {
    Write-Host "[1/5] Downloads sautes (-SkipDownloads)" -ForegroundColor DarkYellow
} elseif (-not (Test-Path (Join-Path $pyDir "python.exe"))) {
    Write-Host "[1/5] Telechargement Python 3.12.8 embedded..." -ForegroundColor Yellow
    try {
        $pyZip = Join-Path $env:TEMP "python-3.12.8-embed-amd64.zip"
        $pyUrl = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-embed-amd64.zip"
        Invoke-WebRequest -Uri $pyUrl -OutFile $pyZip -UseBasicParsing
        Expand-Archive -Path $pyZip -DestinationPath $pyDir -Force
        Write-Host "[OK] Python 3.12 embedded pret" -ForegroundColor Green
    } catch {
        $warnings += "Python embedded: telechargement echoue ($_)"
        Write-Host "[FAIL] Python: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[1/5] Python 3.12 deja present" -ForegroundColor DarkGreen
}

# --- [2/5] FFmpeg Static ---
$ffDir = Join-Path $buildDir "ffmpeg"
if (-not $SkipDownloads -and -not (Test-Path (Join-Path $ffDir "ffmpeg.exe"))) {
    Write-Host "[2/5] Telechargement FFmpeg (gyan.dev essentials)..." -ForegroundColor Yellow
    try {
        $ffZip = Join-Path $env:TEMP "ffmpeg-essentials.zip"
        $ffUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        Invoke-WebRequest -Uri $ffUrl -OutFile $ffZip -UseBasicParsing
        $ffExtract = Join-Path $env:TEMP "ffmpeg_extract"
        Expand-Archive -Path $ffZip -DestinationPath $ffExtract -Force
        $ffBin = Get-ChildItem -Path $ffExtract -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
        Copy-Item $ffBin.FullName (Join-Path $ffDir "ffmpeg.exe") -Force
        $probeFile = Join-Path $ffBin.DirectoryName "ffprobe.exe"
        if (Test-Path $probeFile) { Copy-Item $probeFile (Join-Path $ffDir "ffprobe.exe") -Force }
        Remove-Item $ffExtract -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] FFmpeg pret" -ForegroundColor Green
    } catch {
        $warnings += "FFmpeg: telechargement echoue ($_)"
        Write-Host "[FAIL] FFmpeg: $_" -ForegroundColor Red
    }
} elseif (Test-Path (Join-Path $ffDir "ffmpeg.exe")) {
    Write-Host "[2/5] FFmpeg deja present" -ForegroundColor DarkGreen
}

# --- [3/5] get-pip.py ---
$getPip = Join-Path $buildDir "get-pip.py"
if (-not $SkipDownloads -and -not (Test-Path $getPip)) {
    Write-Host "[3/5] Telechargement get-pip.py..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip -UseBasicParsing
        Write-Host "[OK] get-pip.py pret" -ForegroundColor Green
    } catch {
        $warnings += "get-pip.py: telechargement echoue ($_)"
        Write-Host "[FAIL] get-pip: $_" -ForegroundColor Red
    }
} elseif (Test-Path $getPip) {
    Write-Host "[3/5] get-pip.py deja present" -ForegroundColor DarkGreen
}

# --- [4/5] App V11: GUI + core + dictionnaires ---
Write-Host "[4/5] Copie de l'application V11 depuis le projet dev..." -ForegroundColor Yellow
$appDest = Join-Path $buildDir "app"

if (-not (Test-Path $SourceDir)) {
    $warnings += "Source app introuvable: $SourceDir (utiliser -SourceDir)"
    Write-Host "[FAIL] Source introuvable: $SourceDir" -ForegroundColor Red
} else {
    # 4a. GUI: le plus recent GUI_Audio-To-Text*V11*.py, renomme en nom stable
    $guiFile = Get-ChildItem -Path $SourceDir -Filter "GUI_Audio-To-Text*V11*.py" -File |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $guiFile) {
        # Fallback: n'importe quelle GUI, la plus recente
        $guiFile = Get-ChildItem -Path $SourceDir -Filter "GUI_Audio-To-Text*.py" -File |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($guiFile) { $warnings += "GUI V11 non trouvee, fallback: $($guiFile.Name)" }
    }
    if ($guiFile) {
        Copy-Item $guiFile.FullName (Join-Path $appDest "GUI_Audio-To-Text.py") -Force
        Write-Host "[OK] GUI: $($guiFile.Name)" -ForegroundColor Green
    } else {
        $warnings += "Aucune GUI trouvee dans $SourceDir"
        Write-Host "[FAIL] Aucune GUI_Audio-To-Text*.py dans la source" -ForegroundColor Red
    }

    # 4b. core\ (modules V11) - obligatoire
    $coreSrc = Join-Path $SourceDir "core"
    if (Test-Path $coreSrc) {
        $coreDest = Join-Path $appDest "core"
        if (Test-Path $coreDest) { Remove-Item $coreDest -Recurse -Force }
        New-Item -ItemType Directory -Path $coreDest -Force | Out-Null
        Get-ChildItem -Path $coreSrc -Filter "*.py" -File | ForEach-Object {
            Copy-Item $_.FullName $coreDest -Force
        }
        $n = (Get-ChildItem $coreDest -Filter "*.py").Count
        Write-Host "[OK] core\ : $n modules copies" -ForegroundColor Green
        if ($n -lt 4) { $warnings += "core\ ne contient que $n modules (attendu: 4 - config, engine, workers, ui_components)" }
    } else {
        $warnings += "core\ ABSENT de la source - l'app installee ne demarrera PAS"
        Write-Host "[FAIL] core\ absent: $coreSrc" -ForegroundColor Red
    }

    # 4c. Dictionnaires: copier ceux qui existent (PROMPTS, CORRECTIONS, DICTIONNAIRE)
    $dictFound = 0
    foreach ($dictName in @("PROMPTS", "CORRECTIONS", "DICTIONNAIRE")) {
        $dictSrc = Join-Path $SourceDir $dictName
        if (Test-Path $dictSrc) {
            $dictDest = Join-Path $appDest $dictName; if (Test-Path $dictDest) { Remove-Item $dictDest -Recurse -Force }; Copy-Item $dictSrc $dictDest -Recurse -Force
            $nf = (Get-ChildItem (Join-Path $appDest $dictName) -Recurse -File).Count
            Write-Host "[OK] $dictName\ : $nf fichiers" -ForegroundColor Green
            $dictFound++
        }
    }
    if ($dictFound -eq 0) {
        $warnings += "Aucun dossier dictionnaire trouve (PROMPTS/CORRECTIONS/DICTIONNAIRE) - vocabulaire absent du package"
        Write-Host "[WARN] Aucun dictionnaire copie" -ForegroundColor Red
    }

    # 4d. Icone si presente dans la source
    $iconSrc = Get-ChildItem -Path $SourceDir -Filter "*.ico" -File -ErrorAction SilentlyContinue | Select-Object -First 1
    $iconDest = Join-Path $PSScriptRoot "assets\icon.ico"
    if ($iconSrc -and -not (Test-Path $iconDest)) {
        Copy-Item $iconSrc.FullName $iconDest -Force
        Write-Host "[OK] Icone: $($iconSrc.Name) -> assets\icon.ico" -ForegroundColor Green
    }
}

# --- [5/5] Scripts (lanceur + post_install depuis le repo) ---
Write-Host "[5/5] Copie des scripts..." -ForegroundColor Yellow
foreach ($bat in @("AudioToText.bat", "post_install.bat")) {
    $src = Join-Path $PSScriptRoot "scripts\$bat"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $buildDir "scripts\$bat") -Force
        Write-Host "[OK] scripts\$bat" -ForegroundColor Green
    } else {
        $warnings += "scripts\$bat manquant dans le repo"
        Write-Host "[FAIL] scripts\$bat manquant" -ForegroundColor Red
    }
}

# --- BILAN ---
$totalSize = 0
Get-ChildItem -Path $buildDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }
$sizeMB = [math]::Round($totalSize / 1MB, 1)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
if ($warnings.Count -eq 0) {
    Write-Host "  BUILD PRET - $sizeMB MB (compresse ~50-60% par Inno)" -ForegroundColor Green
} else {
    Write-Host "  BUILD INCOMPLET - $($warnings.Count) probleme(s)" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  [!] $w" -ForegroundColor Yellow }
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prochaine etape:" -ForegroundColor White
Write-Host "  1. Ouvrir AudioToText_Installer.iss dans Inno Setup" -ForegroundColor White
Write-Host "  2. Ctrl+F9 pour compiler" -ForegroundColor White
Write-Host "  3. Installeur genere dans: output\AudioToText_Setup_V11.0.exe" -ForegroundColor White
Write-Host ""
Read-Host "Entree pour fermer"

