# ===================================================================
# Datenbank-Systeme und Backend-Services Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Automatisierte Installation der Datenbank-Systeme und Backend-Services
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Database-Backend-Setup.log"
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

Write-Log "=== Datenbank-Systeme und Backend-Services Setup gestartet ==="

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
    Write-Log "Installiere MariaDB..."
    winget install MariaDB.MariaDB
    Write-Log "MariaDB installiert"

    Write-Log "Installiere PostgreSQL..."
    winget install PostgreSQL.PostgreSQL
    Write-Log "PostgreSQL installiert"

    Write-Log "Installiere MongoDB..."
    winget install MongoDB.Database
    Write-Log "MongoDB installiert"

    Write-Log "Installiere Redis..."
    winget install Redis.Redis-CLI
    Write-Log "Redis installiert"

    Write-Log "Installiere SQLite Browser..."
    winget install DB.Browser.for.SQLite
    Write-Log "SQLite Browser installiert"

    Write-Log "Installiere API-Testing-Tools (Postman)..."
    winget install Postman.Postman
    Write-Log "Postman installiert"

    Write-Log "Installiere pgAdmin..."
    winget install pgAdmin.pgAdmin4
    Write-Log "pgAdmin installiert"

    # Backup-Verzeichnisse erstellen
    $backupDir = "$env:USERPROFILE\Database-Backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir
        Write-Log "Backup-Verzeichnis erstellt: $backupDir"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Datenbank-Systeme und Backend-Services Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ MariaDB
✓ PostgreSQL
✓ MongoDB
✓ Redis
✓ SQLite Browser
✓ Postman
✓ pgAdmin

Backup-Verzeichnis:
- $backupDir

Nächste Schritte:
- Datenbank-Benutzer und -Berechtigungen konfigurieren
- Datenbank-Initialisierungsskripte ausführen
- API-Tests mit Postman erstellen
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Datenbank-Systeme und Backend-Services Setup abgeschlossen!"
