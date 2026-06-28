# WinSetup-Pro

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Lizenz](https://img.shields.io/badge/Lizenz-MIT-green.svg?style=for-the-badge)](LICENSE)

<div align="center">
  <img src="assets/images/logo/readme-banner.svg" alt="WinSetup Pro Banner" width="100%">
</div>

WinSetup-Pro ist ein **profilbasiertes** PowerShell-7+-Setup-Orchestrator-Projekt fuer Windows. Fokus:
- **Open-Source-sicher** (keine getrackten Runtime-Logs/PII, keine Remote-`Invoke-Expression`-Bootstraps)
- **Sicher per Default** (Firewall-Regeln / Defender-Exclusions nur Opt-in)
- **Reproduzierbar** (Pinned vs Latest; Manifest-Struktur vorbereitet)
- **Testbar** (CI: Parse, PSScriptAnalyzer, Pester Policy Tests, Secrets Scan)

## Schnellstart

### Voraussetzungen
- Windows 10/11
- PowerShell 7+ (`pwsh`)
- Winget (empfohlen) oder Chocolatey
- Docker Desktop (nur fuer Container-Services wie DB/Web/HA)

### Ausfuehren
```powershell
# Developer essentials
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 -Profiles dev

# Mehrere Profile kombinieren
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 -Profiles dev,security

# Container-Services starten (DB + Web) ueber das "full"-Profil
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 -Profiles full -DatabaseMode Container -WebMode Container
```

### Non-Interactive (CI/Automation)
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 `
  -Profiles dev `
  -NonInteractive `
  -GitUserName "Example User" `
  -GitUserEmail "user@example.com"
```

## Profile
Profile liegen unter `profiles/`:
- `dev`: Git, VS Code, Node.js LTS, Python, .NET, Docker, Windows Terminal, GitHub CLI
- `server`: Admin/Server-Tools (ohne Virtualisierungs-Stack by default)
- `iot`: Home Assistant (container-first)
- `security`: Kuratierte Security-Tools (ZAP, Nmap, Wireshark)
- `backup`: Kuratierte Backup-Tools (7-Zip, FreeFileSync, AOMEI)
- `docs`: Kuratierte Doku-Tools (Obsidian, Draw.io, ShareX, OBS)
- `full`: Kuratiertes Full-Setup inkl. DB/Web Container-Services

## Sichere Defaults (wichtig)
Sicherheitsrelevante Aktionen sind **aus** per Default:
- Keine inbound Firewall-Regeln ohne `-EnableFirewallDevPorts`
- Keine Windows Defender Exclusions ohne `-EnableDefenderExclusions`

## InstallMode: Pinned vs Latest
- `Pinned` (Default): nutzt `packages/catalog.json` Pins (falls vorhanden) und vorbereitetes `manifests/`
- `Latest`: ignoriert Pins und installiert die neueste verfuegbare Version

Siehe `manifests/README.md` fuer den Release-Prozess.

## Projektstruktur (neu)
```
WinSetup-Pro/
├── src/WinSetup.Pro/               # PowerShell module core
├── scripts/                        # Entry-Skripte (Invoke-WinSetup, RepoChecks)
├── profiles/                       # Profile (dev/server/iot/...)
├── packages/catalog.json           # Kanonischer Package-Katalog (winget + choco)
├── compose/                        # Docker Compose fuer Services (DB/Web/HA)
├── manifests/                      # Release-pinned Manifeste
├── tests/                          # Pester-Tests (Policy + Schema + Parse)
└── config/examples/                # Redaktierte Beispiel-Outputs (keine Runtime-Logs)
```

## Repo-Checks (lokal)
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-RepoChecks.ps1
```

## Rueckwaertskompatibilitaet
Die alten Step-Skripte existieren weiterhin als Forwarder:
- `scripts/01-...ps1` bis `scripts/10-...ps1` leiten auf `scripts/compat/` weiter.
- Empfehlung: nutze den Orchestrator `scripts/Invoke-WinSetup.ps1`.

## Lizenz
MIT, siehe `LICENSE`.
