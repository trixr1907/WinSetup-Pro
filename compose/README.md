# Compose-Dateien (Container-First Services)

Diese `docker compose` Dateien werden verwendet, um Services auf
eine reproduzierbare, local-dev-freundliche Art bereitzustellen.

Datenverzeichnis:
- Der Orchestrator setzt `WINSETUP_DATA` (Default: `%LOCALAPPDATA%\\WinSetup-Pro\\data`)
- Compose nutzt `${WINSETUP_DATA}` fuer Bind-Mounts.

Beispiel:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 -Profiles full -DatabaseMode Container -WebMode Container
```
