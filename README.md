# 🚀 WinSetup-Pro

[![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)]()
[![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)]()
[![Last Commit](https://img.shields.io/badge/Letztes_Update-Juli_2025-brightgreen?style=for-the-badge)]()
[![License](https://img.shields.io/badge/Lizenz-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained-yes-success?style=for-the-badge)]()
[![Docs](https://img.shields.io/badge/Dokumentation-Vollst%C3%A4ndig-blue?style=for-the-badge)](docs/)

<div align="center">
  <img src="assets/images/logo/readme-banner.svg" alt="WinSetup Pro Banner" width="100%">
</div>

## 📋 Über das Projekt

WinSetup-Pro ist ein umfassendes PowerShell-basiertes Automatisierungstool für die schnelle und konsistente Einrichtung von Windows-Entwicklungsumgebungen. Mit über 40 Software-Paketen, automatisierten Wartungsaufgaben und einer vollständigen Entwicklungsumgebung bietet es alles, was für einen produktiven Start benötigt wird.

### ✨ Hauptfunktionen auf einen Blick

| Kategorie | Features |
|-----------|----------|
| 💻 **Entwicklung** | VS Code, Git, Docker, Node.js, Python, .NET |
| 🔐 **Sicherheit** | KeePass, Malwarebytes, OWASP ZAP |
| 📂 **Datenbanken** | MySQL, PostgreSQL, MongoDB |
| 🌐 **Web** | XAMPP, nginx, Apache |
| 📚 **Wissen** | Obsidian, Notion |
| 💾 **Backup** | AOMEI, Cloud-Sync, Auto-Backup |

## 📂 Projektstruktur

```
Windows-PostInstall-Setup/
├── README.md                 # Projekt-Übersicht (diese Datei)
├── docs/                     # Dokumentation und Anleitungen
│   └── Plan_Uebersicht.md   # Detaillierter Projektplan
├── status/                   # Status-Tracking und Fortschritt
│   └── Status-Matrix.md     # Live-Status-Matrix aller Schritte
├── scripts/                  # Automatisierungs-Skripte
├── config/                   # Konfigurationsdateien und Templates
└── backups/                  # Backup-Dateien und Sicherungen
```

## Aktueller Status

📍 **Aktuelle Phase**: 100% Vollständig Implementiert 🎉
🎯 **Status**: Projekt erfolgreich abgeschlossen

### 📊 Fortschritt-Übersicht

| Status | Anzahl | Bereich |
|--------|--------|---------|
| ✅ **Abgeschlossen** | 10/10 | Alle Bereiche erfolgreich implementiert |
| 🟡 **Teilweise** | 0/10 | - |
| 🟥 **Offen** | 0/10 | - |

### 🎯 Wichtige Meilensteine erreicht
- **40+ Software-Pakete** automatisch installiert
- **Task Scheduler** mit automatisierten Wartungsaufgaben
- **Backup-Strategien** (AOMEI, Cloud-Sync, Scripts) implementiert
- **Knowledge-Management** (Obsidian, Notion) eingerichtet
- **Security-Stack** (Malwarebytes, KeePass, OWASP ZAP) installiert
- **Vollständige Entwicklungsumgebung** (XAMPP, Node.js, Docker, Git)

## 📸 Screenshots & Demo

### Asset-Übersicht

- **Logo**: `assets/images/logo/winsetup-pro-logo.svg`
- **README Banner**: `assets/images/logo/readme-banner.svg`
- **Social Preview**: `assets/images/logo/social-preview.svg`

> **Hinweis**: Screenshots der Anwendung werden in einem späteren Update hinzugefügt.

## 🚀 Installation

### 💻 Systemvoraussetzungen

| Komponente | Mindestanforderung |
|------------|-------------------|
| **Betriebssystem** | Windows 10/11 Pro oder Enterprise |
| **PowerShell** | Version 7.0 oder höher |
| **RAM** | 8 GB (16 GB empfohlen) |
| **Speicherplatz** | 20 GB frei |
| **Rechte** | Administratorzugriff |
| **Git** | Aktuelle Version |
| **Internet** | Breitbandverbindung |

### Schnellinstallation

1. Repository klonen:
```powershell
git clone https://github.com/IhrUsername/WinSetup-Pro.git
cd WinSetup-Pro
```

2. PowerShell als Administrator ausführen und Ausführungsrichtlinie anpassen:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

3. Grundkonfiguration starten:
```powershell
.\scripts\01-System-Grundkonfiguration.ps1
```

### Manuelle Installation einzelner Komponenten

Sie können auch einzelne Komponenten nach Bedarf installieren:

```powershell
# Entwicklungsumgebung
.\scripts\02-Dev-Setup.ps1

# IoT & Smart Home
.\scripts\04-HomeAssistant-IoT-Setup.ps1

# Sicherheitswerkzeuge
.\scripts\07-Security-Monitoring-Setup.ps1
```

## Quick Links

- [📊 Status-Matrix](status/Status-Matrix.md) - Live-Fortschrittsübersicht
- [📋 Detaillierter Plan](docs/Plan_Uebersicht.md) - Vollständige Projektbeschreibung
- [⚙️ Skripte](scripts/) - Automatisierungs-Tools
- [🔧 Configs](config/) - Konfigurationsdateien

## 💡 Verwendung

### 🚀 Schnellstart

```powershell
# 1. Repository öffnen
cd "C:\Users\admin\Documents\Windows-PostInstall-Setup"

# 2. Status prüfen
Get-Content status\Status-Matrix.md

# 3. Einzelne Schritte ausführen (Beispiele)
powershell -ExecutionPolicy Bypass -File "scripts\04-HomeAssistant-IoT-Setup.ps1" -SkipPrompts
powershell -ExecutionPolicy Bypass -File "scripts\07-Security-Monitoring-Setup.ps1" -SkipPrompts
```

### 📝 Navigation

1. **Status prüfen**: `status/Status-Matrix.md` für aktuellen Fortschritt
2. **Details nachschlagen**: `docs/Plan_Uebersicht.md` für vollständige Schritt-Beschreibungen
3. **Skripte ausführen**: Entsprechende PowerShell-Skripte in `scripts/`
4. **Konfigurationen anpassen**: Templates in `config/` verwenden

### 🎯 Nächste empfohlene Schritte

1. **System-Grundkonfiguration abschließen** (Administrator-Rechte erforderlich)
   ```powershell
   # Als Administrator ausführen:
   powershell -ExecutionPolicy Bypass -File "scripts\01-System-Grundkonfiguration.ps1"
   ```

2. **Datenbanken manuell nachinstallieren**
   - MySQL/MariaDB von mysql.com
   - PostgreSQL von postgresql.org
   - MongoDB Community Edition

3. **VS Code Extensions installieren**
   ```powershell
   # Extensions aus Liste installieren:
   Get-Content config\vscode-extensions-list.txt | ForEach-Object { code --install-extension $_ }
   ```

4. **Git SSH-Keys konfigurieren**
   ```powershell
   # SSH-Key generieren:
   ssh-keygen -t rsa -b 4096 -C "ihre.email@domain.de"
   ```

---

## 📈 Projekt-Metriken

- **📜 PowerShell-Code**: ~96 KB (12 Skripte)
- **📊 Log-Einträge**: ~37 KB (vollständige Historie)
- **📦 Installierte Software**: 40+ Pakete
- **⏱️ Setup-Zeit**: ~6 Stunden (vollautomatisiert)
- **💾 Repository-Größe**: ~140 KB

## 🤝 Mitwirken

Beiträge sind herzlich willkommen! So können Sie mitwirken:

1. Fork des Repositories erstellen
2. Feature-Branch erstellen (`git checkout -b feature/AmazingFeature`)
3. Änderungen committen (`git commit -m 'Add some AmazingFeature'`)
4. Branch pushen (`git push origin feature/AmazingFeature`)
5. Pull Request erstellen

### Richtlinien für Beiträge

- Folgen Sie dem bestehenden Code-Stil
- Aktualisieren Sie die Dokumentation entsprechend
- Testen Sie Ihre Änderungen gründlich
- Beschreiben Sie Ihre Änderungen ausführlich im Pull Request

## 📜 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Siehe [LICENSE](LICENSE) für weitere Informationen.

---

<div align="center">

### 🌟 Star uns auf GitHub

Wenn Ihnen dieses Projekt gefällt, geben Sie uns einen Stern auf GitHub!

</div>

---
*Erstellt: 19.07.2025*  
*Zuletzt aktualisiert: 23.07.2025 04:15*  
*Projekt-Status: 100% Vollständig Abgeschlossen 🎉*
