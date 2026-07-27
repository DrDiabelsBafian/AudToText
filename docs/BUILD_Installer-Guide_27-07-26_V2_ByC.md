# BUILD GUIDE - Installeur Audio-To-Text V11

**Version kit** : 2.0 | **Date** : 27-07-26 | **Auteur** : Claude (Fable) + Fabian
**Remplace** : BUILD_Installer-Guide_19-02-26_V1_ByC.md

---

## PIPELINE COMPLET (3 commandes)

```powershell
# 1. Staging: telecharge Python embedded + FFmpeg, copie GUI V11 + core + dictionnaires
powershell -ExecutionPolicy Bypass -File .\SCRIPT_Prep-Build_27-07-26_V2_ByC.ps1

# 2. Compiler: ouvrir AudioToText_Installer.iss dans Inno Setup 6.x -> Ctrl+F9

# 3. Livrable: output\AudioToText_Setup_V11.0.exe (~60-80 MB)
```

Source app par defaut : `Desktop\Beta Audio` (projet V11).
Autre source : `-SourceDir "C:\chemin\vers\projet"`.

---

## ARBORESCENCE INSTALLEE (client)

```
{app}\                                 (AppData\...\Programs\AudioToText si non-admin)
|-- AudioToText.bat                    << LANCEUR double-clic (pythonw detache, zero console)
|-- bin\
|   |-- python\                        << Python 3.12.8 embedded
|   |   |-- python.exe / pythonw.exe
|   |   |-- python312._pth             << Patche par l'installeur (import site)
|   |   +-- Lib\site-packages\         << deps pip pinnees
|   |-- ffmpeg\
|   |   |-- ffmpeg.exe
|   |   +-- ffprobe.exe
|   |-- get-pip.py
|   +-- post_install.bat
|-- app\
|   |-- GUI_Audio-To-Text.py           << Entry point V11
|   |-- core\                          << config / engine / workers / ui_components
|   |-- PROMPTS\  CORRECTIONS\         << Dictionnaires embarques
|   |-- IN\ OUT\ ARCHIVE\ TEMP\ ARCHIVE_CR\   << Dossiers de travail (donnees user)
|   +-- .audioToText.cfg               << Config cachee, geree par la GUI elle-meme
|-- assets\icon.ico
+-- logs\
```

Le lanceur fait `cd app\` puis lance pythonw : les chemins relatifs de
`core\config.py` resolvent IN/OUT/etc. dans `app\`. Il prepend aussi
`bin\ffmpeg` au PATH (le client n'a pas les wrappers AI_CORE).

---

## DEPENDANCES PIP (post_install.bat - PINNEES, NE PAS DEVERROUILLER)

| Paquet | Version | Raison |
|---|---|---|
| torch | 2.6.0+cpu (index pytorch CPU) | importe par core/config.py au boot |
| PyQt6 | 6.7.1 | combo DLL valide |
| ctranslate2 | 4.6.3 EXACT (guard hard-fail) | >4.6.3 = segfault DLL avec PyQt6 (incident 21-03-26) |
| faster-whisper | 1.1.1 | compatible ct2 4.6.3 |
| sounddevice, numpy | latest | micro (WARN non bloquant si echec) |
| python-docx | latest | export DOCX (WARN non bloquant) |

Ordre d'INSTALL libre. Ordre d'IMPORT critique (torch/ct2 avant PyQt6) :
gere par la GUI V11, rien a faire cote installeur.

---

## CHECKLIST TEST (VM propre ou machine sans Python)

- [ ] Wizard s'affiche, francais, pas de page "dossier de sortie" (supprimee en V2)
- [ ] Post-install pip sans erreur (internet requis, ~400 MB, 5-10 min)
- [ ] Log post-install : ctranslate2 4.6.3 confirme (guard)
- [ ] Raccourci Bureau -> GUI se lance SANS console visible
- [ ] Badges FFmpeg + Whisper verts (Ollama rouge = normal)
- [ ] Combo Vocabulaire liste les domaines embarques
- [ ] Drag audio -> duree affichee -> transcription Standard OK
- [ ] Premier run : download modele Whisper dans %USERPROFILE%\.cache\huggingface\
- [ ] Micro : enregistrement + ajout file OK
- [ ] Reinstall par-dessus : OUT\ et .audioToText.cfg preserves
- [ ] Desinstallation : OUT\ IN\ ARCHIVE\ conserves, bin\ et logs\ supprimes

---

## DECISIONS ACTEES (inchangees depuis V1)

1. Python embedded 3.12 exact (pas system, pas 3.13+)
2. Pas de PyInstaller (800MB+, DLL natives fragiles)
3. Ollama exclu (500MB+, detecte au runtime ; modele attendu : qwen2.5:14b)
4. Modeles Whisper exclus (download au premier usage)
5. Donnees utilisateur JAMAIS supprimees a la desinstallation
6. .bat pour les scripts d'install (pas de .ps1 : ExecutionPolicy), ASCII pur
7. PrivilegesRequired=lowest (install sans admin)

## NOUVEAU EN V2

8. Deps pinnees = clone du venv Beta Audio valide (regle absolue ct2 4.6.3)
9. app\ installe recursivement (structure modulaire V11)
10. config.json abandonne : V11 gere .audioToText.cfg seul (schema different)
11. Lanceur detache pythonw + PATH ffmpeg embarque

---

## METADATA

```
URI: BUILD_Installer-Guide-AudioToText_27-07-26_V2_ByC
Date: 2026-07-27
Projet: #audio-to-text (kit installeur)
Type: BUILD
OS: Windows 11
Deps: Inno Setup 6.x, Python 3.12.8 embed, FFmpeg static gyan.dev
```
