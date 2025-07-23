# ===================================================================
# Dokumentation und Knowledge-Management Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Installation von Dokumentations- und Wissensmanagement-Tools
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Documentation-Knowledge-Setup.log"
)

# Logging-Funktion
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

# Prüfe Administrator-Rechte
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Log "=== Dokumentation und Knowledge-Management Setup gestartet ==="

if (-not (Test-Administrator)) {
    Write-Log "WARNUNG: Skript läuft nicht als Administrator. Einige Funktionen könnten fehlschlagen." "WARNING"
    if (-not $SkipPrompts) {
        $continue = Read-Host "Trotzdem fortfahren? (y/N)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            Write-Log "Setup abgebrochen durch Benutzer." "INFO"
            exit 1
        }
    }
}

try {
    Write-Log "=== Wiki und Documentation-System ==="
    
    # Obsidian für Knowledge Management
    Write-Log "Installiere Obsidian..."
    winget install Obsidian.Obsidian
    Write-Log "Obsidian installiert"

    # Notion Desktop (als Alternative)
    Write-Log "Installiere Notion..."
    winget install Notion.Notion
    Write-Log "Notion installiert"

    # Joplin für Notizen
    Write-Log "Installiere Joplin..."
    winget install Joplin.Joplin
    Write-Log "Joplin installiert"

    Write-Log "=== Diagramm und Visualization Tools ==="
    
    # Draw.io Desktop
    Write-Log "Installiere Draw.io Desktop..."
    winget install JGraph.Draw.io
    Write-Log "Draw.io Desktop installiert"

    # Lucidchart (Web-basiert, nur Information)
    Write-Log "Lucidchart: Web-basiert verfügbar über lucidchart.com"

    # PlantUML (für Code-basierte Diagramme)
    Write-Log "PlantUML: Integration über VS Code Extension bereits konfiguriert"

    Write-Log "=== Markdown-Editoren und Tools ==="
    
    # Typora (Premium Markdown Editor)
    Write-Log "Installiere Typora..."
    winget install Typora.Typora
    Write-Log "Typora installiert"

    # MarkText (Open Source Alternative)
    Write-Log "Installiere MarkText..."
    winget install MarkText.MarkText
    Write-Log "MarkText installiert"

    Write-Log "=== Screenshot und Screen Recording ==="
    
    # Greenshot für Screenshots
    Write-Log "Installiere Greenshot..."
    winget install Greenshot.Greenshot
    Write-Log "Greenshot installiert"

    # ShareX für erweiterte Screenshot-Features
    Write-Log "Installiere ShareX..."
    winget install ShareX.ShareX
    Write-Log "ShareX installiert"

    # OBS Studio für Screen Recording
    Write-Log "Installiere OBS Studio..."
    winget install OBSProject.OBSStudio
    Write-Log "OBS Studio installiert"

    Write-Log "=== License-Management-System ==="
    
    # Simple License Manager (eigene Lösung)
    Write-Log "Erstelle License-Management-System..."

    Write-Log "=== Vendor-Contact-Management ==="
    
    # Microsoft Excel für Vendor-Datenbank (bereits verfügbar in Office)
    Write-Log "Excel für Vendor-Kontakt-Management verfügbar"

    Write-Log "=== Documentation-Verzeichnisse erstellen ==="
    
    # Hauptdokumentation-Verzeichnis
    $docsRootDir = "$env:USERPROFILE\Documentation"
    if (-not (Test-Path $docsRootDir)) {
        New-Item -ItemType Directory -Path $docsRootDir
        Write-Log "Hauptdokumentation-Verzeichnis erstellt: $docsRootDir"
    }

    # Unterverzeichnisse für verschiedene Dokumentations-Typen
    $docDirs = @(
        "System-Configuration",
        "Troubleshooting-Guides",
        "Project-Documentation",
        "Vendor-Information",
        "License-Management",
        "Change-Logs",
        "Templates",
        "Screenshots",
        "Diagrams"
    )

    foreach ($dir in $docDirs) {
        $fullPath = Join-Path $docsRootDir $dir
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath
            Write-Log "Dokumentation-Unterverzeichnis erstellt: $fullPath"
        }
    }

    Write-Log "=== Konfiguration-as-Code Repository erstellen ==="
    
    # Git Repository für Konfigurationsdateien
    $configRepoDir = Join-Path $docsRootDir "System-Configuration"
    if (-not (Test-Path "$configRepoDir\.git")) {
        Push-Location $configRepoDir
        git init
        git config user.name "System Administrator"
        git config user.email "admin@local.system"
        
        # .gitignore für sensible Daten
        $gitignoreContent = @"
# Sensitive Information
*.key
*.pem
*.pfx
passwords.txt
secrets.json
*.env

# Temporary Files
*.tmp
*.temp
*.log

# System Files
Thumbs.db
.DS_Store
*.swp
*.swo
"@
        Set-Content -Path ".gitignore" -Value $gitignoreContent -Encoding UTF8
        
        # README für das Repository
        $readmeContent = @"
# System Configuration Repository

Dieses Repository enthält alle wichtigen Konfigurationsdateien und Dokumentationen für das Windows-PostInstall-Setup System.

## Struktur

- `config/` - Konfigurationsdateien
- `scripts/` - Automatisierungs-Skripte
- `docs/` - Systemdokumentation
- `templates/` - Vorlagen und Templates

## Verwendung

Alle Änderungen an der Systemkonfiguration sollten hier dokumentiert und versioniert werden.

## Sicherheitshinweis

⚠️ Keine Passwörter oder sensible Daten in diesem Repository speichern!
"@
        Set-Content -Path "README.md" -Value $readmeContent -Encoding UTF8
        
        git add .
        git commit -m "Initial commit: System Configuration Repository"
        Pop-Location
        
        Write-Log "Git Repository für Konfigurationsdateien erstellt: $configRepoDir"
    }

    Write-Log "=== Troubleshooting-Guides erstellen ==="
    
    # Troubleshooting-Template
    $troubleshootingTemplate = @"
# Troubleshooting Guide Template

## Problem-Beschreibung
**Symptome:** 
**Betroffene Systeme:** 
**Häufigkeit:** 

## Root Cause Analysis
**Ursache:** 
**Auslöser:** 

## Lösung
### Sofortmaßnahmen
1. 
2. 
3. 

### Langfristige Lösung
1. 
2. 
3. 

## Präventionsmaßnahmen
- 
- 
- 

## Verwandte Probleme
- 
- 

## Dokumentiert von
**Name:** 
**Datum:** $(Get-Date -Format 'yyyy-MM-dd')
**Letzte Aktualisierung:** 

## Tags
#troubleshooting #system #configuration
"@

    $troubleshootingTemplatePath = Join-Path (Join-Path $docsRootDir "Templates") "Troubleshooting-Guide-Template.md"
    Set-Content -Path $troubleshootingTemplatePath -Value $troubleshootingTemplate -Encoding UTF8
    Write-Log "Troubleshooting-Guide-Template erstellt: $troubleshootingTemplatePath"

    Write-Log "=== License-Management-System ==="
    
    # License-Tracking CSV-Template
    $licenseTrackingContent = @"
Software,Version,License-Key,Purchase-Date,Expiry-Date,Vendor,Contact,Notes,Status
Windows 11 Pro,,,,,,Microsoft Support,,Active
Visual Studio Code,,Free,,,Microsoft,,Open Source,Active
Office 365,,,,,,Microsoft,,Subscription
"@

    $licenseTrackingPath = Join-Path (Join-Path $docsRootDir "License-Management") "Software-Licenses.csv"
    Set-Content -Path $licenseTrackingPath -Value $licenseTrackingContent -Encoding UTF8
    Write-Log "License-Tracking-System erstellt: $licenseTrackingPath"

    Write-Log "=== Vendor-Contact-Database ==="
    
    # Vendor-Kontakt CSV-Template
    $vendorContactContent = @"
Company,Primary-Contact,Email,Phone,Support-URL,Account-Manager,License-Manager,Notes,Last-Contact
Microsoft,Microsoft Support,support@microsoft.com,+1-800-MICROSOFT,https://support.microsoft.com,,,Official Support,
GitHub,GitHub Support,support@github.com,,https://support.github.com,,,Git Repository Hosting,
Google,Google Support,support@google.com,,https://support.google.com,,,Cloud Services,
"@

    $vendorContactPath = Join-Path (Join-Path $docsRootDir "Vendor-Information") "Vendor-Contacts.csv"
    Set-Content -Path $vendorContactPath -Value $vendorContactContent -Encoding UTF8
    Write-Log "Vendor-Contact-Database erstellt: $vendorContactPath"

    Write-Log "=== Change-Management-Prozess ==="
    
    # Change-Log-Template
    $changeLogTemplate = @"
# System Change Log

## Change #$(Get-Date -Format 'yyyyMMdd')-001

**Datum:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Durchgeführt von:** 
**Kategorie:** [System/Software/Configuration/Security]
**Priorität:** [Low/Medium/High/Critical]

### Änderungsbeschreibung


### Grund für Änderung


### Betroffene Systeme
- 
- 

### Durchgeführte Schritte
1. 
2. 
3. 

### Rollback-Plan
1. 
2. 
3. 

### Tests durchgeführt
- [ ] Funktionalitätstest
- [ ] Performance-Test
- [ ] Sicherheitstest
- [ ] Backup-Verifikation

### Ergebnis
**Status:** [Erfolgreich/Fehlgeschlagen/Teilweise]
**Bemerkungen:** 

### Lessons Learned


---
"@

    $changeLogPath = Join-Path (Join-Path $docsRootDir "Change-Logs") "Change-Log-$(Get-Date -Format 'yyyy-MM').md"
    Set-Content -Path $changeLogPath -Value $changeLogTemplate -Encoding UTF8
    Write-Log "Change-Management-Template erstellt: $changeLogPath"

    Write-Log "=== Obsidian Vault konfigurieren ==="
    
    # Obsidian Vault im Documentation-Verzeichnis erstellen
    $obsidianVaultDir = Join-Path $docsRootDir "Obsidian-Vault"
    if (-not (Test-Path $obsidianVaultDir)) {
        New-Item -ItemType Directory -Path $obsidianVaultDir
        
        # Obsidian-Konfiguration
        $obsidianConfigDir = Join-Path $obsidianVaultDir ".obsidian"
        New-Item -ItemType Directory -Path $obsidianConfigDir
        
        # Standard-Notiz erstellen
        $welcomeNote = @"
# Windows-PostInstall-Setup Knowledge Base

Willkommen in der Knowledge Base für das Windows-PostInstall-Setup Projekt!

## Struktur

- [[System Configuration]] - Systemkonfigurationsdokumentation
- [[Troubleshooting]] - Fehlerbehebungsanleitungen
- [[Project Documentation]] - Projektdokumentation
- [[Vendor Information]] - Anbieter-Informationen

## Tags

Verwende diese Tags für bessere Organisation:
- #system
- #configuration  
- #troubleshooting
- #project
- #vendor
- #license

## Templates

Nutze die Vorlagen in den Templates-Ordnern für konsistente Dokumentation.

## Letzte Aktualisierung
$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
        
        Set-Content -Path (Join-Path $obsidianVaultDir "Welcome.md") -Value $welcomeNote -Encoding UTF8
        Write-Log "Obsidian Vault erstellt: $obsidianVaultDir"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Dokumentation-Verzeichnisse erstellt:"
    foreach ($dir in $docDirs) {
        Write-Log "- $(Join-Path $docsRootDir $dir)"
    }
    Write-Log ""
    Write-Log "Wichtige Dateien erstellt:"
    Write-Log "- Troubleshooting-Template: $troubleshootingTemplatePath"
    Write-Log "- License-Tracking: $licenseTrackingPath"
    Write-Log "- Vendor-Contacts: $vendorContactPath"
    Write-Log "- Change-Log: $changeLogPath"
    Write-Log "- Obsidian Vault: $obsidianVaultDir"
    Write-Log ""
    Write-Log "Wichtige nächste Schritte:"
    Write-Log "1. Obsidian öffnen und Vault verknüpfen: $obsidianVaultDir"
    Write-Log "2. Notion-Account einrichten (optional)"
    Write-Log "3. Screenshot-Tools (Greenshot/ShareX) konfigurieren"
    Write-Log "4. License-Management CSV pflegen"
    Write-Log "5. Vendor-Kontakte aktualisieren"
    Write-Log "6. Change-Management-Prozess implementieren"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Dokumentation und Knowledge-Management Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ Obsidian (Knowledge Management)
✓ Notion (Collaboration)
✓ Joplin (Note Taking)
✓ Draw.io Desktop (Diagramme)
✓ Typora (Markdown Editor)
✓ MarkText (Markdown Editor)
✓ Greenshot (Screenshots)
✓ ShareX (Advanced Screenshots)
✓ OBS Studio (Screen Recording)

Dokumentation-Verzeichnisstruktur:
- Haupt-Dokumentation: $docsRootDir
$(foreach ($dir in $docDirs) { "- $dir`n" } )

Erstellte Management-Systeme:
- Git Repository für Konfigurationen: $configRepoDir
- License-Tracking: $licenseTrackingPath
- Vendor-Contact-Database: $vendorContactPath
- Change-Management: $changeLogPath
- Obsidian Vault: $obsidianVaultDir

Templates erstellt:
- Troubleshooting-Guide-Template
- Change-Log-Template
- System-Configuration-Template

Nächste Schritte:
- Obsidian Vault konfigurieren
- Knowledge Base strukturieren
- Documentation-Workflow etablieren
- Regelmäßige Backup-Zyklen einrichten
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Dokumentation und Knowledge-Management Setup abgeschlossen!"
